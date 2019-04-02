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
    func userFetched()
}

class ReviewsContext {
    var reviews = [Review]()
    var currentUserReview: Review?
    var currentUser: CKRecord.ID?
    
    var hasUserReview = false
    
    weak var delegate: ReviewsContextDelegate?
    
    func fetchCurrentUser() {
        let container = CKContainer.default()
        container.fetchUserRecordID { (recordID, error) in
            //TODO error
            
            self.currentUser = recordID
            DispatchQueue.main.async {
                self.delegate?.userFetched()
            }
        }
    }
    
    func fetchReviews(placeID: String) {
        let container = CKContainer.default()
        let publicDB = container.publicCloudDatabase
        
        let recordID = CKRecord.ID(recordName: placeID)
        let recordToMatch = CKRecord.Reference(recordID: recordID, action: .deleteSelf)
        
        let predicate = NSPredicate(format: "place == %@", recordToMatch)
        let query = CKQuery(recordType: "Review", predicate: predicate)
        
        let queryOperation = CKQueryOperation(query: query)
        queryOperation.qualityOfService = .userInteractive
        
        queryOperation.recordFetchedBlock = { record in
            let review = Review(date: record.creationDate!, rating: record["rating"]!, text: record["text"])
            
            if record.creatorUserRecordID == self.currentUser {
                self.currentUserReview = review
                self.hasUserReview = true
            } else {
                self.reviews.append(review)
            }
        }
        
        queryOperation.queryCompletionBlock = { results, error in
            
            if error != nil {
                // TODO
                return
            }
            
            DispatchQueue.main.async {
                self.delegate?.fetchedMyReviews()
            }
        }
        
        publicDB.add(queryOperation)
    }
    
    func saveToCloudkit(review: Review, placeID: String, reviewRecordID: String?) {
        let container = CKContainer.default()
        let publicDB = container.publicCloudDatabase
     
        let reviewCKRecord = ReviewCKRecord(review: review, placeID: placeID, reviewRecordID: reviewRecordID)
        
        let saveOperation = CKModifyRecordsOperation(recordsToSave: [reviewCKRecord.record])
        saveOperation.savePolicy = .changedKeys
        saveOperation.modifyRecordsCompletionBlock = { (records, recordsID, error) in
            
            if let _error = error {
                DispatchQueue.main.async {
                    //self.delegateSave?.placeContextSaved(annotation: nil, error: _error)
                }
                return
            }
            
            DispatchQueue.main.async {
                //
            }
        }
        
        publicDB.add(saveOperation)
    }
}
