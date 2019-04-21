//
//  ReviewsContext.swift
//  Gastro Places
//
//  Created by Michal Martinů on 02/04/2019.
//  Copyright © 2019 Michal Martinů. All rights reserved.
//

import Foundation
import CloudKit

protocol ReviewsContextDelegate: AnyObject {
    func fetchedMyReviews()
}

protocol ReviewsContextSaveDelegate: AnyObject {
    func reviewSaved(error: Error?)
}

protocol ReviewsContextDeleteDelegate: AnyObject {
    func reviewDeleted(error: Error?)
}


class ReviewsContext {
    
    var reviews = [Review]()
    var currentUserReview: Review? // Review created by user which is using aplication
    
    var hasUserReview: Bool {
        if currentUserReview == nil { return false }
        return true
    }
    
    var count: Int {
        var count = reviews.count
        
        if currentUserReview != nil {
            count += 1
        }
        
        return count
    }
    
    var rating: Double {
        if count == 0 {
            return 0
        }
        
        var sumRating = 0.0
        
        for review in reviews {
            sumRating += Double(review.rating)
        }
        
        if let review = currentUserReview {
            sumRating += Double(review.rating)
        }
        
        return sumRating/Double(count)
    }
    
    weak var delegate: ReviewsContextDelegate?
    weak var delegateSave: ReviewsContextSaveDelegate?
    weak var delegateDelete: ReviewsContextDeleteDelegate?
    
    func fetchReviews(placeID: String, place: PlaceCoreData) {
        
        let context = AppDelegate.viewContext
        
        // Check if local cache of review is available
        if let reviewsSaved = ReviewCoreData.findSaved(placeCoreData: place, context: context) {
            for review in reviewsSaved {
                
                // Check if review was by user which is using aplication
                if review.user == "__defaultOwner__" {
                     self.currentUserReview = review
                } else {
                    self.reviews.append(review)
                }
            }
            
            self.delegate?.fetchedMyReviews()
        } else {
            self.fetchFromCloudkit(placeID: placeID, place: place)
        }
    }
    
    func changeCurrentUserReview(with review: Review) {
        self.currentUserReview = review
    }
    
    private func fetchFromCloudkit(placeID: String, place: PlaceCoreData?) {
        let container = CKContainer.default()
        let publicDB = container.publicCloudDatabase
        
        let recordID = CKRecord.ID(recordName: placeID)
        let recordToMatch = CKRecord.Reference(recordID: recordID, action: .deleteSelf)
        
        let predicate = NSPredicate(format: "place == %@", recordToMatch)
        
        let query = CKQuery(recordType: "Review", predicate: predicate)
        
        query.sortDescriptors = [NSSortDescriptor(key: "modificationDate", ascending: false)]
        
        let queryOperation = CKQueryOperation(query: query)
        
        queryOperation.qualityOfService = .userInteractive
        queryOperation.queuePriority = .veryHigh
        
        queryOperation.recordFetchedBlock = { record in
            
            // Create review from record
            let review = Review(date: record.creationDate!, rating: record["rating"]!, text: record["text"], user: record.creatorUserRecordID?.recordName, cloudID: record.recordID)
            
            DispatchQueue.main.async {
                let context = AppDelegate.viewContext
                
                guard let _place = place else  { return }
                
                // Save review to CoreData
                ReviewCoreData.changeOrCreate(place: _place, record: record, context: context)
            }
            
            // Check if review was by user which is using aplication
            if record.creatorUserRecordID?.recordName == "__defaultOwner__" {
                self.currentUserReview = review
            } else {
                self.reviews.append(review)
            }
        }
        
        queryOperation.queryCompletionBlock = { results, error in
            
            DispatchQueue.main.async {
                self.delegate?.fetchedMyReviews()
            }
        }
        
        publicDB.add(queryOperation)
    }
    
    func saveToCloudkit(review: Review, place: PlaceCoreData) {
        let container = CKContainer.default()
        let publicDB = container.publicCloudDatabase
        
        var reviewRecordID: CKRecord.ID? = nil
        
        if let id = currentUserReview?.cloudID {
            reviewRecordID = id
        }
     
        let reviewCKRecord = ReviewCKRecord(review: review, placeID: place.placeID!, reviewRecordID: reviewRecordID)
        
        let saveOperation = CKModifyRecordsOperation(recordsToSave: [reviewCKRecord.record])
        
        saveOperation.savePolicy = .changedKeys
        saveOperation.queuePriority = .veryHigh
        saveOperation.qualityOfService = .userInteractive
        
        saveOperation.modifyRecordsCompletionBlock = { (records, recordsID, error) in
            
            if let _error = error {
                DispatchQueue.main.async {
                    self.delegateSave?.reviewSaved(error: _error)
                }
                return
            }
            
            guard let record = records?.first else { return }
            
            self.currentUserReview = Review(date: record.creationDate!, rating: record["rating"]!, text: record["text"], user: record.creatorUserRecordID?.recordName, cloudID: record.recordID)
            
            DispatchQueue.main.async {
                let context = AppDelegate.viewContext
                ReviewCoreData.changeOrCreate(place: place, record: record, context: context)

                self.delegateSave?.reviewSaved(error: nil)
            }
        }
        
        publicDB.add(saveOperation)
    }
    
    func deleteUserReview() {
        guard let id = currentUserReview?.cloudID else { return }
        
        let container = CKContainer.default()
        let publicDB = container.publicCloudDatabase
        
        publicDB.delete(withRecordID: id) { (recordID, error) in
            if error != nil {
                DispatchQueue.main.async {
                    self.delegateDelete?.reviewDeleted(error: error)
                }
                return
            }
            
            DispatchQueue.main.async {
                let context = AppDelegate.viewContext
                
                // Delete user from CoreData
                ReviewCoreData.deleteCurrentUser(context: context)
                
                self.currentUserReview = nil
                
                self.delegateDelete?.reviewDeleted(error: nil)
            }
        }
    }
}
