//
//  ImageCoreData.swift
//  Gastro Places
//
//  Created by Michal Martinů on 21/03/2019.
//  Copyright © 2019 Michal Martinů. All rights reserved.
//

import UIKit
import CoreData
import CloudKit

class ImageCoreData: NSManagedObject {
    
    class func changeOrCreate(place: PlaceCoreData, record: CKRecord, context: NSManagedObjectContext) {
        var recordToSave: ImageCoreData?
        
        let query:NSFetchRequest<ImageCoreData> = ImageCoreData.fetchRequest()
        
        let id = record.recordID.recordName
        
        let predicate = NSPredicate(format: "imageID = %@", id)
        query.predicate = predicate
        
        if let _recordToSave = try? context.fetch(query), _recordToSave.count == 1 {
            recordToSave = _recordToSave.first
        } else {
            recordToSave = ImageCoreData(context: context)
        }
        
        recordToSave?.imageID = id
        guard let asset = record["picture"] as? CKAsset, let url = asset.fileURL,let data = try? Data(contentsOf: url) else {
            return
        }
        
        recordToSave?.picture = data
        recordToSave?.creationDate = record.creationDate
        
        place.addToImage(recordToSave!)
    }
    
    class func find(id: String, context: NSManagedObjectContext) -> UIImage? {
        
        let query:NSFetchRequest<ImageCoreData> = ImageCoreData.fetchRequest()
        
        let predicate = NSPredicate(format: "imageID = %@", id)
        query.predicate = predicate
        
        if let record = try? context.fetch(query) {
            guard let data = record.first?.picture else { return nil }
            return UIImage(data: data, scale: 1.0)
        } else {
            return nil
        }
    }
    
    class func findSavedIDs(placeCoreData: PlaceCoreData, context: NSManagedObjectContext) -> [String]? {
        
        let query:NSFetchRequest<ImageCoreData> = ImageCoreData.fetchRequest()
        
        let predicate = NSPredicate(format: "place = %@", placeCoreData)
        query.predicate = predicate
       
        query.sortDescriptors = [] // Start with empty array
        query.sortDescriptors?.append(NSSortDescriptor(key: "creationDate", ascending: true))
        query.sortDescriptors?.append(NSSortDescriptor(key: "imageID", ascending: true))
        
        if let records = try? context.fetch(query), records.count > 0 {
            var imageIDs = [String]()
        
            for record in records {
                imageIDs.append(record.imageID!)
            }
            return imageIDs
        } else {
            return nil
        }
    }
    
    class func saveID(imageID: String, creationDate: Date, placeID: String, context: NSManagedObjectContext) {
        
        let queryPlace:NSFetchRequest<PlaceCoreData> = PlaceCoreData.fetchRequest()
        let predicatePlace = NSPredicate(format: "placeID = %@", placeID)
        queryPlace.predicate = predicatePlace
        
        if let placeRecords = try? context.fetch(queryPlace), placeRecords.count == 1, let placeRecord = placeRecords.first {
            let imageRecord = ImageCoreData(context: context)
            
            imageRecord.imageID = imageID
            imageRecord.creationDate = creationDate
            
            placeRecord.addToImage(imageRecord)
        } else {
            return
        }
    }
    
    class func saveImage(imageID: String, data: Data, context: NSManagedObjectContext) {
        
        let queryImage:NSFetchRequest<ImageCoreData> = ImageCoreData.fetchRequest()
        
        let predicateImage = NSPredicate(format: "imageID = %@", imageID)
        queryImage.predicate = predicateImage
        
        if let record = try? context.fetch(queryImage), record.count == 1 {
            record.first?.picture = data
        } else {
            return
        }
    }
}
