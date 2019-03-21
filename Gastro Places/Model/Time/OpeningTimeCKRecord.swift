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
    let recordID: CKRecord.ID
    let record: CKRecord
    
    init(days: [Day], id: CKRecord.ID, recordReference: CKRecord) {
        recordID = id
        
        self.record = CKRecord(recordType: "OpeningTime")
        let reference = CKRecord.Reference(record: recordReference, action: .deleteSelf)
        
        self.record["place"] = reference
        
        for day in days {
            record[day.name.lowercased()] = day.full
        }
    }
}

