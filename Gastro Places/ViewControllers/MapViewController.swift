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

class MapViewController: UIViewController, CLLocationManagerDelegate {

    @IBOutlet weak var loadingIndicatorView: UIView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var loadingPlacesView: UIView!
    
    let locationManager = CLLocationManager()
    var mapCentered = false
    let regionRadius: CLLocationDistance = 1000

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
        if mapCentered == false {
            centerMapOnUserLocation(location: locations, radius: regionRadius)
            mapCentered = true
        }
    }
    
     // MARK: Map
    
    func centerMapOnUserLocation(location: [CLLocation], radius: CLLocationDistance) {
        let location = location.first!
        let coordinateRegion = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: radius, longitudinalMeters: radius)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    func showAlert(title: String?, message: String?, confirmTitle: String?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: confirmTitle, style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}
