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

protocol OpeningTimeDelegate: AnyObject {
    func openingTimeDidLoad()
}

enum Open {
    case open
    case closed
    case unknown
}

class OpeningTime: Operation {
    private var minuteInterval: Int
    
    private(set) var times = [Time]()
    
    private let dayNames = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
    
    var days = [Day]()
        
    private(set) var recordID: String?
    
    weak var delegate: OpeningTimeDelegate?
    
    private static let openingTimeQueue = DispatchQueue(label: "openingTimeQueue", qos: .userInteractive, attributes: .concurrent)
    
    var stringHours: String {
        var string = "" // String that will be returned
        
        for day in days {
            if let _from = day.from?.string, let _to = day.to?.string {
                
                if _from == "0:00", _to == "0:00" {
                    // When it is open all day
                    string += "nonstop\n"
                } else {
                    string += "\(_from)-\(_to)\n"
                }
            } else {
                // When there is no time record
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
    }
    
    func generateTime() {
        let sequence = stride(from: 0, to: 24 * 60, by: minuteInterval)
        
        for minutes in sequence {
            let time = Time.init(minutes: minutes)
            times.append(time)
        }
        
        // Add 0:00 to end
        let midnigth = Time.init(minutes: 0)
        times.append(midnigth)
    }
    
    func initDays() {
        for dayName in dayNames {
            days.append(Day.init(day: dayName))
        }
    }
    
    func setDay(indexPath: Int, from: Time?, to: Time?) {
        // When day is not initialized and day before is, set as day before
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
    
    func fetchOpeningHours(placeID: String, placeCoreData: PlaceCoreData?) {
        state = .Executing
        
        //Check if opening data are saved in CoreData
        let context = AppDelegate.viewContext
        
        guard let _placeCoreData = placeCoreData else { return }
        
        if let record = OpeningTimeCoreData.find(place: _placeCoreData, context: context) {
            // Convert CoreData record to CKRecord
            let convertedRecord = OpeningTimeCKRecord.init(openingTimeCoreData: record)
            
            initDaysFromCKRecord(convertedRecord.record)
            
            DispatchQueue.main.async {
                self.state = .Finished
                self.delegate?.openingTimeDidLoad()
            }
            
            return
        }
        
        initDays() // Default value before days are fetched
        
        OpeningTime.openingTimeQueue.async {
            self.gtFetchOpeningHours(placeID: placeID, placeCoreData: _placeCoreData)
        }
    }
    
    private func gtFetchOpeningHours(placeID: String, placeCoreData: PlaceCoreData) {
        let container = CKContainer.default()
        let publicDB = container.publicCloudDatabase
        
        let recordID = CKRecord.ID(recordName: placeID)
        let recordToMatch = CKRecord.Reference(recordID: recordID, action: .deleteSelf)
        
        let predicate = NSPredicate(format: "place == %@", recordToMatch)
        let query = CKQuery(recordType: "OpeningTime", predicate: predicate)
        
        let queryOperation = CKQueryOperation(query: query)
        queryOperation.qualityOfService = .userInteractive
        
        queryOperation.recordFetchedBlock = { (record) in
            self.initDaysFromCKRecord(record)
            
            DispatchQueue.main.async {
                let context = AppDelegate.viewContext
                
                // Save to CoreData
                OpeningTimeCoreData.changeOrCreate(place: placeCoreData, record: record, context: context)
                
                self.recordID =  record.recordID.recordName
                
                self.state = .Finished
                self.delegate?.openingTimeDidLoad()
            }
        }
        
        publicDB.add(queryOperation)
    }
    
    private func initDaysFromCKRecord(_ record: CKRecord) {
        days = [Day]()
        
        for name in dayNames {
            
            if let string = record[name.lowercased()] as? String {
                
                let separatedString = string.components(separatedBy: "-") // Separate from and to times
                
                let fromStringSeparated = separatedString[0].components(separatedBy: ":")
                let toStringSeparated = separatedString[1].components(separatedBy: ":")
                
                // Get from and to time minutes
                guard let _fromHours = Int(fromStringSeparated[0]), let _fromMinutes = Int(fromStringSeparated[1]),
                    let _toHours = Int(toStringSeparated[0]), let _toMinutes = Int(toStringSeparated[1]) else { return }
                
                let fromTime = Time.init(minutes: _fromHours * 60 + _fromMinutes)
                let toTime = Time.init(minutes: _toHours * 60 + _toMinutes)
                
                days.append(Day.init(day: name, from: fromTime, to: toTime))
            } else {
                // There was not time
                days.append(Day.init(day: name))
            }
        }
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
                // Standart opening
                return .open
            }
            
            if from >= to, minutes > from {
                // Opening which covers another day
                return .open
            }
        }
        
        return checkDayBefore(day: day, minutes: minutes)
    }
    
    private func checkIfTimeIsUnknown() -> Bool {
        // When there are no days
        
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
        
        if dayBeforeIndex < 0 {
            // Monday <- Sunday
            dayBeforeIndex = 6
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
            // When it is Sunday, convert to application notation
            return 6
        }
        
        return day - 2
    }
}
