//
//  PlaceCoreData.swift
//  Gastro Places
//
//  Created by Michal Martinů on 11/03/2019.
//  Copyright © 2019 Michal Martinů. All rights reserved.
//

import Foundation
import CoreData
import CloudKit
import CoreLocation

class PlaceCoreData: NSManagedObject{
    
    class func changeOrCreatePlaces(records: [CKRecord], context: NSManagedObjectContext) {
        for record in records {
            _ = PlaceCoreData.changeOrCreatePlace(record: record, context: context)
        }
    }

    class func changeOrCreatePlace(record: CKRecord, context: NSManagedObjectContext) -> PlaceCoreData? {
        var recordToSave: PlaceCoreData?
        
        let query:NSFetchRequest<PlaceCoreData> = PlaceCoreData.fetchRequest()
        let id = record.recordID.recordName
        
        let predicate = NSPredicate(format: "placeID = %@", id)
        query.predicate = predicate
        
        if let _recordToSave = try? context.fetch(query), _recordToSave.count == 1 {
            // Found existing record (rewrite it)
            recordToSave = _recordToSave.first
        } else {
            //Create new record
            recordToSave = PlaceCoreData(context: context)
        }
        
        let location = record[PlaceCKRecordNames.location] as! CLLocation
        
        recordToSave?.placeID = record.recordID.recordName
        recordToSave?.name = record[PlaceCKRecordNames.name]
        recordToSave?.cathegory = record[PlaceCKRecordNames.cathegory]
        recordToSave?.city = record[PlaceCKRecordNames.city]
        recordToSave?.street = record[PlaceCKRecordNames.street]
        recordToSave?.zipCode = record[PlaceCKRecordNames.zipCode]
        recordToSave?.email = record[PlaceCKRecordNames.email]
        recordToSave?.web = record[PlaceCKRecordNames.web]
        recordToSave?.phone = record[PlaceCKRecordNames.phone]
        recordToSave?.longitude = location.coordinate.longitude
        recordToSave?.latitude = location.coordinate.latitude
        recordToSave?.userID = record.creatorUserRecordID?.recordName
        
        return recordToSave
    }
}
