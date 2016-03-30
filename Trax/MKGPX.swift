//
//  MKGPX.swift
//  Trax
//
//  Created by Junor on 3/30/16.
//  Copyright © 2016 Junor. All rights reserved.
//

import MapKit

extension GPX.Waypoint: MKAnnotation {
    
    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    var title = String! {
        return name
     }
    
    var subtitle = String! {
        return info
    }
    
}
