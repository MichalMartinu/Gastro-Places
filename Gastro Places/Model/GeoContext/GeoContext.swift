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

class GeoContext {
    
    var annotations = [PlaceAnnotation]()
    var state = GeoContextState.Ready
    
    let location: CLLocation
    let radius: CLLocationDistance
    let cathegory: String
    
    private let container: CKContainer
    private let publicDB: CKDatabase
    
    weak var delegate: GeoContextDelegate?
    
    static let geoContextQueue = DispatchQueue(label: "geoContextQueue", qos: .utility, attributes: .concurrent)
    
    init(location: CLLocation, radius: CLLocationDistance, cathegory: String) {
        self.location = location
        self.radius = radius
        self.cathegory = cathegory
        container = CKContainer.default()
        publicDB = container.publicCloudDatabase
    }
    
    func start() {
        state = .Executing
        GeoContext.geoContextQueue.async {
            self.fetchCloudkitPlaces()
        }
    }
    
    func fetchCloudkitPlaces() {
        let predicate = createPredicateToFetchPlaces(location: location, radius: radius, cathegory: cathegory)
        let query = CKQuery(recordType: placeRecord.record, predicate: predicate)
        
        publicDB.perform(query, inZoneWith: nil) { results, error in
            if error != nil {
                self.state = .Failed
                return
            }
            
            guard let records = results else {
                return
            }
            
            self.saveRecords(records: records)
            
            if self.state == .Canceled {
                self.state = .Finished
                return
            }
            
            self.state = .Finished
            DispatchQueue.main.async {
                self.delegate?.geoContextDidLoadAnnotations()
            }
        }
    }
    
    private func saveRecords(records: [CKRecord]) {
        for record in records {
            if self.state == .Canceled {
                self.state = .Finished
                return
            }
            
            guard let name = record[placeRecord.name] as? String, let cathegory = record[placeRecord.cathegory] as? String,
                let placeLoacation = record[placeRecord.location] as? CLLocation else {
                    continue
            }
            
            let placeAnnotationItem = PlaceAnnotation.init(title: name, cathegory: cathegory, coordinate: placeLoacation.coordinate)
            self.annotations.append(placeAnnotationItem)
            
            DispatchQueue.main.async {
                let savedPlace = self.savePlaceToCoreData(record: record)
                GeoContext.geoContextQueue.async {
                    self.fetchOpeningHours(place: savedPlace, record: record)
                }
            }
        }
    }
    
    private func createPredicateToFetchPlaces(location: CLLocation, radius: CLLocationDistance, cathegory: String) ->  NSCompoundPredicate {
        let locationPredicate = NSPredicate(format: "distanceToLocation:fromLocation:(location, %@) < %f",  location, Double(radius))
        var cathegoryPredicate = NSPredicate(value: true)
        
        if cathegory != "All" {
            cathegoryPredicate = NSPredicate(format: "\(placeRecord.cathegory) = %@", cathegory)
        }
        
        let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [locationPredicate, cathegoryPredicate])
        return predicate
    }
    
    private func fetchOpeningHours(place: PlaceCoreData?, record: CKRecord) {
        let recordID = record.recordID
        let recordToMatch = CKRecord.Reference(recordID: recordID, action: .deleteSelf)
        let predicate = NSPredicate(format: "place == %@", recordToMatch)
        let query = CKQuery(recordType: "OpeningTime", predicate: predicate)
        publicDB.perform(query, inZoneWith: nil) { results, error in
            
            if error != nil {
                return
            }
            
            if results?.count == 1, let _result = results?.first {
                DispatchQueue.main.async {
                    self.saveOpeningTimeToCoreData(place: place, record: _result)
                }
            }
        }
    }
    
    private func savePlaceToCoreData(record: CKRecord) -> PlaceCoreData? {
        let context = AppDelegate.viewContext
        let place = PlaceCoreData.changeOrCreatePlace(record: record, context: context)
        try? context.save()
        return place
    }
    
    private func saveOpeningTimeToCoreData(place: PlaceCoreData?, record: CKRecord) {
        let context = AppDelegate.viewContext
        if let _place = place {
            OpeningTimeCoreData.changeOrCreate(place: _place, record: record, context: context)
        }
        try? context.save()
    }
    
    func cancel() {
        state = .Canceled
    }
}



