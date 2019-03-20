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

protocol PlaceContextProtocol: AnyObject {
    func finishedDecodingAddress(address: Address?, error: Error?)
    func placeSaved(place: Place, error: Error?)
}

@objc protocol PlaceContextDelegate: AnyObject {
    @objc optional func placeContextDidDecodeAddress(address: String?, error: Error?)
    @objc optional func placeContextSaved(annotation: PlaceAnnotation, error: Error?)
}


enum InputTypes: String {
    case email = "email"
    case web = "web"
    case phone = "phone"
    case name = "name"
}

struct Place {
    let location: CLLocation
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
}

class PlaceContext {
    
    var place: Place
    
    weak var delegate: PlaceContextDelegate?
    
    let annotation: PlaceAnnotation
    
    var state = PlaceContextState.Ready

    private let container: CKContainer
    private let publicDB: CKDatabase
    
    static let placeContextQueue = DispatchQueue(label: "placeContextQueue", qos: .utility, attributes: .concurrent)
    
    init(location: CLLocation) {
        self.annotation = PlaceAnnotation.init(title: "New place", cathegory: "", coordinate: location.coordinate)
        place = Place(location: location)
        container = CKContainer.default()
        publicDB = container.publicCloudDatabase
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
    
    func save(days: [Day]) {
        PlaceContext.placeContextQueue.async {
            self.saveToCloudkit(days: days)
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
        geoCoder.reverseGeocodeLocation(place.location, completionHandler:
            {
                placemarks, error -> Void in
                
                // Place details
                guard let placeMark = placemarks?.first else {
                    self.delegate?.placeContextDidDecodeAddress!(address: nil, error: error)
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
                    self.state = .Finished
                    DispatchQueue.main.async {
                        self.delegate?.placeContextDidDecodeAddress!(address: address.full, error: error)
                    }
                }
        })
    }
    
    func saveToCloudkit(days: [Day]) {
        var records = [CKRecord]()
        
        let placeCKRecord = PlaceCKRecord.init(place: place)
        let openingTimeCKRecord = OpeningTimeCKRecord.init(days: days, id: placeCKRecord.recordID, record: placeCKRecord.record)
        
        records.append(placeCKRecord.record)
        records.append(openingTimeCKRecord.record)
        
        let saveOperation = CKModifyRecordsOperation(recordsToSave: records)
        saveOperation.savePolicy = .changedKeys
        saveOperation.modifyRecordsCompletionBlock = { (records, recordsID, error) in
            
            if let _records = records {
                // Save record to Core Data
                DispatchQueue.main.async {
                    self.savePlacesToCoreData(records: _records)
                }
            }
            
            if let _name = self.place.name, let _cathegory = self.place.cathegory {
                // Finished
                let newAnnotation = PlaceAnnotation.init(title: _name, cathegory: _cathegory, coordinate: self.place.location.coordinate)
                self.state = .Finished
                DispatchQueue.main.async {
                    self.delegate?.placeContextSaved!(annotation: newAnnotation, error: error)
                }
            }
        }
        
        publicDB.add(saveOperation)
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
    
    func finishedDecodingAddress(address: Address?, error: Error?) {
        if let _address = address {
            self.place.address = _address
        }
        DispatchQueue.main.async {
            self.delegate?.placeContextDidDecodeAddress!(address: address?.full, error: error)
        }
    }
    
    func placeSaved(place: Place, error: Error?) {
        if let name = place.name, let cathegory = place.cathegory {
            let annotation = PlaceAnnotation.init(title: name, cathegory: cathegory, coordinate: place.location.coordinate)
            DispatchQueue.main.async {
                self.delegate?.placeContextSaved!(annotation: annotation, error: error)
            }
        }
    }
}
