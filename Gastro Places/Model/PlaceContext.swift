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
    func finishedDecodingAddress(city: String?, street: String?)
    func placeSaved(place: Place, error: Error?)
}

@objc protocol PlaceContextDelegate: AnyObject {
    @objc optional func placeContextDidDecodeAddress(address: String)
    @objc optional func placeContextSaved(annotation: PlaceAnnotation, error: Error?)
}


enum InputTypes {
    case email
    case web
    case phone
    case name
}

struct Place {
    let location: CLLocation
    var street: String?
    var city: String?
    var placeID: String?
    var cathegory: String?
    var name: String?
    var phone: String?
    var email: String?
    var web: String?
    
    init(location: CLLocation) {
        self.location = location
    }
}

class PlaceContext: PlaceContextProtocol {
    
    var place: Place
    
    weak var delegate: PlaceContextDelegate?
    
    var address: String {
        var address = ""
        if let _street = place.street {
            address += _street
        }
        if let _city = place.city {
            address += " \(_city)"
        }
        return address
    }
    
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
    
    func finishedDecodingAddress(city: String?, street: String?) {
        self.place.street = street
        self.place.city = city
        DispatchQueue.main.async {
            self.delegate?.placeContextDidDecodeAddress!(address: self.address)
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
        var street: String?
        var city: String?
        let geoCoder = CLGeocoder()
        geoCoder.reverseGeocodeLocation(location, completionHandler:
            {
                placemarks, error -> Void in
                
                // Place details
                guard let placeMark = placemarks?.first else { return }
                
                if let _city = placeMark.locality {
                    city = _city
                }
                if let _zipCode = placeMark.postalCode {
                    city?.append(contentsOf: " \(_zipCode)")
                }
                if let _street = placeMark.thoroughfare {
                    street = _street
                }
                if let _streetNumber = placeMark.subThoroughfare{
                    street?.append(contentsOf: " \(_streetNumber)")
                }
                
                if self.isCancelled {
                    self.state = .Finished
                    return
                }
                
                self.delegate?.finishedDecodingAddress(city: city, street: street)
                self.state = .Finished
        })
    }
}
