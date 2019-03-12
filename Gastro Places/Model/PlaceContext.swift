//
//  CreatePlaceContext.swift
//  Gastro Places
//
//  Created by Michal Martinů on 08/03/2019.
//  Copyright © 2019 Michal Martinů. All rights reserved.
//

import Foundation
import CoreLocation
import MapKit


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

class PlaceContext: PlaceContextProtocol {
    
    var place: Place
    
    weak var delegate: PlaceContextDelegate?
    
    let annotation: PlaceAnnotation
    
    private let operationQueue = OperationQueue()
    
    init(location: CLLocation) {
        self.annotation = PlaceAnnotation.init(title: "New place", cathegory: "", coordinate: location.coordinate)
        place = Place(location: location)
    }
    
    func changeData(cathegory: String, name: String, phone: String, email: String, web: String) {
        self.place.cathegory = cathegory
        self.place.name = name
        self.place.phone = phone
        self.place.email = email
        self.place.web = web
    }
    
    func cancel() {
        operationQueue.cancelAllOperations()
    }
    
    func getAddress() {
        let decodePlaceAddress = DecodePlaceAddress.init(location: place.location)
        decodePlaceAddress.delegate = self
        operationQueue.addOperation(decodePlaceAddress)
    }
    
    func save() {
        let savePlace = SavePlace.init(place: place)
        savePlace.delegate = self
        operationQueue.addOperation(savePlace)
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

class DecodePlaceAddress: AsyncOperation {
    let location: CLLocation
    
    weak var delegate: PlaceContextProtocol?
    
    init(location: CLLocation) {
        self.location = location
    }
    
    override func main() {
        if isCancelled {
            state = .Finished
            return
        }
        decodePlaceItemAddress()
    }
    
    private func decodePlaceItemAddress() {
        var street = ""
        var city = ""
        var zipCode = ""
        let geoCoder = CLGeocoder()
        geoCoder.reverseGeocodeLocation(location, completionHandler:
            {
                placemarks, error -> Void in
                
                // Place details
                guard let placeMark = placemarks?.first else {
                    self.delegate?.finishedDecodingAddress(address: nil, error: error)
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
                
                if self.isCancelled {
                    self.state = .Finished
                    return
                }
                let address = Address.init(city: city, zipCode: zipCode, street: street)
                self.delegate?.finishedDecodingAddress(address: address, error: error)
                self.state = .Finished
        })
    }
}
