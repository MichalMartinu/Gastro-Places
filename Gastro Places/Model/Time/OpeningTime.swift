//
//  OpeningTime.swift
//  Gastro Places
//
//  Created by Michal Martinů on 12/03/2019.
//  Copyright © 2019 Michal Martinů. All rights reserved.
//

import UIKit
import CloudKit
import CoreData

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

class Day {
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


protocol OpeningTimeDelegate: AnyObject {
    func openingTimeDidLoad()
}

class OpeningTime {
    private var minuteInterval: Int
    var times = [Time]()
    private let dayNames = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
    var days = [Day]()
    
    weak var delegate: OpeningTimeDelegate?
    
    private static let openingTimeQueue = DispatchQueue(label: "openingTimeQueue", qos: .userInteractive, attributes: .concurrent)
    
    var stringHours: String {
        var string = ""
        for day in days {
            if let _from = day.from?.string, let _to = day.to?.string {
                if _from == "0:00", _to == "0:00" {
                    string += "nonstop\n"
                } else {
                    string += "\(_from)-\(_to)\n"
                }
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
    }
    
    func generateTime(interval: Int) -> [Time] {
        var times = [Time]()
        
        let sequence = stride(from: 0, to: 24 * 60, by: interval)
        
        for minutes in sequence {
            let time = Time.init(minutes: minutes)
            times.append(time)
        }
        
        // Add 0:00 to end
        let midnigth = Time.init(minutes: 0)
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
    
    func fetchOpeningHours(placeID: String) {
        //state = .Executing
        OpeningTime.openingTimeQueue.async {
            self.gtFetchOpeningHours(placeID: placeID)
        }
    }
    
    private func gtFetchOpeningHours(placeID: String) {
        let container = CKContainer.default()
        let publicDB = container.publicCloudDatabase
        
        let recordID = CKRecord.ID(recordName: placeID)
        let recordToMatch = CKRecord.Reference(recordID: recordID, action: .deleteSelf)
        
        let predicate = NSPredicate(format: "place == %@", recordToMatch)
        let query = CKQuery(recordType: "OpeningTime", predicate: predicate)
        publicDB.perform(query, inZoneWith: nil) { results, error in
            
            if error != nil {
                return
            }
            
            if results?.count == 1, let _result = results?.first {
                
                self.initDaysFromCKRecord(_result)
                
                DispatchQueue.main.async {
                    self.delegate?.openingTimeDidLoad()
                }
            }
        }
    }
    
    private func initDaysFromCKRecord(_ record: CKRecord) {
        days = [Day]()
        for name in dayNames {
            if let string = record[name.lowercased()] as? String {
                let separatedString = string.components(separatedBy: "-")
                let fromStringSeparated = separatedString[0].components(separatedBy: ":")
                let toStringSeparated = separatedString[1].components(separatedBy: ":")
                guard let _fromHours = Int(fromStringSeparated[0]), let _fromMinutes = Int(fromStringSeparated[1]),
                    let _toHours = Int(toStringSeparated[0]), let _toMinutes = Int(toStringSeparated[1])
                    else {
                        return
                }
                
                let fromTime = Time.init(minutes: _fromHours * 60 + _fromMinutes)
                let toTime = Time.init(minutes: _toHours * 60 + _toMinutes)
                
                
                days.append(Day.init(day: name, from: fromTime, to: toTime))
            } else {
                
                days.append(Day.init(day: name))
                
            }
        }
    }
    
    enum Open {
        case open
        case closed
        case unknown
    }
    
    func isOpen() -> Open {
        let date = Date()
        let calendar = Calendar.current
        let day = getCurrentDay()
        let minutes = calendar.component(.minute, from: date) + calendar.component(.hour, from: date) * 60
        
        let currentDay = days[day]
        
        if checkIfTimeIsUnknown() {
            return .unknown
        }
        
        if let from = currentDay.from?.interval, let to = currentDay.to?.interval {
            if from == 0, to == 0 {
                // Open whole day
                return .open
            }
            
            if minutes >= from, minutes <= to {
                return .open
            }
            
            if from >= to, minutes > from {
                return .open
            }
        }
        
        return checkDayBefore(day: day, minutes: minutes)
    }
    
    private func checkIfTimeIsUnknown() -> Bool {
        var cnt = 0
        for day in days {
            if day.full == nil {
                cnt += 1
            }
        }
        if cnt == days.count {
            return true
        }
        return false
    }
    
    private func checkDayBefore(day: Int, minutes: Int) -> Open {
        var dayBeforeIndex = day - 1
        
        if dayBeforeIndex == -1 {
            // Monday <- Sunday
            dayBeforeIndex = 7
        }
        
        let dayBefore = days[dayBeforeIndex]
        guard let from = dayBefore.from?.interval, let to = dayBefore.to?.interval else { return .closed }
        if to <= from {
            if minutes < to {
                return .open
            }
        }
        
        
        return .closed
    }
    
    private func getCurrentDay() -> Int {
        let date = Date()
        let calendar = Calendar.current
        
        let day = calendar.component(.weekday, from: date)
        if day == 1 {
            return 6
        }
        
        return day - 2
    }
}
