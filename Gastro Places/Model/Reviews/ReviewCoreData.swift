//
//  ReviewCoreData.swift
//  Gastro Places
//
//  Created by Michal Martinů on 15/04/2019.
//  Copyright © 2019 Michal Martinů. All rights reserved.
//

import Foundation
import CoreData
import CloudKit

class ReviewCoreData: NSManagedObject {
    
    class func changeOrCreate(place: PlaceCoreData, record: CKRecord, context: NSManagedObjectContext) {
        
        let query:NSFetchRequest<ReviewCoreData> = ReviewCoreData.fetchRequest()
        
        let predicate = NSPredicate(format: "place = %@", place)
        query.predicate = predicate
        
        let recordToSave = ReviewCoreData(context: context)
        
        recordToSave.user = record.creatorUserRecordID?.recordName
        recordToSave.rating = record["rating"] as? Int16 ?? 0
        recordToSave.text = record["text"] as? String
        recordToSave.modifiedDate = record.modificationDate
        
        place.addToReviews(recordToSave)
    }
    
    class func findSaved(placeCoreData: PlaceCoreData, context: NSManagedObjectContext) -> [Review]? {
        
        let query:NSFetchRequest<ReviewCoreData> = ReviewCoreData.fetchRequest()
        
        let predicate = NSPredicate(format: "place = %@", placeCoreData)
        query.predicate = predicate
        
        query.sortDescriptors = [] // Start with empty array
        query.sortDescriptors?.append(NSSortDescriptor(key: "modifiedDate", ascending: false))
        
        if let records = try? context.fetch(query), records.count > 0 {
            var reviews = [Review]()
            
            for record in records {
                let review = Review(date: record.modifiedDate!, rating: Int(record.rating), text: record.text, user: record.user, cloudID: nil)
                
                reviews.append(review)
            }
            return reviews
        } else {
            return nil
        }
    }
}
