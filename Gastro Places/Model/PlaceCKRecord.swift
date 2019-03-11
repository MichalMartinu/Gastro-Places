//
//  PlaceCKRecord.swift
//  Gastro Places
//
//  Created by Michal Martinů on 11/03/2019.
//  Copyright © 2019 Michal Martinů. All rights reserved.
//

import Foundation
import CloudKit

struct PlaceCKRecord {
    let recordID: CKRecord.ID
    let record: CKRecord
    
    init(place: Place) {
        if let _recordID = place.placeID {
            recordID = CKRecord.ID(recordName: _recordID)
        } else {
            let uuid = UUID().uuidString
            recordID = CKRecord.ID(recordName: uuid)
        }
        
        
        record = CKRecord(recordType: placeRecord.record, recordID: recordID)
        
        initItems(place: place)
    }
    
    private func initItems(place: Place) {
        record[placeRecord.location] = place.location as CLLocation
        
        if let name = place.name {
            record[placeRecord.name] = name
        }
        if let cathegory = place.cathegory {
            record[placeRecord.cathegory] = cathegory
        }
        if let city = place.address?.city {
            record[placeRecord.city] = city
        }
        if let street = place.address?.street {
            record[placeRecord.street] = street
        }
        if let zipCode = place.address?.zipCode {
            record[placeRecord.zipCode] = zipCode
        }
        if let web = place.web {
            record[placeRecord.web] = web
        }
        if let email = place.email {
            record[placeRecord.email] = email
        }
        if let phone = place.phone {
            record[placeRecord.phone] = phone
        }
    }
        
}
