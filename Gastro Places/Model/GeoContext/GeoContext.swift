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

enum GeoContextState {
    case Ready, Executing, Finished, Failed, Canceled
}

protocol GeoContextDelegate: AnyObject {
    func geoContextDidLoadAnnotations(error: Error?)
}

class GeoContext {
    
    private(set) var annotations = [PlaceAnnotation]()
    private(set) var state = GeoContextState.Ready
    
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
    
    func deleteAnnotation(with id: String) {
        if let annotationIndex = annotations.index(where: { $0.id == id }) {
            annotations.remove(at: annotationIndex)
        }
    }
    
    func start() {
        state = .Executing
        GeoContext.geoContextQueue.async {
            self.fetchCloudkitPlaces()
        }
    }
    
    private func fetchCloudkitPlaces() {
        let container = CKContainer.default()
        let publicDB = container.publicCloudDatabase
        
        let predicate = createPredicateToFetchPlaces(location: location, radius: radius, cathegory: cathegory)
        let query = CKQuery(recordType: PlaceCKRecordNames.record, predicate: predicate)
        
        publicDB.perform(query, inZoneWith: nil) { results, error in
            if let _error = error {
                self.state = .Failed
                DispatchQueue.main.async {
                    self.delegate?.geoContextDidLoadAnnotations(error: _error)
                }
                return
            }
            
            guard let records = results else {
                self.delegate?.geoContextDidLoadAnnotations(error: error)
                return
            }
            
            self.saveRecords(records: records)
        }
    }
    
    private func saveRecords(records: [CKRecord]) {
        for record in records {
            if self.state == .Canceled {
                self.state = .Finished
                return
            }
            
            guard let name = record[PlaceCKRecordNames.name] as? String, let cathegory = record[PlaceCKRecordNames.cathegory] as? String,
                let placeLoacation = record[PlaceCKRecordNames.location] as? CLLocation else {
                    continue
            }
            
            let placeAnnotationItem = PlaceAnnotation.init(title: name, cathegory: cathegory, id: record.recordID.recordName, coordinate: placeLoacation.coordinate)
            self.annotations.append(placeAnnotationItem)
        }
        
        DispatchQueue.main.async {
            if self.state == .Canceled {
                self.state = .Finished
                return
            }
            
            let context = AppDelegate.viewContext
            
            PlaceCoreData.changeOrCreatePlaces(records: records, context: context)
            
            try? context.save()

            self.state = .Finished
            self.delegate?.geoContextDidLoadAnnotations(error: nil)
        }
    }
    
    private func createPredicateToFetchPlaces(location: CLLocation, radius: CLLocationDistance, cathegory: String) ->  NSCompoundPredicate {
        let locationPredicate = NSPredicate(format: "distanceToLocation:fromLocation:(location, %@) < %f",  location, Double(radius))
        var cathegoryPredicate = NSPredicate(value: true)
        
        if cathegory != "All" {
            cathegoryPredicate = NSPredicate(format: "\(PlaceCKRecordNames.cathegory) = %@", cathegory)
        }
        
        let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [locationPredicate, cathegoryPredicate])
        return predicate
    }

    func cancel() {
        state = .Canceled
    }
}



