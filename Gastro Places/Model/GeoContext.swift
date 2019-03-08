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
    case ready, exectuting, finished, noData, failed
}

class GeoContext: GeocontextOperations {
    
    var placeAnnotation = [PlaceAnnotationItem]()
    var state = GeoContextState.ready
    
    let location: CLLocation
    let radius: CLLocationDistance
    
    private let operationQueue = OperationQueue()
    private var fetchGeocontext: FetchGeoContext?
    
    weak var delegate: GeocontextDelegate?
    
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
        
        self.placeAnnotation = placeAnnotation
        state = .finished
        delegate?.geocontextDidLoadAnnotations()
    }
}



