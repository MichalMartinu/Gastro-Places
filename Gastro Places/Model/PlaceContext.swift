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
}

class PlaceContext: PlaceContextProtocol {
    
    let location: CLLocation
    var street: String?
    var city: String?
    
    weak var delegate: PlaceContextDelegate?
    
    var address: String {
        var address = ""
        if let _street = street {
            address += _street
        }
        if let _city = city {
            address += " \(_city)"
        }
        return address
    }
    
    let annotation = MKPointAnnotation()
    
    private let operationQueue = OperationQueue()
    
    init(location: CLLocation) {
        self.location = location
        
        self.annotation.coordinate = location.coordinate
        self.annotation.title = "New place"
    }
    
    func cancel() {
        operationQueue.cancelAllOperations()
    }
    
    func getAddress() {
        let decodePlaceAddress = DecodePlaceAddress.init(location: location)
        decodePlaceAddress.delegate = self
        operationQueue.addOperation(decodePlaceAddress)
    }
    
    func finishedDecodingAddress(city: String?, street: String?) {
        self.street = street
        self.city = city
        DispatchQueue.main.async {
            self.delegate?.placeContextDidDecodeAddress(address: self.address)
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
