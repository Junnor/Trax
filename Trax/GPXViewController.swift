//
//  GPXViewController.swift
//  Trax
//
//  Created by Junor on 3/30/16.
//  Copyright © 2016 Junor. All rights reserved.
//

import UIKit
import MapKit

class GPXViewController: UIViewController {

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
    }
    
}

extension GPXViewController: MKMapViewDelegate {
    
}

