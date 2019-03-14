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
    var openingTimeCKRecord: OpeningTimeCKRecord
    var place: Place
    
    weak var delegate: PlaceContextProtocol?
    
    private let container: CKContainer
    private let publicDB: CKDatabase
    
    init(place: Place, days: [Day]) {
        self.place = place
        placeCKRecord = PlaceCKRecord.init(place: place)
        openingTimeCKRecord = OpeningTimeCKRecord.init(days: days, id: placeCKRecord.recordID, record: placeCKRecord.record)
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
        records.append(openingTimeCKRecord.record)
        
        let saveOperation = CKModifyRecordsOperation(recordsToSave: records)
        saveOperation.savePolicy = .changedKeys
        saveOperation.modifyRecordsCompletionBlock = { (records, recordsID, error) in
            if let _records = records {
                DispatchQueue.main.async {
                    self.savePlacesToCoreData(records: _records)
                }
            }
            self.delegate?.placeSaved(place: self.place, error: error)
        }
        
        publicDB.add(saveOperation)
        
        state = .Finished
    }
    
    private func savePlacesToCoreData(records: [CKRecord]) {
        let context = AppDelegate.viewContext
        
        var placeCKRecord: CKRecord?
        var openingTimeRecord: CKRecord?
        
        var placeCoreData: PlaceCoreData?
        
        for record in records {
            if record.recordType == placeRecord.record {
                placeCKRecord = record
            }
            else if record.recordType == "OpeningTime" {
                openingTimeRecord = record
            }
        }
        
        if let _placeCKRecord = placeCKRecord, let _openingTimeRecord = openingTimeRecord {
            placeCoreData = PlaceCoreData.changeOrCreatePlace(record: _placeCKRecord, context: context)
            if let _placeCoreData = placeCoreData {
                OpeningTimeCoreData.changeOrCreate(place: _placeCoreData, record: _openingTimeRecord, context: context)
            }
        }
        
        try? context.save()
    }
}
