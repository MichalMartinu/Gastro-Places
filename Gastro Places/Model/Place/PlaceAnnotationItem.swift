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

class PlaceAnnotation: NSObject, MKAnnotation {
    let title: String?
    let cathegory: String
    let coordinate: CLLocationCoordinate2D
    
    init(title: String, cathegory: String, coordinate: CLLocationCoordinate2D) {
        self.title = title
        self.cathegory = cathegory
        self.coordinate = coordinate
        
        super.init()
    }
    
    var subtitle: String? {
        return cathegory
    }
}

class PlaceAnnotationView: MKMarkerAnnotationView {
    override var annotation: MKAnnotation? {
        willSet {
            guard let place = newValue as? PlaceAnnotation else { return }
            markerTintColor = placesCathegories.colorForCathegory(cathegory: place.cathegory)
            if place.cathegory.count > 0 {
                // When cathegory string is longer than 0 chars
                glyphText = String(place.cathegory.first!)
            } else {
                glyphText = "New"
            }
        }
    }
}

