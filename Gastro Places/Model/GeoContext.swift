//
//  GeoContext.swift
//  Gastro Places
//
//  Created by Michal Martinů on 06/03/2019.
//  Copyright © 2019 Michal Martinů. All rights reserved.
//

import Foundation
import CoreLocation
import MapKit

protocol GeocontextOperations: AnyObject {
    func finishedLoadingData(placeAnnotation: [PlaceAnnotationItem], error: Error?)
}

enum GeoContextState {
    case ready, exectuting, finished, noData, failed, canceled
}

class GeoContext: GeocontextOperations {
    
    var annotations = [MKAnnotation]()
    var state = GeoContextState.ready
    
    let location: CLLocation
    let radius: CLLocationDistance
    
    private let operationQueue = OperationQueue()
    private var fetchGeocontext: FetchGeoContext?
    
    weak var delegate: GeoContextDelegate?
    
    init(location: CLLocation, radius: CLLocationDistance) {
        self.location = location
        self.radius = radius
        getData()
    }
    
    func getData() {
        fetchGeocontext = FetchGeoContext(location: location, radius: radius)
        fetchGeocontext?.delegate = self
        operationQueue.addOperation(fetchGeocontext!)
    }
    
    func finishedLoadingData(placeAnnotation: [PlaceAnnotationItem], error: Error?) {
        fetchGeocontext = nil
        
        if error != nil {
            state = .failed
            return
        }
        
        if placeAnnotation.count == 0 {
            state = .noData
            return
        }
        
        for placeAnnotation in placeAnnotation {
            self.annotations.append(placeAnnotation.annotation)
        }
        
        state = .finished
        DispatchQueue.main.async {
            self.delegate?.geoContextDidLoadAnnotations()
        }
    }
    
    func cancel() {
        operationQueue.cancelAllOperations()
        delegate = nil
        state = .canceled
    }
}



