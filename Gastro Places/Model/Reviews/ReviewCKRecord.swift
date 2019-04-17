//
//  ReviewCKRecord.swift
//  Gastro Places
//
//  Created by Michal Martinů on 02/04/2019.
//  Copyright © 2019 Michal Martinů. All rights reserved.
//

import Foundation
import CloudKit

class ReviewCKRecord {
    let record: CKRecord
    
    init(review: Review, placeID: String, reviewRecordID: CKRecord.ID?) {
        
        if let id = reviewRecordID {
            self.record = CKRecord(recordType: "Review", recordID: id)
        } else {
            self.record = CKRecord(recordType: "Review")
        }
        
        let referenceRecordID = CKRecord.ID(recordName: placeID)
        let reference = CKRecord.Reference(recordID: referenceRecordID, action: .deleteSelf)
        
        self.record["place"] = reference
        self.record["text"] = review.text
        self.record["rating"] = review.rating
    }
}
