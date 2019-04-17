//
//  Review.swift
//  Gastro Places
//
//  Created by Michal Martinů on 02/04/2019.
//  Copyright © 2019 Michal Martinů. All rights reserved.
//

import Foundation
import CloudKit

struct Review {
    let date: Date?
    let rating: Int
    let text: String?
    let user: String?
    var cloudID:  CKRecord.ID?
    
    init(date: Date, rating: Int, text: String?, user: String?, cloudID: CKRecord.ID?) {
        self.date = date
        self.rating = rating
        self.text = text
        self.user = user
        self.cloudID = cloudID
    }
    
    init(rating: Int, text: String?) {
        self.date = nil
        self.user = nil
        self.rating = rating
        self.text = text
        cloudID = nil
    }
}
