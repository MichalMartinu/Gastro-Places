//
//  OpeningTimeCKRecord.swift
//  Gastro Places
//
//  Created by Michal Martinů on 13/03/2019.
//  Copyright © 2019 Michal Martinů. All rights reserved.
//

import Foundation
import CloudKit

class OpeningTimeCKRecord {
    let record: CKRecord
    
    init(days: [Day], recordReference: CKRecord, openingRecordID: CKRecord.ID?) {
        if let recordID = openingRecordID {
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
    
    init(openingTimeCoreData: OpeningTimeCoreData) {
        let record = CKRecord(recordType: "OpeningTime")
        
        record["monday"] = openingTimeCoreData.monday
        record["tuesday"] = openingTimeCoreData.tuesday
        record["wednesday"] = openingTimeCoreData.wednesday
        record["thursday"] = openingTimeCoreData.thursday
        record["friday"] = openingTimeCoreData.friday
        record["saturday"] = openingTimeCoreData.saturday
        record["sunday"] = openingTimeCoreData.sunday
        
        self.record = record
    }
}

