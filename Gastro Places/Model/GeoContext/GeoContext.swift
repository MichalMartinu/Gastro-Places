//
//  GeoContext.swift
//  Gastro Places
//
//  Created by Michal Martinů on 06/03/2019.
//  Copyright © 2019 Michal Martinů. All rights reserved.
//

import Foundation
import CoreLocation
import CloudKit
import MapKit

protocol GeoContextDelegate: AnyObject {
    func geoContextDidLoadAnnotations(error: Error?)
}

class GeoContext: Operation {
    
    private(set) var annotations = [PlaceAnnotation]() // Annotations that will be shown on map
    
    let location: CLLocation
    let radius: CLLocationDistance
    let cathegory: String
        
    weak var delegate: GeoContextDelegate?
    
    private static let geoContextQueue = DispatchQueue(label: "geoContextQueue", qos: .userInteractive, attributes: .concurrent)
    
    init(location: CLLocation, radius: CLLocationDistance, cathegory: String) {
        self.location = location
        self.radius = radius
        self.cathegory = cathegory
    }
    
    func appendAnnotation(_ annotation: PlaceAnnotation) {
        annotations.append(annotation)
    }
    
    func changeAnnotation(id: String, title: String, cathegory: String) -> PlaceAnnotation? {
        
        // Get index of annotation to change
        if let annotationIndex = annotations.firstIndex(where: { $0.id == id }) {
            
            let annotation = annotations[annotationIndex]
            
            annotation.title = title
            annotation.cathegory = cathegory
            
            return annotation // Return changed annotation
        }
        
        return nil
    }
    
    func deleteAnnotation(with id: String) -> PlaceAnnotation? {
        
        // Get index of annotation to delete
        if let annotationIndex = annotations.firstIndex(where: { $0.id == id }) {
            
            let annotation = annotations[annotationIndex]
            
            annotations.remove(at: annotationIndex)
            
            return annotation // Return deleted annotation
        }
        
        return nil
    }
    
    func start() {
        
        state = .Executing

        self.fetchCloudkitPlaces()
    }
    
    private func fetchCloudkitPlaces() {
        let container = CKContainer.default()
        let publicDB = container.publicCloudDatabase
        
        let predicate = createPredicateToFetchPlaces(location: location, radius: radius, cathegory: cathegory)
        let query = CKQuery(recordType: PlaceCKRecordNames.record, predicate: predicate)
        
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
                    self.delegate?.geoContextDidLoadAnnotations(error: _error)
                }
                
                return
            }
            
            // When there is something to fetch
            // Recursively call this function with cursor
            if let cursor = cursor {
                let newOperation = CKQueryOperation(cursor: cursor)
                
                queryOperation.qualityOfService = .userInteractive
                queryOperation.queuePriority = .veryHigh
                
                newOperation.recordFetchedBlock = queryOperation.recordFetchedBlock
                newOperation.queryCompletionBlock = queryOperation.queryCompletionBlock
                
                publicDB.add(newOperation)
                
                return
            }
            
            // Save fetched records to CoreData
            self.saveRecords(records: records)
        }
        
        publicDB.add(queryOperation)
    }
    
    private func saveRecords(records: [CKRecord]) {
        
        // Process each record individualy
        for record in records {
            
            if self.state == .Canceled {
                self.state = .Finished
                return
            }
            
            guard let name = record[PlaceCKRecordNames.name] as? String,
                let cathegory = record[PlaceCKRecordNames.cathegory] as? String,
                let placeLoacation = record[PlaceCKRecordNames.location] as? CLLocation else { continue }
            
            let placeAnnotationItem = PlaceAnnotation.init(title: name, cathegory: cathegory, id: record.recordID.recordName, coordinate: placeLoacation.coordinate)
            
            self.annotations.append(placeAnnotationItem)
        }
        
        DispatchQueue.main.async {
            if self.state == .Canceled {
                self.state = .Finished
                return
            }
            
            let context = AppDelegate.viewContext
            
            // Save to CoreData
            PlaceCoreData.changeOrCreatePlaces(records: records, context: context)
            
            self.state = .Finished
            
            self.delegate?.geoContextDidLoadAnnotations(error: nil)
        }
    }
    
    private func createPredicateToFetchPlaces(location: CLLocation, radius: CLLocationDistance, cathegory: String) ->  NSCompoundPredicate {
        
        // Predicate to fetch places in location defined location
        let locationPredicate = NSPredicate(format: "distanceToLocation:fromLocation:(location, %@) < %f",  location, Double(radius))
        
        // Default cathegory predicate used for search "all"
        var cathegoryPredicate = NSPredicate(value: true)
        
        if cathegory != "All" {
            cathegoryPredicate = NSPredicate(format: "\(PlaceCKRecordNames.cathegory) = %@", cathegory)
        }
        
        // Combine both predicates
        let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [locationPredicate, cathegoryPredicate])
        
        return predicate
    }

    func cancel() {
        state = .Canceled
    }
}



