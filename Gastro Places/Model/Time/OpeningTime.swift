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
    
    init(seconds: Int) {
        self.hours = seconds / 60
        self.minutes = seconds % 60
    }
}

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

class OpeningTime {
    private var minuteInterval: Int
    var times = [Time]()
    private let dayNames = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
    var days = [Day]()
    
    var stringHours: String {
        var string = ""
        for day in days {
            if let _from = day.from?.string, let _to = day.to?.string {
                string += "\(_from)-\(_to)\n"
            } else {
                string += "\n"
            }
        }
        return string
    }
    
    var stringDays: String {
        var string = ""
        for day in dayNames {
            string += "\(day):\n"
        }
        return string
    }
    
    init(intervalInMinutes: Int) {
        minuteInterval = intervalInMinutes
        times = generateTime(interval: intervalInMinutes)
        initDays()
    }
    
    func generateTime(interval: Int) -> [Time] {
        var times = [Time]()
        
        let sequence = stride(from: 0, to: 24 * 60, by: interval)
        
        for seconds in sequence {
            let time = Time.init(seconds: seconds)
            times.append(time)
        }
        
        // Add 0:00 to end
        let midnigth = Time.init(seconds: 0)
        times.append(midnigth)
        
        return times
    }
    
    func initDays() {
        for dayName in dayNames {
            days.append(Day.init(day: dayName))
        }
    }
    
    func setDay(indexPath: Int, from: Time?, to: Time?) {
        // When day is not initialized and day before is, set same time
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
