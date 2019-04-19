//
//  OpeningTimeCoreData.swift
//  Gastro Places
//
//  Created by Michal Martinů on 14/03/2019.
//  Copyright © 2019 Michal Martinů. All rights reserved.
//

import Foundation
import CoreData
import CloudKit
import CoreLocation

class OpeningTimeCoreData: NSManagedObject{
    
    class func changeOrCreate(place: PlaceCoreData, record: CKRecord, context: NSManagedObjectContext) {
        
        var recordToSave: OpeningTimeCoreData?
        
        let query:NSFetchRequest<OpeningTimeCoreData> = OpeningTimeCoreData.fetchRequest()
        
        let predicate = NSPredicate(format: "place = %@", place)
        query.predicate = predicate
        
        if let _recordToSave = try? context.fetch(query), _recordToSave.count == 1 {
            // Found existing record (rewrite it)
            recordToSave = _recordToSave.first
        } else {
            // Create new record
            recordToSave = OpeningTimeCoreData(context: context)
        }
        
        recordToSave?.monday = record["monday"]
        recordToSave?.tuesday = record["tuesday"]
        recordToSave?.wednesday = record["wednesday"]
        recordToSave?.thursday = record["thursday"]
        recordToSave?.friday = record["friday"]
        recordToSave?.saturday = record["saturday"]
        recordToSave?.sunday = record["sunday"]
        
        place.openingTime = recordToSave
    }
    
    class func find(place: PlaceCoreData, context: NSManagedObjectContext) -> OpeningTimeCoreData? {
        let query:NSFetchRequest<OpeningTimeCoreData> = OpeningTimeCoreData.fetchRequest()
        
        let predicate = NSPredicate(format: "place = %@", place)
        query.predicate = predicate
                
        if let _records = try? context.fetch(query), _records.count == 1, let _record = _records.first {
            return _record
        }
        
        return nil
    }
}
