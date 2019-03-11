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
    
    class func findOrCreatePlace(record: CKRecord, context: NSManagedObjectContext) {
        var recordToSave: PlaceCoreData?
        
        let query:NSFetchRequest<PlaceCoreData> = PlaceCoreData.fetchRequest()
        let id = record.recordID.recordName
        
        let predicate = NSPredicate(format: "placeID = %@", id)
        query.predicate = predicate
        
        if let _recordToSave = try? context.fetch(query), _recordToSave.count == 1 {
            recordToSave = _recordToSave.first
        } else {
            recordToSave = PlaceCoreData(context: context)
        }
        
        let location = record[placeRecord.location] as! CLLocation
        
        recordToSave?.placeID = record.recordID.recordName
        recordToSave?.name = record[placeRecord.name]
        recordToSave?.cathegory = record[placeRecord.cathegory]
        recordToSave?.city = record[placeRecord.city]
        recordToSave?.street = record[placeRecord.street]
        recordToSave?.zipCode = record[placeRecord.zipCode]
        recordToSave?.email = record[placeRecord.email]
        recordToSave?.web = record[placeRecord.web]
        recordToSave?.phone = record[placeRecord.phone]
        recordToSave?.longitude = location.coordinate.longitude
        recordToSave?.latitude = location.coordinate.latitude

    }
}
