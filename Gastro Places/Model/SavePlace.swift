//
//  SavePlace.swift
//  Gastro Places
//
//  Created by Michal Martinů on 11/03/2019.
//  Copyright © 2019 Michal Martinů. All rights reserved.
//

import Foundation
import CloudKit

class SavePlace: AsyncOperation {
    
    var placeCKRecord: PlaceCKRecord
    var place: Place
    
    weak var delegate: PlaceContextProtocol?
    
    private let container: CKContainer
    private let publicDB: CKDatabase
    
    init(place: Place) {
        self.place = place
        placeCKRecord = PlaceCKRecord.init(place: place)
        container = CKContainer.default()
        publicDB = container.publicCloudDatabase
    }
    
    override func main() {
        if isCancelled {
            state = .Finished
            return
        }
        saveToCloudkit(placeCKRecord: placeCKRecord)
    }
    
    func saveToCloudkit(placeCKRecord: PlaceCKRecord) {
        var records = [CKRecord]()
        
        records.append(placeCKRecord.record)
        
        let saveOperation = CKModifyRecordsOperation(recordsToSave: records)
        saveOperation.savePolicy = .changedKeys
        saveOperation.modifyRecordsCompletionBlock = { (records, recordsID, error) in
            self.delegate?.placeSaved(place: self.place, error: error)
        }
        
        publicDB.add(saveOperation)
        
        state = .Finished
    }
}
