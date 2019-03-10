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
    var placeAnnotations = [PlaceAnnotation]()
    let location: CLLocation
    let radius: CLLocationDistance
    let cathegory: String
    
    let container: CKContainer
    let publicDB: CKDatabase
    
    weak var delegate: GeocontextOperations?
    
    init(location: CLLocation, radius: CLLocationDistance, cathegory: String) {
        self.location = location
        self.radius = radius
        self.cathegory = cathegory
        container = CKContainer.default()
        publicDB = container.publicCloudDatabase
    }
    
    override func main() {
        if isCancelled {
            state = .Finished
            return
        }
        fetchCloudKitPlaces(location: location, radius: radius, cathegory: cathegory)
    }
    
    func fetchCloudKitPlaces(location: CLLocation, radius: CLLocationDistance, cathegory: String) {
        let predicate = createPredicateToFetchPlaces(location: location, radius: radius, cathegory: cathegory)
        let query = CKQuery(recordType: placeRecord.record, predicate: predicate)
       
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

                guard let name = record[placeRecord.name] as? String, let cathegory = record[placeRecord.cathegory] as? String,
                    let placeLoacation = record[placeRecord.location] as? CLLocation else {
                        continue
                }
                
                let placeAnnotationItem = PlaceAnnotation.init(title: name, cathegory: cathegory, coordinate: placeLoacation.coordinate)
                self.placeAnnotations.append(placeAnnotationItem)
                
                DispatchQueue.main.async {
                    self.savePlaceToCoreData(record: record)
                }
            }
            
            self.state = .Finished
            self.delegate?.finishedLoadingData(placeAnnotation: self.placeAnnotations, error: nil)
        }
    }
    
    func createPredicateToFetchPlaces(location: CLLocation, radius: CLLocationDistance, cathegory: String) ->  NSCompoundPredicate {
        
        let locationPredicate = NSPredicate(format: "distanceToLocation:fromLocation:(\(placeRecord.location), %@) < %f",  location, Double(radius))
        var cathegoryPredicate = NSPredicate(value: true)
        
        if cathegory != "All" {
            cathegoryPredicate = NSPredicate(format: "\(placeRecord.cathegory) = %@", cathegory)
        }
        
        let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [locationPredicate, cathegoryPredicate])
        return predicate
    }
    
    func savePlaceToCoreData(record: CKRecord) {
        //TODO: save
    }
}

