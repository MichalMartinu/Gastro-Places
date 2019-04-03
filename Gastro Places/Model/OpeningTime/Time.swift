//
//  Time.swift
//  Gastro Places
//
//  Created by Michal Martinů on 03/04/2019.
//  Copyright © 2019 Michal Martinů. All rights reserved.
//

import Foundation

class Time {
    var hours: Int
    var minutes: Int
    
    var string: String {
        if minutes == 0 {
            return "\(hours):\(minutes)0"
        } else {
            return "\(hours):\(minutes)"
        }
    }
    
    var interval: Int {
        return hours * 60 + minutes
    }
    
    init(minutes: Int) {
        self.hours = minutes / 60
        self.minutes = minutes % 60
    }
}
