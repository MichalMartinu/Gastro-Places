//
//  PlaceAnnotationItem.swift
//  Gastro Places
//
//  Created by Michal Martinů on 08/03/2019.
//  Copyright © 2019 Michal Martinů. All rights reserved.
//

import Foundation
import CoreLocation
import MapKit
import CloudKit

struct PlaceAnnotationItem {
    var name: String
    var cathegory: String
    var location: CLLocation
    
    var annotation: MKPointAnnotation {
        let annotation = MKPointAnnotation()
        annotation.coordinate = location.coordinate
        annotation.title = name
        annotation.subtitle = cathegory
        return annotation
    }
    
    init(name: String, cathegory: String, location: CLLocation) {
        self.name = name
        self.cathegory = cathegory
        self.location = location
    }
}
