//
//  Review.swift
//  Gastro Places
//
//  Created by Michal Martinů on 02/04/2019.
//  Copyright © 2019 Michal Martinů. All rights reserved.
//

import Foundation

struct Review {
    let date: Date?
    let rating: Int
    let text: String?
    
    init(date: Date, rating: Int, text: String?) {
        self.date = date
        self.rating = rating
        self.text = text
    }
    
    init(rating: Int, text: String?) {
        self.date = nil
        self.rating = rating
        self.text = text
    }
}
