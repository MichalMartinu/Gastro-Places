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
    func searchContextLoadedPlace(error: Error?)
}

class SearchContext: Operation {
    
    private(set) var places = [PlaceContext]()
    
    var delegate: SearchContextDelegate?
    
    func fetchCloudkitPlaces(stringToMatch: String?) {
        
        let container = CKContainer.default()
        let publicDB = container.publicCloudDatabase
        
        // When there is no string fetch all places
        var predicate = NSPredicate(value: true)
        
        if let _stringToMatch = stringToMatch {
            // Predicete to match string set by user
            predicate = NSPredicate(format: "self CONTAINS %@", _stringToMatch)
        }
        
        let query = CKQuery(recordType: PlaceCKRecordNames.record, predicate: predicate)
        
        query.sortDescriptors = [] // Init array for sort descriptors
        
        if let _location = CustomLocationManager.manager.location {
            query.sortDescriptors?.append(CKLocationSortDescriptor(key: "location", relativeLocation: _location))
        }
        
        query.sortDescriptors?.append(NSSortDescriptor(key: "name", ascending: true))

        
        let queryOperation = CKQueryOperation(query: query)
        
        // Prioritize operation
        queryOperation.qualityOfService = .userInteractive
        queryOperation.queuePriority = .veryHigh
        
        var records = [CKRecord]() // Array of fetched records
        
        queryOperation.recordFetchedBlock = { record in
            records.append(record)
        }
        
        queryOperation.queryCompletionBlock = { cursor, error in
            
            if let _error = error {
                self.state = .Failed
                
                DispatchQueue.main.async {
                    self.delegate?.searchContextLoadedPlace(error: _error)
                }
                
                return
            }
            
            // Fetched records will be saved to CoreData
            self.saveRecords(records: records)
        }
        
        publicDB.add(queryOperation)
    }
    
    private func saveRecords(records: [CKRecord]) {
        
        // Process records individualy
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
            
            self.places.append(placeContext) // Append to places that will be shown
        }
        
        sortPlacesByDistance() // Custom sort by distance
        
        DispatchQueue.main.async {
            
            if self.state == .Canceled {
                self.state = .Finished
                return
            }
            
            let context = AppDelegate.viewContext
            
            // Save to CoreData
            PlaceCoreData.changeOrCreatePlaces(records: records, context: context)
            
            self.state = .Finished
            
            DispatchQueue.main.async {
                self.delegate?.searchContextLoadedPlace(error: nil)
            }
        }
    }
    
    func sortPlacesByDistance() {
        guard let _location = CustomLocationManager.manager.location else { return }
        
        //Custom sort of places by dostance because CloudKit works only with range of 10 km
        places.sort(by: { $0.place.location!.distance(from: _location) < $1.place.location!.distance(from: _location) })
    }
    
    func deletePlace(with id: String) -> Int? {
        
        // Get index of place to delete
        if let placeIndex = places.firstIndex(where: { $0.place.placeID == id }) {
            
            places.remove(at: placeIndex)
            
            return placeIndex // Return deleted index
        }
        
        return nil
    }
    
    func changePlace(id: String, title: String, cathegory: String) -> Int? {
        
        // Get index of place to show
        if let placeIndex = places.firstIndex(where: { $0.place.placeID == id }) {
            
            places[placeIndex].place.name = title
            places[placeIndex].place.cathegory = cathegory

            return placeIndex // Return deleted index
        }
        
        return nil
    }
}
