//
//  OpeningTime.swift
//  Gastro Places
//
//  Created by Michal Martinů on 12/03/2019.
//  Copyright © 2019 Michal Martinů. All rights reserved.
//

import UIKit

struct Time {
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
    
    init(hours: Int, minutes: Int) {
        self.hours = hours
        self.minutes = minutes
    }
}

struct Day {
    var name: String
    var from: Time?
    var to: Time?

    init(day: String) {
        self.name = day
    }
    
    init(day: String, from: Time, to: Time) {
        self.name = day
        self.from = from
        self.to = to
    }
}

class OpeningTime: NSObject {
    var minuteInterval: Int
    var times = [Time]()
    let daysNames = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
    var days = [Day]()
    
    
    init(intervalInMinutes: Int) {
        minuteInterval = intervalInMinutes
        super.init()
        times = generateTime(interval: intervalInMinutes)
        initDays()
    }
    
    func generateTime(interval: Int) -> [Time] {
        var times = [Time]()
        
        let sequence = stride(from: 0, to: 60, by: interval)
        
        for hour in 0..<24 {
            for minute in sequence {
                let day = Time.init(hours: hour, minutes: minute)
                times.append(day)
            }
        }
        return times
    }
    
    func initDays() {
        for dayName in daysNames {
            days.append(Day.init(day: dayName))
        }
    }
    
    func setDay(indexPath: Int, from: Time?, to: Time?) {
        let beforeIndex = indexPath - 1
        if from != nil, to != nil, beforeIndex >= 0 {
            if days[indexPath].from == nil,  days[indexPath].to == nil {
                if let _from = days[beforeIndex].from, let _to = days[beforeIndex].to {
                    days[indexPath].from = _from
                    days[indexPath].to = _to
                    return
                }
            }
        }
        
        days[indexPath].from = from
        days[indexPath].to = to
    }
}
