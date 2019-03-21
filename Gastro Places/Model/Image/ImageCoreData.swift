//
//  ImageCoreData.swift
//  Gastro Places
//
//  Created by Michal Martinů on 21/03/2019.
//  Copyright © 2019 Michal Martinů. All rights reserved.
//

import Foundation
import CoreData
import CloudKit

class ImageCoreData: NSManagedObject{
    
    class func changeOrCreate(place: PlaceCoreData, record: CKRecord, context: NSManagedObjectContext) {
        var recordToSave: ImageCoreData?
        
        let query:NSFetchRequest<ImageCoreData> = ImageCoreData.fetchRequest()
        
        let predicate = NSPredicate(format: "place = %@", place)
        query.predicate = predicate
        
        if let _recordToSave = try? context.fetch(query), _recordToSave.count == 1 {
            recordToSave = _recordToSave.first
        } else {
            recordToSave = ImageCoreData(context: context)
        }
        
        recordToSave?.imageID = record.recordID.recordName
        recordToSave?.picture = record["picture"]
        
        place.image = recordToSave
    }
}
