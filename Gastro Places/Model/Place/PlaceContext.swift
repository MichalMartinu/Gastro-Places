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

enum PlaceContextState {
    case Ready, Executing, Finished, Failed, Canceled
}

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

class Place {
    var location: CLLocation?
    var placeID: String?
    var cathegory: String?
    var name: String?
    var phone: String?
    var email: String?
    var web: String?
    var address: Address?
    
    init(location: CLLocation) {
        self.location = location
    }
    
    init(placeID: String) {
        self.placeID = placeID
    }
    
    init(place: PlaceCoreData) {
        self.location = CLLocation(latitude: place.latitude, longitude: place.longitude)
        self.placeID = place.placeID
        self.cathegory = place.cathegory
        self.name = place.name
        self.phone = place.phone
        self.email = place.email
        self.web = place.web
        self.address = Address.init(city: place.city ?? "", zipCode: place.zipCode ?? "", street: place.street ?? "")
    }
}

class PlaceContext {
    
    private(set) var place: Place
    
    weak var delegateSave: PlaceContextDelegateSave?
    weak var delegateLoad: PlaceContextDelegateLoad?
    weak var delegateAddress: PlaceContextDelegateAdress?
    
    var annotation: PlaceAnnotation
    
    var state = PlaceContextState.Ready
    
    private static let placeContextQueue = DispatchQueue(label: "placeContextQueue", qos: .userInteractive, attributes: .concurrent)
    
    init(location: CLLocation) {
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
        PlaceContext.placeContextQueue.async {
            self.decodePlaceItemAddress()
        }
    }
    
    func save(days: [Day], images: ImageContext) {
        PlaceContext.placeContextQueue.async {
            self.saveToCloudkit(days: days, images: images)
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
                } else {
                    let address = Address.init(city: city, zipCode: zipCode, street: street)
                    self.place.address = address
                    self.state = .Finished
                    DispatchQueue.main.async {
                        self.delegateAddress?.placeContextDidDecodeAddress(address: address.full, error: error)
                    }
                }
        })
    }
    
    private func saveToCloudkit(days: [Day], images: ImageContext) {
        var records = [CKRecord]()
        
        let container = CKContainer.default()
        let publicDB = container.publicCloudDatabase
        
        let placeCKRecord = PlaceCKRecord.init(place: place)
        let openingTimeCKRecord = OpeningTimeCKRecord.init(days: days, id: placeCKRecord.recordID, recordReference: placeCKRecord.record)
        let imagesCKRecordsToSave = ImageCKRecord()
        imagesCKRecordsToSave.initImages(images: images.getImagesToSave(), recordReference: placeCKRecord.record)
        
        records.append(placeCKRecord.record)
        records.append(openingTimeCKRecord.record)
        records.append(contentsOf: imagesCKRecordsToSave.record)
        
        let saveOperation = CKModifyRecordsOperation(recordsToSave: records)
        saveOperation.savePolicy = .changedKeys
        saveOperation.modifyRecordsCompletionBlock = { (records, recordsID, error) in
            
            if let _error = error {
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
        
        var placeCoreData: PlaceCoreData?
        
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
            placeCoreData = PlaceCoreData.changeOrCreatePlace(record: _placeCKRecord, context: context)
            
            if let _placeCoreData = placeCoreData {
                OpeningTimeCoreData.changeOrCreate(place: _placeCoreData, record: _openingTimeRecord, context: context)
                
                for image in imageRecords {
                    ImageCoreData.changeOrCreate(place: _placeCoreData, record: image, context: context)
                }
            }
            
            createAnnotation(placeCKRecord: _placeCKRecord)
        }
        
        try? context.save()
        
        self.state = .Finished
        self.delegateSave?.placeContextSaved(annotation: annotation, error: nil)
    }
    
    private func createAnnotation(placeCKRecord: CKRecord) {
        if let _name = self.place.name, let _cathegory = self.place.cathegory {
            annotation = PlaceAnnotation.init(title: _name, cathegory: _cathegory, id: placeCKRecord.recordID.recordName, coordinate: self.place.location!.coordinate)
        }
    }
    
    func loadPlace() {
        let context = AppDelegate.viewContext
        let query:NSFetchRequest<PlaceCoreData> = PlaceCoreData.fetchRequest()
        
        guard let id = place.placeID else {
            state = .Failed
            self.delegateLoad?.placeContextLoadedPlace()
            return
        }
        
        let predicate = NSPredicate(format: "placeID = %@", id)
        query.predicate = predicate
        
        if let _record = try? context.fetch(query), _record.count == 1 {
            guard let recordToShow = _record.first else {
                state = .Failed
                self.delegateLoad?.placeContextLoadedPlace()
                return
            }
            
            place = Place.init(place: recordToShow)
            state = .Finished
            self.delegateLoad?.placeContextLoadedPlace()
        }
        else {
            state = .Failed
            self.delegateLoad?.placeContextLoadedPlace()
        }
    }
}
