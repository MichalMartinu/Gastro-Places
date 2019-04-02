//
//  CreatePlaceContext.swift
//  Gastro Places
//
//  Created by Michal Martinů on 08/03/2019.
//  Copyright © 2019 Michal Martinů. All rights reserved.
//

import Foundation
import CoreLocation
import CloudKit
import CoreData
import MapKit

protocol PlaceContextDelegateAdress: AnyObject {
    func placeContextDidDecodeAddress(address: String?, error: Error?)
}

protocol PlaceContextDelegateSave: AnyObject {
    func placeContextSaved(annotation: PlaceAnnotation?, error: Error?)
}

protocol PlaceContextDelegateLoad: AnyObject {
    func placeContextLoadedPlace()
}

enum InputTypes: String {
    case email = "email"
    case web = "web"
    case phone = "phone"
    case name = "name"
}

class PlaceContext: Operation {
    
    private(set) var place: Place
    
    weak var delegateSave: PlaceContextDelegateSave?
    weak var delegateLoad: PlaceContextDelegateLoad?
    weak var delegateAddress: PlaceContextDelegateAdress?
    
    private(set) var annotation: PlaceAnnotation
    
    private(set) var placeCoreData: PlaceCoreData?
        
    private static let placeContextQueue = DispatchQueue(label: "placeContextQueue", qos: .userInteractive, attributes: .concurrent)
    
    init(location: CLLocation) {
        // Used when creating new place
        self.annotation = PlaceAnnotation.init(title: "New place", cathegory: "", id: nil, coordinate: location.coordinate)
        place = Place(location: location)
    }
    
    init(annotation: PlaceAnnotation) {
        self.annotation = annotation
        place = Place.init(placeID: annotation.id!)
    }
    
    func changeData(cathegory: String, name: String, phone: String, email: String, web: String) {
        self.place.cathegory = cathegory
        self.place.name = name
        self.place.phone = phone
        self.place.email = email
        self.place.web = web
    }
    
    func cancel() {
        state = .Canceled
    }
    
    func getAddress() {
        state = .Executing
        
        PlaceContext.placeContextQueue.async {
            self.decodePlaceItemAddress()
        }
    }
    
    func save(openingTime: OpeningTime, images: ImageContext) {
        state = .Executing
        
        PlaceContext.placeContextQueue.async {
            self.saveToCloudkit(openingTime: openingTime, images: images)
        }
    }
    
    func checkInput() -> [InputTypes] {
        var error = [InputTypes]()
        if let _name = place.name {
            if _name.isValidInput(type: .name) == false {
                error.append(.name)
            }
        }
        if let _web = place.web, _web.count > 0 {
            if _web.isValidInput(type: .web) == false {
                error.append(.web)
            }
        }
        if let _phone = place.phone, _phone.count > 0 {
            if _phone.isValidInput(type: .phone) == false {
                error.append(.phone)
            }
        }
        if let _email = place.email, _email.count > 0 {
            if _email.isValidInput(type: .email) == false {
                error.append(.email)
            }
        }
        return error
    }
    
    private func decodePlaceItemAddress() {
        var street = ""
        var city = ""
        var zipCode = ""
        
        let geoCoder = CLGeocoder()
        
        geoCoder.reverseGeocodeLocation(place.location!, completionHandler:
            {
                placemarks, error -> Void in
                
                if let _error = error {
                    self.delegateAddress?.placeContextDidDecodeAddress(address: nil, error: _error)
                    return
                }
                
                // Place details
                guard let placeMark = placemarks?.first else {
                    self.delegateAddress?.placeContextDidDecodeAddress(address: nil, error: error)
                    return
                }
                
                if let _city = placeMark.locality {
                    city = _city
                }
                if let _zipCode = placeMark.postalCode {
                    zipCode = _zipCode
                }
                if let _street = placeMark.thoroughfare {
                    street = _street
                }
                if let _streetNumber = placeMark.subThoroughfare{
                    street.append(contentsOf: " \(_streetNumber)")
                }
                
                if self.state == .Canceled {
                    self.state = .Finished
                    return
                }
                
                let address = Address.init(city: city, zipCode: zipCode, street: street)
                self.place.address = address
                
                self.state = .Finished
                DispatchQueue.main.async {
                    self.delegateAddress?.placeContextDidDecodeAddress(address: address.full, error: error)
                }
        })
    }
    
    private func saveToCloudkit(openingTime: OpeningTime, images: ImageContext) {
        var records = [CKRecord]() // Records to save
        
        let container = CKContainer.default()
        let publicDB = container.publicCloudDatabase
        
        //Create Place CKRecord
        let placeCKRecord = PlaceCKRecord.init(place: place)
        records.append(placeCKRecord.record)
        
        //Create OpeningTime CKRecord
        let openingTimeCKRecord = OpeningTimeCKRecord.init(days: openingTime.days, recordReference: placeCKRecord.record, openingRecordID: openingTime.recordID)
        records.append(openingTimeCKRecord.record)

        //Create Image CKRecords
        let imagesCKRecordsToSave = ImageCKRecord()
        imagesCKRecordsToSave.initImages(images: images.getImagesToSave(), recordReference: placeCKRecord.record)
        records.append(contentsOf: imagesCKRecordsToSave.record)

        let saveOperation = CKModifyRecordsOperation(recordsToSave: records, recordIDsToDelete: images.imagesToDelete)
        saveOperation.savePolicy = .changedKeys
        
        saveOperation.modifyRecordsCompletionBlock = { (records, recordsID, error) in
            
            if let _error = error {
                self.state = .Finished
                
                DispatchQueue.main.async {
                    self.delegateSave?.placeContextSaved(annotation: nil, error: _error)
                }
                return
            }
            
            if let _records = records {
                
                // Save record to Core Data
                DispatchQueue.main.async {
                    self.savePlacesToCoreData(records: _records)
                }
            }
        }
        
        publicDB.add(saveOperation)
    }
    
    private func savePlacesToCoreData(records: [CKRecord]) {
        let context = AppDelegate.viewContext
        
        var placeCKRecord: CKRecord?
        var openingTimeRecord: CKRecord?
        var imageRecords = [CKRecord]()
        
        for record in records {
            if record.recordType == PlaceCKRecordNames.record {
                placeCKRecord = record
            }
            else if record.recordType == "OpeningTime" {
                openingTimeRecord = record
            }
            else if record.recordType == "Image" {
                imageRecords.append(record)
            }
        }
        
        if let _placeCKRecord = placeCKRecord, let _openingTimeRecord = openingTimeRecord {
            // Save Place to CoreData
            let placeCoreData = PlaceCoreData.changeOrCreatePlace(record: _placeCKRecord, context: context)
            
            if let _placeCoreData = placeCoreData {
                // Save OpeningTime to CoreData
                OpeningTimeCoreData.changeOrCreate(place: _placeCoreData, record: _openingTimeRecord, context: context)
                
                // Save all Images to CoreData
                for image in imageRecords {
                    ImageCoreData.changeOrCreate(place: _placeCoreData, record: image, context: context)
                }
            }
            
            // Create annotation of new place
            createAnnotation(placeCKRecord: _placeCKRecord)
        }
        
        self.state = .Finished
        self.delegateSave?.placeContextSaved(annotation: annotation, error: nil)
    }
    
    private func createAnnotation(placeCKRecord: CKRecord) {
        if let _name = self.place.name, let _cathegory = self.place.cathegory {
            annotation = PlaceAnnotation.init(title: _name, cathegory: _cathegory, id: placeCKRecord.recordID.recordName, coordinate: self.place.location!.coordinate)
        }
    }
    
    func loadPlace() {
    
        guard let id = place.placeID else {
            state = .Failed
            self.delegateLoad?.placeContextLoadedPlace()
            return
        }
        
        let context = AppDelegate.viewContext
        let query:NSFetchRequest<PlaceCoreData> = PlaceCoreData.fetchRequest()
        
        let predicate = NSPredicate(format: "placeID = %@", id)
        query.predicate = predicate
        
        if let _record = try? context.fetch(query), _record.count == 1 {
            guard let recordToShow = _record.first else {
                state = .Failed
                self.delegateLoad?.placeContextLoadedPlace()
                return
            }
            
            place = Place.init(place: recordToShow) // Init new place
            
            self.placeCoreData = recordToShow // Save placeCoreData reference
            
            state = .Finished
            self.delegateLoad?.placeContextLoadedPlace()
        }
        else {
            state = .Failed
            self.delegateLoad?.placeContextLoadedPlace()
        }
    }
}
