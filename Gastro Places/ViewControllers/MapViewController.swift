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
        mountGeocontext()
    }
    
    func mountGeocontext() {
        guard let annotations = geoContext?.annotations else {
            return
        }
        mapView.addAnnotations(annotations)
    }
    
    func unmountGeocontext(_ geoContext: GeoContext?) {
        guard let annotations = geoContext?.annotations else {
            return
        }
        mapView.removeAnnotations(annotations)
    }
    
    
    @IBAction func searchButtonIsPressed(_ sender: Any) {
        if let _geoContext = geoContext {
            if _geoContext.state == .finished {
                unmountGeocontext(_geoContext)
            }
            _geoContext.cancel()
        }
        
        let coordinate = mapView.region.center
        let location = CLLocation.init(latitude: coordinate.latitude, longitude: coordinate.longitude)
        let radius = getRadiusFromMapView(mapView)
        geoContext = GeoContext(location: location, radius: radius)
        geoContext?.delegate = self

    }
    
    func getRadiusFromMapView(_ mapView: MKMapView) -> CLLocationDistance{
        let span = mapView.region.span
        let center = mapView.region.center
        
        let locationCenter = CLLocation(latitude: center.latitude, longitude: center.longitude)
        let locationUpperRight = CLLocation(latitude: center.latitude + span.latitudeDelta * 0.5, longitude: center.longitude + span.longitudeDelta * 0.5)
        let radius = locationCenter.distance(from: locationUpperRight)
        
        return radius
    }
}


protocol GeocontextDelegate: AnyObject {
    func geocontextDidLoadAnnotations()
}
