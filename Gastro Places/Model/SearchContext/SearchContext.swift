//
//  SearchContext.swift
//  Gastro Places
//
//  Created by Michal Martinů on 19/04/2019.
//  Copyright © 2019 Michal Martinů. All rights reserved.
//

import Foundation
import CloudKit
import CoreData
import CoreLocation

protocol SearchContextDelegate: AnyObject {
    func searchContextLoadedPlace()
}

class SearchContext: Operation {
    private(set) var places = [PlaceContext]()
    
    var delegate: SearchContextDelegate?
    
    func fetchCloudkitPlaces(stringToMatch: String) {
        let container = CKContainer.default()
        let publicDB = container.publicCloudDatabase
        
        let predicate = NSPredicate(format: "self CONTAINS %@", "brno")
        let query = CKQuery(recordType: PlaceCKRecordNames.record, predicate: predicate)
        query.sortDescriptors = []
        if let _location = CustomLocationManager.manager.location {
            query.sortDescriptors?.append(CKLocationSortDescriptor(key: "location", relativeLocation: _location))
        }
        query.sortDescriptors?.append(NSSortDescriptor(key: "name", ascending: true))

        
        let queryOperation = CKQueryOperation(query: query)
        queryOperation.qualityOfService = .userInteractive
        queryOperation.queuePriority = .veryHigh
        
        var records = [CKRecord]()
        
        queryOperation.recordFetchedBlock = { record in
            records.append(record)
        }
        
        queryOperation.queryCompletionBlock = { cursor, error in
            if let _error = error {
                self.state = .Failed
                print(_error)
                DispatchQueue.main.async {
                }
                
                return
            }
            
            
            
           self.saveRecords(records: records)
        }
        publicDB.add(queryOperation)
    }
    
    private func saveRecords(records: [CKRecord]) {
        for record in records {
            if self.state == .Canceled {
                self.state = .Finished
                return
            }
            
            guard let name = record[PlaceCKRecordNames.name] as? String,
                let cathegory = record[PlaceCKRecordNames.cathegory] as? String,
                let placeLoacation = record[PlaceCKRecordNames.location] as? CLLocation else { continue }
            
            
            let placeAnnotationItem = PlaceAnnotation.init(title: name, cathegory: cathegory, id: record.recordID.recordName, coordinate: placeLoacation.coordinate)
            let placeContext = PlaceContext.init(annotation: placeAnnotationItem)
            
            self.places.append(placeContext)
        }
        
        sortPlacesByDistance()
        
        DispatchQueue.main.async {
            if self.state == .Canceled {
                self.state = .Finished
                return
            }
            
            let context = AppDelegate.viewContext
            
            PlaceCoreData.changeOrCreatePlaces(records: records, context: context) // Save to CoreData
            
            self.state = .Finished
            
            DispatchQueue.main.async {
                self.delegate?.searchContextLoadedPlace()
            }
        }
    }
    
    func sortPlacesByDistance() {
        guard let _location = CustomLocationManager.manager.location else { return }
        
        //Custom sort of places because CloudKit works only with range of 10km
        places.sort(by: { $0.place.location!.distance(from: _location) < $1.place.location!.distance(from: _location) })
    }
}
