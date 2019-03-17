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
import CloudKit
import CoreData

protocol GeoContextDelegate: AnyObject {
    func geoContextDidLoadAnnotations()
}

class MapViewController: UIViewController, GeoContextDelegate, PlaceContextDelegate {
    
    @IBOutlet weak var noPlacesInAreaView: UIView!
    @IBOutlet weak var loadingIndicatorView: UIView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var loadingPlacesView: UIView!
    @IBOutlet weak var createPlaceDialogView: UIView!
    @IBOutlet weak var createPlaceDialogStackView: UIStackView!
    @IBOutlet weak var createPlaceAddress: UILabel!
    @IBOutlet weak var createPlaceActivityIndicatorView: UIView!
    @IBOutlet weak var centerOnLocationButton: UIButton!
    @IBOutlet weak var createPlaceDialogViewNoButton: UIButton!
    @IBOutlet weak var createPlaceDialogYesButton: UIButton!
    @IBOutlet weak var cathegoryCollectionView: UICollectionView!
    @IBOutlet weak var collectionViewFlowLayout: UICollectionViewFlowLayout!
    @IBOutlet weak var cathegoryView: UIView!
    
    let locationManager = CLLocationManager()
    var mapCentered = false
    let regionRadius: CLLocationDistance = 10000 // meters
    
    var geoContext: GeoContext?
    var placeContext: PlaceContext?
    var cathegories = Cathegories.init(type: .all)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.register(PlaceAnnotationView.self,
                         forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)
        
        cathegoryCollectionView.dataSource = self.cathegories
        cathegoryCollectionView.delegate = self
        
        initComponentsGraphic()
        initLocationManager()
        initLongPressGestureRecognizer()
    }
    
    // MARK: Views graphic
    
    func initComponentsGraphic() {
        loadingPlacesView.roundCornersLarge()
        createPlaceDialogView.roundCornersLarge()
        createPlaceDialogYesButton.roundCornersLittle()
        createPlaceDialogViewNoButton.roundCornersLittle()
        cathegoryView.roundCornersLarge()
        noPlacesInAreaView.roundCornersLarge()
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
    
    // MARK: Map
    
    @IBAction func centerOnUserLocationButtonIsPressed(_ sender: Any) {
        if let location = locationManager.location {
            let radius = getRadiusFromMapView(mapView)
            centerMapOnUserLocation(location: location, radius: radius)
        }
    }
    
    func centerMapOnUserLocation(location: CLLocation, radius: CLLocationDistance) {
        let coordinateRegion = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: radius, longitudinalMeters: radius)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    // Mark: Geocontext
    
    func geoContextDidLoadAnnotations() {
        loadingIndicatorView.isHidden = true
        mountGeocontext()
    }
    
    // Showing geocontext annotations
    func mountGeocontext() {
        guard let annotations = geoContext?.annotations else {
            return
        }
        
        if annotations.count == 0 {
            noPlacesInAreaView.isHidden = false
        }
        
        mapView.addAnnotations(annotations)
        mapView.showAnnotations(annotations, animated: true)
    }
    
    // Removing Geocontext annotations
    func unmountGeocontext(_ geoContext: GeoContext?) {
        guard let annotations = geoContext?.annotations else {
            return
        }
        mapView.removeAnnotations(annotations)
    }
    
    // Function delete and create new geocontex.
    func newGeocontext(coordinate: CLLocationCoordinate2D, radius: CLLocationDistance, cathegory: String) {
        let location = CLLocation.init(latitude: coordinate.latitude, longitude: coordinate.longitude)
        var updatedRadius: CLLocationDistance = 10000 // Smalest radius which can be used by CloudKit for searching
        
        if radius > 10000 {
            updatedRadius = radius
        }

        if let _geoContext = geoContext {
            // When geocontext exist
            
            let locationDistance = location.distance(from: _geoContext.location)
            let newArea = locationDistance + radius
            
            // Check if user needs to fetch new places
            if _geoContext.cathegory == cathegory, newArea < _geoContext.radius {
                return
            }
            
            noPlacesInAreaView.isHidden = true
            loadingIndicatorView.isHidden = false

            if _geoContext.state == .finished {
                unmountGeocontext(_geoContext)
            }
            _geoContext.cancel()
        }
        
        // New GeoContext
        geoContext = GeoContext(location: location, radius: updatedRadius, cathegory: cathegory)
        geoContext?.delegate = self
    }
    
    @IBAction func searchButtonIsPressed(_ sender: Any) {
        let coordinate = mapView.region.center
        let radius = getRadiusFromMapView(mapView)
        let cathegory = cathegories.selectedCathegory()
        
        newGeocontext(coordinate: coordinate, radius: radius, cathegory: cathegory)
    }
    
    // Function calculate new radius from distance of upper left point and middle
    func getRadiusFromMapView(_ mapView: MKMapView) -> CLLocationDistance{
        let span = mapView.region.span
        let center = mapView.region.center
        
        let centerPoint = CLLocation(latitude: center.latitude, longitude: center.longitude)
        let upperRightPoint = CLLocation(latitude: center.latitude + span.latitudeDelta * 0.5, longitude: center.longitude + span.longitudeDelta * 0.5)
        
        let radius = centerPoint.distance(from: upperRightPoint)
        
        return radius
    }
    
    // Mark: Create new place
    
    @objc func longTapGesture(_ sender: UILongPressGestureRecognizer) {
        if sender.state == .ended {
            let locationInView = sender.location(in: mapView)
            let locationOnMap = mapView.convert(locationInView, toCoordinateFrom: mapView)
            showCreateNewPlaceDialog(coordinate: locationOnMap)
        }
    }
    
    private func initLongPressGestureRecognizer() {
        let gesture = UILongPressGestureRecognizer(target: self, action: #selector(self.longTapGesture))
        mapView.addGestureRecognizer(gesture)
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if view.annotation is MKUserLocation {
            // Check if user selected current location
            guard let location = locationManager.location?.coordinate else {
                return
            }
            
            showCreateNewPlaceDialog(coordinate: location)
        }
    }
    
    func showCreateNewPlaceDialog(coordinate: CLLocationCoordinate2D) {
        createPlaceDialogView.isHidden = false
        centerOnLocationButton.isHidden = true
        
        if placeContext != nil {
            unmountPlaceContext()
        }
        
        let location = CLLocation.init(latitude: coordinate.latitude, longitude: coordinate.longitude)
        placeContext = PlaceContext.init(location: location)
        placeContext?.delegate = self
        mountPlaceContext(placeContext: placeContext)
        placeContext?.getAddress()
    }
    
    func placeContextDidDecodeAddress(address: String?, error: Error?) {
        createPlaceActivityIndicatorView.isHidden = true

        if error != nil {
            createPlaceDialogView.isHidden = true
            unmountPlaceContext()
            showAlert(title: "Could not create new place!", message: "Connection error!", confirmTitle: "Ok")
            return
        }
        
        createPlaceAddress.text = address!
        createPlaceDialogStackView.isHidden = false
    }
    
    // Show annotation when creating place
    func mountPlaceContext(placeContext: PlaceContext?) {
        guard let annotation = placeContext?.annotation else {
            return
        }
        mapView.addAnnotation(annotation)
        mapView.setCenter(annotation.coordinate, animated: true)
    }
    
    // Remove annotation when creating place
    func unmountPlaceContext() {
        guard let annotation = placeContext?.annotation else {
            return
        }
        mapView.removeAnnotation(annotation)
    }
    
    @IBAction func createPlaceDialogNoButtonPressed(_ sender: UIButton) {
        unmountPlaceContext()
        createPlaceDialogView.isHidden = true
        centerOnLocationButton.isHidden = false
    }
    
    @IBAction func createPlaceDialogYesButtonPressed(_ sender: UIButton) {
        if isICloudKitContainerAvailable() {
            createPlaceDialogView.isHidden = true
            unmountPlaceContext()
            performSegue(withIdentifier: "createPlaceDialog", sender: self)
        } else {
            showAlert(title: "No iCloud account!", message: "To create new place you need to login to your iCloud account in your settings.", confirmTitle: "Ok")
        }
    }
    
    func isICloudKitContainerAvailable() -> Bool {
        // Check if iCloud is currently available
        if FileManager.default.ubiquityIdentityToken != nil {
            return true
        }
        else {
            return false
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "createPlaceDialog" {
            centerOnLocationButton.isHidden = false
            if let vc = segue.destination as? CreatePlaceViewController {
                vc.placeContext = placeContext
            }
        }
    }
    
    @IBAction func unwindToMapViewController(segue: UIStoryboardSegue) {
        if segue.source is CreatePlaceViewController {
            // Add creted place
            mountGeocontext()
        }
    }
    
    // MARK: Alert
    
    func showAlert(title: String?, message: String?, confirmTitle: String?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: confirmTitle, style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }

}

// MARK: Location manager delegate

extension MapViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if mapCentered == false, let location = locations.first {
            // Initialization of GeoContext when location is obtained for the firs time
            let cathegory = cathegories.selectedCathegory()
            newGeocontext(coordinate: location.coordinate, radius: regionRadius, cathegory: cathegory)
            mapCentered = true
        }
    }
}

// MARK: Collection view delegeate

extension MapViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        cathegories.selectedIndex = indexPath.row
        collectionView.reloadData()
        
        let coordinate = mapView.region.center
        let radius = getRadiusFromMapView(mapView)
        let cathegory = cathegories.selectedCathegory()
        
        newGeocontext(coordinate: coordinate, radius: radius, cathegory: cathegory)
    }
}

// MARK: Collection view resizing cells

extension MapViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let string = cathegories.cathegories[indexPath.row] // Get string of current cell
        var font =  UIFont.systemFont(ofSize: 16)
        let height: CGFloat = 20 // Height of cell
        
        if indexPath.row == cathegories.selectedIndex {
            // If cathegory is selected
            font = UIFont.boldSystemFont(ofSize: 18)
        }
        
        let width = string.name.width(withConstrainedHeight: height, font: font)
        return CGSize(width: width, height: height)
    }
}



