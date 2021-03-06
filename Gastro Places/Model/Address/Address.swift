//
//  Address.swift
//  Gastro Places
//
//  Created by Michal Martinů on 11/03/2019.
//  Copyright © 2019 Michal Martinů. All rights reserved.
//

import Foundation

class Address: NSObject {
    var city: String
    var zipCode: String
    var street: String
    
    var full: String {
        if street.count == 0 {
            return "\(city) \(zipCode)"
        }
        return "\(street), \(city) \(zipCode)"
    }
    
    init(city: String, zipCode: String, street: String) {
        self.city = city
        self.zipCode = zipCode
        self.street = street
    }
}
