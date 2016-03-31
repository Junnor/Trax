//
//  GPXViewController.swift
//  Trax
//
//  Created by Junor on 3/30/16.
//  Copyright © 2016 Junor. All rights reserved.
//

import UIKit
import MapKit

class GPXViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView! {
        didSet {
            mapView.mapType = .Satellite
            mapView.delegate = self
        }
    }
    
    var gpxURl: NSURL? {
        didSet {
            if let url  = gpxURl {
                GPX.parse(url) {
                    if let gpx = $0 {
                        self.handleWaypoints(gpx.waypoints)
                    }
                }

            }
        }
    }
    
    private func cleanWaypoints() {
        if mapView?.annotations != nil {
            mapView.removeAnnotations(mapView.annotations as [MKAnnotation])
        }
    }

    private func handleWaypoints(waypoints: [GPX.Waypoint]) {
        mapView.addAnnotations(waypoints)
        mapView.showAnnotations(waypoints, animated: true)
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
        
        view?.leftCalloutAccessoryView = nil
        view?.rightCalloutAccessoryView = nil
        if let waypoints = annotation as? GPX.Waypoint {
            if waypoints.thumbnailURL != nil {
                view?.leftCalloutAccessoryView = UIImageView(frame: Constants.LeftCalloutFrame )
            }
            if waypoints.imageURL != nil {
                view?.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure) as UIButton
            }
        }
        
        return view
    }

    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
        if let waypoints = view.annotation as? GPX.Waypoint {
            if let thumnailImageView = view.leftCalloutAccessoryView as? UIImageView {
                dispatch_async(dispatch_get_global_queue(Int(QOS_CLASS_DEFAULT.rawValue), 0)) { 
                    if let imageData = NSData(contentsOfURL: waypoints.thumbnailURL!) {
                        if let image = UIImage(data: imageData) {
                            dispatch_async(dispatch_get_main_queue()) { 
                                thumnailImageView.image = image
                            }
                        }
                    }
                 }
            }
        }
    }
    
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        performSegueWithIdentifier(Constants.ShowImageSegue, sender: view)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == Constants.ShowImageSegue {
            if let waypoints = (sender as? MKAnnotationView)?.annotation as? GPX.Waypoint {
                if let imageVC = segue.destinationViewController as? ImageViewController {
                    imageVC.imageURL = waypoints.imageURL
                    print("url = \(imageVC.imageURL)")
                    imageVC.title = waypoints.name
                }
            }
        }
    }
    
    
    // MARK: - ViewController Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let center = NSNotificationCenter.defaultCenter()
        let queue = NSOperationQueue.mainQueue()
        let appDelegate = UIApplication.sharedApplication().delegate
        center.addObserverForName(GPXURL.Notification, object: appDelegate, queue: queue) { (notification) in
            if let url = notification.userInfo?[GPXURL.Key] as? NSURL {
                self.gpxURl = url
            }
        }
//        gpxURl = NSURL(string: "http://cs193p.stanford.edu/Vacation.gpx")  // Demo test
    }
    
}

