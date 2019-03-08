//
//  PlaceCKRecord.swift
//  Gastro Places
//
//  Created by Michal Martinů on 08/03/2019.
//  Copyright © 2019 Michal Martinů. All rights reserved.
//

import Foundation
import CloudKit

let placeRecordNames = PlaceCKRecordNames()

struct PlaceCKRecordNames {
    let name = "name"
    let cathegory = "cathegory"
    let city = "city"
    let street = "street"
    let email = "email"
    let location = "location"
    let phone = "phone"
    let web = "web"
    let placeID = "recordName"
}

/*struct PlaceCKRecord {
    let identifier = PlaceCKRecordNames()
    
    var name: String?
    var cathegory: String?
    var city: String?
    var street: String?
    var email: String?
    var location: CLLocation?
    var phone: String?
    var web: String?
    var placeID: String?
    
    
    
    init(_ record: CKRecord) {
        if let name = record[identifier.name] as? String {
            self.name = name
        }
        
        if let cathegory
        
    }
}*/
