//
//  ViewController.swift
//  Gastro Places
//
//  Created by Michal Martinů on 06/03/2019.
//  Copyright © 2019 Michal Martinů. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class MapViewController: UIViewController, CLLocationManagerDelegate, GeocontextDelegate {

    @IBOutlet weak var loadingIndicatorView: UIView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var loadingPlacesView: UIView!
        
    let locationManager = CLLocationManager()
    var mapCentered = false
    let regionRadius: CLLocationDistance = 1000
    
    var geoContext: GeoContext?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        roundButtonsAndViews()
        
        initLocationManager()
    }
    
    func roundButtonsAndViews() {
        loadingPlacesView.roundCornersLarge()
        
    }
    
    // MARK: Location manager
    
    func initLocationManager() {
        checkLocationAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
    }
    
    private func checkLocationAuthorization() {
        switch CLLocationManager.authorizationStatus() {
        case .denied:
            showAlert(title: "Location service is denined for this app", message: "To see actual location please enable location permission in setting for this application", confirmTitle: "Ok")
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        default:
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if mapCentered == false, let location = locations.first {
            geoContext = GeoContext(location: location, radius: regionRadius)
            geoContext?.delegate = self
            centerMapOnUserLocation(location: location, radius: regionRadius)
            mapCentered = true
        }
    }
    
     // MARK: Map
    
    func centerMapOnUserLocation(location: CLLocation, radius: CLLocationDistance) {
        let coordinateRegion = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: radius, longitudinalMeters: radius)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    func showAlert(title: String?, message: String?, confirmTitle: String?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: confirmTitle, style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func centerOnUserLocationButtonIsPressed(_ sender: Any) {
        if let location = locationManager.location {
            centerMapOnUserLocation(location: location, radius: regionRadius)
        }
    }
    
    // Mark: Geocontext
    func geocontextDidLoadAnnotations() {
        mountGeocontext(geoContext)
    }
    
    func mountGeocontext(_ geoContext: GeoContext?) {
        guard let placeAnnotations = geoContext?.placeAnnotation else {
            return
        }
        
        for placeAnnotation in placeAnnotations {
            mapView.addAnnotation(placeAnnotation.annotation)
        }
    }
}


protocol GeocontextDelegate: AnyObject {
    func geocontextDidLoadAnnotations()
}
