//
//  Place.swift
//  Gastro Places
//
//  Created by Michal Martinů on 02/04/2019.
//  Copyright © 2019 Michal Martinů. All rights reserved.
//

import Foundation
import CoreLocation

class Place {
    var location: CLLocation?
    var placeID: String?
    var cathegory: String?
    var name: String?
    var phone: String?
    var email: String?
    var web: String?
    var address: Address?
    var userID: String?
    
    init(location: CLLocation) {
        self.location = location
    }
    
    init(placeID: String, name: String, cathegory: String, location: CLLocationCoordinate2D) {
        self.placeID = placeID
        self.name = name
        self.cathegory = cathegory
        self.location = CLLocation.init(latitude: location.latitude, longitude: location.longitude)
    }
    
    init(place: PlaceCoreData) {
        self.location = CLLocation(latitude: place.latitude, longitude: place.longitude)
        self.placeID = place.placeID
        self.cathegory = place.cathegory
        self.name = place.name
        self.phone = place.phone
        self.email = place.email
        self.web = place.web
        self.address = Address.init(city: place.city ?? "", zipCode: place.zipCode ?? "", street: place.street ?? "")
        self.userID = place.userID
    }
}
