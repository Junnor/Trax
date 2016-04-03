//
//  GPXViewController.swift
//  Trax
//
//  Created by Junor on 3/30/16.
//  Copyright © 2016 Junor. All rights reserved.
//

import UIKit
import MapKit

class GPXViewController: UIViewController, MKMapViewDelegate, UIPopoverPresentationControllerDelegate {

    @IBOutlet weak var mapView: MKMapView! {
        didSet {
            mapView.mapType = .Satellite
            mapView.delegate = self
        }
    }
    
    var gpxURL: NSURL? {
        didSet {
            clearWaypoints()
            if let url = gpxURL {
                print("url = \(url)")
                GPX.parse(url) {
                    if let gpx = $0 {
                        self.handleWaypoints(gpx.waypoints)
                    }
                }
            }
        }
    }
    
    
    // MARK: - Waypoints 
    
    private func clearWaypoints() {
        if mapView?.annotations != nil {
            mapView.removeAnnotations(mapView.annotations as [MKAnnotation])
        }
    }

    private func handleWaypoints(waypoints: [GPX.Waypoint]) {
        mapView.addAnnotations(waypoints)
        mapView.showAnnotations(waypoints, animated: true)
    }
    
    @IBAction func addWaypoints(sender: UILongPressGestureRecognizer) {
        if sender.state == UIGestureRecognizerState.Began {
            let coordinate = mapView.convertPoint(sender.locationInView(mapView), toCoordinateFromView: mapView)
            let waypoint = EditabelWaypoint(latitude: coordinate.latitude, longitude: coordinate.longitude)
            waypoint.name = "Dropped"
            mapView.addAnnotation(waypoint)
        }
    }
    
    
    // MARK: - Constants
    
    private struct Constants {
        static let PartialTrackColor = UIColor.greenColor()
        static let FullTrackColor = UIColor.blueColor().colorWithAlphaComponent(0.5)
        static let TrackLineWidth: CGFloat = 3.0
        static let ZoomCooldown = 1.5
        static let LeftCalloutFrame = CGRect(x: 0, y: 0, width: 59, height: 59)
        static let AnnotationViewResuseIdentifier = "Waypoint"
        static let ShowImageSegue = "Show Image"
        static let EditWaypointSegue = "Edit Waypoint"
        static let EditWaypointPopoverWidth: CGFloat = 320
    }
    
    
    // MARK: - MKMapViewDelegate
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        var view = mapView.dequeueReusableAnnotationViewWithIdentifier(Constants.AnnotationViewResuseIdentifier)
        if view == nil {
            view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: Constants.AnnotationViewResuseIdentifier)
            view?.canShowCallout = true
        } else {
            view?.annotation = annotation
        }
        
        view?.draggable = annotation is EditabelWaypoint
        
        view?.leftCalloutAccessoryView = nil
        view?.rightCalloutAccessoryView = nil
        if let waypoint = annotation as? GPX.Waypoint {
            if waypoint.thumbnailURL != nil {
                view?.leftCalloutAccessoryView = UIButton(frame: Constants.LeftCalloutFrame )
            }
            if annotation is EditabelWaypoint {
                view?.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure) as UIButton
            }
        }
        
        return view
    }

    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
        if let waypoint = view.annotation as? GPX.Waypoint {
            if let thumnailImageButton = view.leftCalloutAccessoryView as? UIButton {
                dispatch_async(dispatch_get_global_queue(Int(QOS_CLASS_DEFAULT.rawValue), 0)) { 
                    if let imageData = NSData(contentsOfURL: waypoint.thumbnailURL!) {
                        if let image = UIImage(data: imageData) {
                            dispatch_async(dispatch_get_main_queue()) { 
                                thumnailImageButton.setImage(image, forState: .Normal)
                            }
                        }
                    }
                 }
            }
        }
    }
    
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if (control as? UIButton)?.buttonType == UIButtonType.DetailDisclosure {
            mapView.deselectAnnotation(view.annotation, animated: true)
            performSegueWithIdentifier(Constants.EditWaypointSegue, sender: view)
        } else if let waypoint = view.annotation as? GPX.Waypoint {
            if waypoint.imageURL != nil {
                performSegueWithIdentifier(Constants.ShowImageSegue, sender: view)
            }
        }
    }
    
    
    // MARK: - Segue Thing
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == Constants.ShowImageSegue {
            if let waypoint = (sender as? MKAnnotationView)?.annotation as? GPX.Waypoint {
                if let imageVC = segue.destinationViewController.contentViewController as? ImageViewController {
                    imageVC.imageURL = waypoint.imageURL
                    print("url = \(imageVC.imageURL)")
                    imageVC.title = waypoint.name
                }
            }
        } else if segue.identifier == Constants.EditWaypointSegue {
            if let waypoint = (sender as? MKAnnotationView)?.annotation as? EditabelWaypoint {
                if let editWaypointVC = segue.destinationViewController.contentViewController as? EditWaypointViewController {
                    if let ppc = editWaypointVC.popoverPresentationController {   // iPad love it
                        let coordinatePoint = mapView.convertCoordinate(waypoint.coordinate, toPointToView: mapView)
                        ppc.sourceRect = (sender as! MKAnnotationView).popverSourceRectForCoordinatePoint(coordinatePoint)
                        let minimumSize = editWaypointVC.view.systemLayoutSizeFittingSize(UILayoutFittingCompressedSize)
                        editWaypointVC.preferredContentSize = CGSize(width: Constants.EditWaypointPopoverWidth, height: minimumSize.height)
                        ppc.delegate = self
                    }
                    editWaypointVC.waypointToEdit = waypoint
                }
            }
        }
    }
    
    
    // MARK: - UIPopoverPresentationControllerDelegate
    
    // Let the screen not black
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.OverFullScreen
    }
    
    // Show iPhone's done button & Show the visual effect
    func presentationController(controller: UIPresentationController, viewControllerForAdaptivePresentationStyle style: UIModalPresentationStyle) -> UIViewController? {
        let naviVC = UINavigationController(rootViewController: controller.presentedViewController )
        let visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .ExtraLight))
        visualEffectView.frame = naviVC.view.bounds
        naviVC.view.insertSubview(visualEffectView, atIndex: 0)
        return naviVC
    }
    
    // MARK: - ViewController Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Vacation"
        
        let center = NSNotificationCenter.defaultCenter()
        let queue = NSOperationQueue.mainQueue()
        let appDelegate = UIApplication.sharedApplication().delegate
        center.addObserverForName(GPXURL.Notification, object: appDelegate, queue: queue) { (notification) in
            if let url = notification.userInfo?[GPXURL.Key] as? NSURL {
                self.gpxURL = url
            }
        }
        
        let path = NSBundle .mainBundle().URLForResource("Vacation", withExtension: "gpx")
        gpxURL = path  // Demo test
    }
    
}


// MARK: - Extention UIViewController

extension UIViewController {
    
    var contentViewController: UIViewController {
        if let navc = self as? UINavigationController {
            return navc.visibleViewController!
        } else {
            return self
        }
    }
    
}

// MARK: - Extention MKAnnotationView

extension MKAnnotationView {
    
    func popverSourceRectForCoordinatePoint(coordinatePoint: CGPoint) -> CGRect {
        var popoverSourceRectCenter = coordinatePoint
        popoverSourceRectCenter.x -= frame.width / 2 - centerOffset.x - calloutOffset.x
        popoverSourceRectCenter.y -= frame.height / 2 - centerOffset.y - calloutOffset.y
        return CGRect(origin: popoverSourceRectCenter, size: frame
        .size)
    }
    
}

 
