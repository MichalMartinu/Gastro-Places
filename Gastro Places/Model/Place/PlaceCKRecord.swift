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
        
        record = CKRecord(recordType: PlaceCKRecordNames.record, recordID: recordID)
        
        record[PlaceCKRecordNames.location] = place.location! as CLLocation
        
        if let name = place.name {
            record[PlaceCKRecordNames.name] = name
        }
        if let cathegory = place.cathegory {
            record[PlaceCKRecordNames.cathegory] = cathegory
        }
        if let city = place.address?.city {
            record[PlaceCKRecordNames.city] = city
        }
        if let street = place.address?.street {
            record[PlaceCKRecordNames.street] = street
        }
        if let zipCode = place.address?.zipCode {
            record[PlaceCKRecordNames.zipCode] = zipCode
        }
        if let web = place.web {
            record[PlaceCKRecordNames.web] = web
        }
        if let email = place.email {
            record[PlaceCKRecordNames.email] = email
        }
        if let phone = place.phone {
            record[PlaceCKRecordNames.phone] = phone
        }
    }
}
