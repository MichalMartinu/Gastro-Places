//
//  Day.swift
//  Gastro Places
//
//  Created by Michal Martinů on 03/04/2019.
//  Copyright © 2019 Michal Martinů. All rights reserved.
//

import Foundation

struct Day {
    var name: String
    var from: Time?
    var to: Time?
    
    var full: String? {
        if let _from = from?.string, let _to = to?.string {
            return "\(_from)-\(_to)"
        }
        return nil
    }
    
    init(day: String) {
        self.name = day
    }
    
    init(day: String, from: Time, to: Time) {
        self.name = day
        self.from = from
        self.to = to
    }
}
