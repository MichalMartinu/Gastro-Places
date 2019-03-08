//
//  FetchGeoContext.swift
//  Gastro Places
//
//  Created by Michal Martinů on 08/03/2019.
//  Copyright © 2019 Michal Martinů. All rights reserved.
//

import Foundation
import CoreLocation
import CloudKit
import CoreData

class FetchGeoContext: AsyncOperation {
    var placeAnnotations = [PlaceAnnotationItem]()
    let location: CLLocation
    let radius: CLLocationDistance
    
    let container: CKContainer
    let publicDB: CKDatabase
    
    weak var delegate: GeocontextOperations?
    
    init(location: CLLocation, radius: CLLocationDistance) {
        self.location = location
        self.radius = radius
        container = CKContainer.default()
        publicDB = container.publicCloudDatabase
    }
    
    override func main() {
        if isCancelled {
            state = .Finished
            return
        }
        fetchCloudKitPlaces()
    }
    
    func fetchCloudKitPlaces() {
        let locationPredicate = NSPredicate(format: "distanceToLocation:fromLocation:(location, %@) < %f",  location, radius)
        let query = CKQuery(recordType: "Place", predicate: locationPredicate)
        publicDB.perform(query, inZoneWith: nil) { results, error in
            if self.isCancelled {
                self.state = .Finished
                return
            }
            
            if let error = error {
                self.delegate?.finishedLoadingData(placeAnnotation: self.placeAnnotations, error: error)
                return
            }
            
            guard let records = results else {
                return
            }
            
            for record in records {
                if self.isCancelled {
                    self.state = .Finished
                    return
                }

                guard let name = record[placeRecordNames.name] as? String, let cathegory = record[placeRecordNames.cathegory] as? String,
                    let placeLoacation = record[placeRecordNames.location] as? CLLocation else {
                        continue
                }
                
                let placeAnnotationItem = PlaceAnnotationItem.init(name: name, cathegory: cathegory, location: placeLoacation)
                self.placeAnnotations.append(placeAnnotationItem)
                
                DispatchQueue.main.async {
                    self.savePlaceToCoreData(record: record)
                }
            }
            
            self.delegate?.finishedLoadingData(placeAnnotation: self.placeAnnotations, error: nil)
            self.state = .Finished
        }
    }
    
    func savePlaceToCoreData(record: CKRecord) {
        //TODO: save
    }
}

