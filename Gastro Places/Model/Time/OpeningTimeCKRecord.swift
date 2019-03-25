//
//  OpeningTimeCKRecord.swift
//  Gastro Places
//
//  Created by Michal Martinů on 13/03/2019.
//  Copyright © 2019 Michal Martinů. All rights reserved.
//

import Foundation
import CloudKit

struct OpeningTimeCKRecord {
    let record: CKRecord
    
    init(days: [Day], recordReference: CKRecord, openingRecordID: String?) {
        if let id = openingRecordID {
            let recordID = CKRecord.ID(recordName: id)
            self.record = CKRecord(recordType: "OpeningTime", recordID: recordID)
        } else {
            self.record = CKRecord(recordType: "OpeningTime")
        }
        
        let reference = CKRecord.Reference(record: recordReference, action: .deleteSelf)
        
        self.record["place"] = reference
        
        for day in days {
            record[day.name.lowercased()] = day.full
        }
    }
}

