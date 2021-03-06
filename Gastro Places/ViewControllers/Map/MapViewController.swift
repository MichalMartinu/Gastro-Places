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



class MapViewController: UIViewController {
    
    @IBOutlet weak var loadingIndicatorView: UIView!
    @IBOutlet weak var mapView: MKMapView!
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
    @IBOutlet weak var cathegoryLineView: UIView!
    @IBOutlet weak var cathegoryLabel: UILabel!
    @IBOutlet weak var geoContextInformationView: UIView!
    @IBOutlet weak var geoContextInformationLabel: UILabel!
    
    
    private var mapCentered = false
    
    private let regionRadius: CLLocationDistance = 5000 // meters
    
    private(set) var geoContext: GeoContext?
    
    private var placeContext: PlaceContext?
    
    private var cathegories = Cathegories.init(type: .all)
    
    let noPlacesMessage = "No places in this area"
    let geoContextErrorMessage = "Some error ocured"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set custom annotation class as points on map
        mapView.register(PlaceAnnotationView.self, forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)
        mapView.delegate = self
        
        cathegoryCollectionView.dataSource = self.cathegories // Class cathegories has datasource
        cathegoryCollectionView.delegate = self
        
        setRefreshButton(enabled: false)
        
        initComponentsGraphic()
        initLocationManager()
        initLongPressGestureRecognizer()
        
        NotificationCenter.default.addObserver(self, selector: #selector(deleteAnnotation(_:)), name: .didDeletePlace, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(changeAnnotation(_:)), name: .didChangePlace, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.isNavigationBarHidden = false

        placeContext = nil
    }
    
    // MARK: Views graphic
    
    private func initComponentsGraphic() {
        // Round buttons
        createPlaceDialogView.roundCornersLarge()
        createPlaceDialogYesButton.roundCornersLittle()
        createPlaceDialogViewNoButton.roundCornersLittle()
        cathegoryView.roundCornersLarge()
        geoContextInformationView.roundCornersLarge()
        loadingIndicatorView.roundCornersLarge()
    }
    
    private func setRefreshButton(enabled: Bool) {
        // Show refresh button
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(searchButtonIsPressed))
        navigationItem.rightBarButtonItem?.isEnabled = enabled
    }
    
    private func enableRefreshButton(enabled: Bool) {
        navigationItem.rightBarButtonItem?.isEnabled = enabled
    }
    
    private func setCancelButton() {
        // Show cancel button
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .stop, target: self, action: #selector(cancelButtonIsPressed))
    }
    
    private func showGeoContextInformationView(text: String) {
        // Show information view on top of screen with message
        geoContextInformationView.isHidden = false
        geoContextInformationLabel.text = text
    }
   
    // MARK: Location manager
    
    private func initLocationManager() {
        checkLocationAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            // Start locating user
            CustomLocationManager.manager.delegate = self
            CustomLocationManager.manager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            CustomLocationManager.manager.startUpdatingLocation()
        }
    }
    
    private func checkLocationAuthorization() {
        // Check if user enabled location services
        switch CLLocationManager.authorizationStatus() {
        case .denied:
            showAlert(title: "Location service is denined for this app", message: "To see actual location please enable location permission in setting for this application", confirmTitle: "Ok", handler: nil)
        case .notDetermined:
            CustomLocationManager.manager.requestWhenInUseAuthorization()
        default:
            break
        }
    }
    
    // MARK: Map
    
    @IBAction private func centerOnUserLocationButtonIsPressed(_ sender: Any) {
        if let location = CustomLocationManager.manager.location {
            let radius = getRadiusFromMapView(mapView)
            
            centerMapOnUserLocation(location: location, radius: radius)
        }
    }
    
    private func centerMapOnUserLocation(location: CLLocation, radius: CLLocationDistance) {
        let coordinateRegion = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: radius, longitudinalMeters: radius)
        
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    // Mark: Geocontext
    
    // Showing geocontext annotations
    private func mountGeocontext() {
        guard let annotations = geoContext?.annotations else { return }
        
        if annotations.count == 0 {
            // Show dialog that there are no places
            showGeoContextInformationView(text: noPlacesMessage)
            return
        }
        
        mapView.addAnnotations(annotations)
    }
    
    // Removing Geocontext annotations
    private func unmountGeocontext(_ geoContext: GeoContext?) {
        geoContext?.delegate = nil // Stop recieving messages from this GeoContext
        geoContext?.cancel()
        
        guard let annotations = geoContext?.annotations else { return }
        
        mapView.removeAnnotations(annotations)
    }
    
    // Function delete and create new geocontex.
    private func newGeocontext(coordinate: CLLocationCoordinate2D, radius: CLLocationDistance, cathegory: String) {
        let location = CLLocation.init(latitude: coordinate.latitude, longitude: coordinate.longitude)
        var updatedRadius: CLLocationDistance = 10000 // Smalest radius which can be used by CloudKit for searching
        
        if radius > 10000 {
            // CloudKit can only work with radius 10000
            updatedRadius = radius
        }

        if let _geoContext = geoContext {
            
            // When geocontext exist and is finished
            if _geoContext.state == .Finished {
                unmountGeocontext(_geoContext)
            }
        }
        
        // New GeoContext
        geoContext = GeoContext(location: location, radius: updatedRadius, cathegory: cathegory)
        geoContext?.delegate = self
        
        geoContextInformationView.isHidden = true
        loadingIndicatorView.isHidden = false
        
        geoContext?.start() // Get new places
    }
    
    private func checkIfGeoContextCanBeUpdated() {
        let coordinate = mapView.region.center
        let location = CLLocation.init(latitude: coordinate.latitude, longitude: coordinate.longitude)
        let radius = getRadiusFromMapView(mapView)

        if let _geoContext = geoContext {
            // When geocontext exist
            let locationDistance = location.distance(from: _geoContext.location)
            let newArea = locationDistance + radius
            
            let deviation = 100.0 // Deviation of radius
            
            // Check if radius is different than old one
            if newArea < _geoContext.radius + deviation, geoContext?.state == .Finished {
                enableRefreshButton(enabled: false)
                return
            }
        }
        
        if geoContext?.state == .Executing {
            // Enable refresh button when geocontext is exectuing
            enableRefreshButton(enabled: false)
            
            return
        }
        
        enableRefreshButton(enabled: true)
    }
    
    @objc private func searchButtonIsPressed(_ sender: Any) {
        setCancelButton()
        
        let coordinate = mapView.region.center
        let radius = getRadiusFromMapView(mapView)
        let cathegory = cathegories.selectedCathegory()
        
        newGeocontext(coordinate: coordinate, radius: radius, cathegory: cathegory)
    }
    
    @objc private func cancelButtonIsPressed(_ sender: Any) {
        // Remove GeoContext that is already executing
        geoContext?.cancel()
        geoContext = nil
        
        setRefreshButton(enabled: false)
        loadingIndicatorView.isHidden = true
        
        checkIfGeoContextCanBeUpdated()
    }
    
    // Function calculate new radius from distance of upper left point and middle
    private func getRadiusFromMapView(_ mapView: MKMapView) -> CLLocationDistance{
        let span = mapView.region.span
        let center = mapView.region.center
        
        //Generate radius as distance of two points in mapView
        let centerPoint = CLLocation(latitude: center.latitude, longitude: center.longitude)
        let upperRightPoint = CLLocation(latitude: center.latitude + span.latitudeDelta * 0.5, longitude: center.longitude + span.longitudeDelta * 0.5)
        
        let radius = centerPoint.distance(from: upperRightPoint)
        
        return radius
    }
    
    // Mark: Create new place
    
    @objc private func longTapGesture(_ sender: UILongPressGestureRecognizer) {
        if sender.state == .ended {
            let locationInView = sender.location(in: mapView)
            let locationOnMap = mapView.convert(locationInView, toCoordinateFrom: mapView)
            
            showCreateNewPlaceDialog(coordinate: locationOnMap)
        }
    }
    
    private func initLongPressGestureRecognizer() {
        let gesture = UILongPressGestureRecognizer(target: self, action: #selector(self.longTapGesture))
        gesture.minimumPressDuration = 0.5
        
        mapView.addGestureRecognizer(gesture)
    }
    
    private func initShowCreateNewPlaceDialog() {
        createPlaceDialogView.isHidden = false
        centerOnLocationButton.isHidden = true
        createPlaceActivityIndicatorView.isHidden = false
        createPlaceDialogStackView.isHidden = true
    }
    
    private func destroyPlaceContext() {
        if let _placeContext = placeContext {
            
            _placeContext.delegateAddress = nil
            
            unmountPlaceContext()
        }
    }
    
    private func showCreateNewPlaceDialog(coordinate: CLLocationCoordinate2D) {
        initShowCreateNewPlaceDialog()

        if placeContext?.annotation.id == nil {
            destroyPlaceContext()
        }
        
        let location = CLLocation.init(latitude: coordinate.latitude, longitude: coordinate.longitude)
        
        placeContext = PlaceContext.init(location: location) // Create new placeContext
        placeContext?.delegateAddress = self
        
        mountPlaceContext(placeContext: placeContext)
        
        placeContext?.getAddress()
    }
    
    @IBAction private func createPlaceDialogCancelButtonIsPressed(_ sender: Any) {
        // User canceled creating place before address has been decoded
        destroyPlaceContext()
        
        createPlaceDialogView.isHidden = true
    }
    
    // Show annotation when creating place
    private func mountPlaceContext(placeContext: PlaceContext?) {
        guard let annotation = placeContext?.annotation else { return }
        
        mapView.addAnnotation(annotation)
        mapView.setCenter(annotation.coordinate, animated: true)
    }
    
    // Remove annotation when creating place
    private func unmountPlaceContext() {
        guard let annotation = placeContext?.annotation else { return }
        mapView.removeAnnotation(annotation)
    }
    
    @IBAction private func createPlaceDialogNoButtonPressed(_ sender: UIButton) {
        unmountPlaceContext()
        
        createPlaceDialogView.isHidden = true
        centerOnLocationButton.isHidden = false
        
        mountGeocontext()
    }
    
    @IBAction private func createPlaceDialogYesButtonPressed(_ sender: UIButton) {
        // Check if user is logged into iCloud on iPhone
        if isICloudKitContainerAvailable() {
            createPlaceDialogView.isHidden = true
            
            unmountPlaceContext()
            
            performSegue(withIdentifier: "createPlaceDialog", sender: self)
        } else {
            showAlert(title: "No iCloud account!", message: "To create new place you need to login to your iCloud account in your settings.", confirmTitle: "Ok", handler: nil)
        }
    }
    
    private func isICloudKitContainerAvailable() -> Bool {
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
        if segue.identifier == "showPlace" {
            if let vc = segue.destination as? ShowPlaceTableViewController {
                vc.placeContext = placeContext
            }
        }

    }
    
    @IBAction func unwindToMapViewController(segue: UIStoryboardSegue) {
        if segue.source is CreatePlaceIndicatorViewController {
            // Add created place
            mountGeocontext()
        }
    }
    
    @objc func deleteAnnotation(_ notification: Notification){
        // Parse data and delete annotation
        if let data = notification.userInfo as? [String: String], let id = data["id"], let annotation = geoContext?.deleteAnnotation(with: id) {
            
            mapView.removeAnnotation(annotation)
        }
    }
    
    @objc func changeAnnotation(_ notification: Notification){
        // Parse data and change annotation
        if let data = notification.userInfo as? [String: String] {
            
            guard let id = data["id"],
                let title = data["title"],
                let cathegory = data["cathegory"],
                let annotation = geoContext?.changeAnnotation(id: id, title: title, cathegory: cathegory)
                else { return }
            
            mapView.removeAnnotation(annotation)
            mapView.addAnnotation(annotation)
        }
    }
}

// MARK: Location manager delegate

extension MapViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // Execute only for the first time
        if mapCentered == false, let location = locations.first {
            // Initialization of GeoContext when location is obtained for the firs time
            centerMapOnUserLocation(location: location, radius: regionRadius)

            let cathegory = cathegories.selectedCathegory()
            
            newGeocontext(coordinate: location.coordinate, radius: regionRadius, cathegory: cathegory)
            
            mapCentered = true
        }
    }
}

// MARK: MKMapView delegate

extension MapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        checkIfGeoContextCanBeUpdated()
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if view.annotation is MKUserLocation {
            // Check if user selected current location
            guard let location = CustomLocationManager.manager.location?.coordinate else { return }
            
            showCreateNewPlaceDialog(coordinate: location)
        }
        
        if let annotation = view.annotation as? PlaceAnnotation, annotation.id != nil {
            unmountPlaceContext()
            
            createPlaceDialogView.isHidden = true
            centerOnLocationButton.isHidden = false
            
            placeContext = PlaceContext.init(annotation: annotation)
            
            performSegue(withIdentifier: "showPlace", sender: self)
        }
        
        mapView.deselectAnnotation(view.annotation, animated: false)
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
        
        cathegoryLabel.textColor = cathegories.getColorForSelectedIndex()
        cathegoryLineView.backgroundColor = cathegories.getColorForSelectedIndex()
        
        setCancelButton()
        
        // Get new GeoContext
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
        
        // Count width for cell by string
        let width = string.name.width(withConstrainedHeight: height, font: font)
        
        return CGSize(width: width, height: height)
    }
}

// MARK: GeoContext delegate

extension MapViewController: GeoContextDelegate {
    
    func geoContextDidLoadAnnotations(error: Error?) {
        if let _error = error {
            showAlert(title: "Error when loading places!", message: _error.localizedDescription, confirmTitle: "Ok", handler: nil)
            showGeoContextInformationView(text: geoContextErrorMessage)
            setRefreshButton(enabled: true)
            return
        }
        
        loadingIndicatorView.isHidden = true
        
        mountGeocontext()
        setRefreshButton(enabled: false)
    }
}

// MARK: PlaceContext delegate

extension MapViewController: PlaceContextDelegateAdress {
    
    func placeContextDidDecodeAddress(address: String?, error: Error?) {
        createPlaceActivityIndicatorView.isHidden = true
        
        if let _error = error {
            createPlaceDialogView.isHidden = true
            
            unmountPlaceContext()
            
            showAlert(title: "Could not create new place!", message: _error.localizedDescription, confirmTitle: "Ok", handler: nil)
            
            return
        }
        
        createPlaceAddress.text = address!
        
        createPlaceDialogStackView.isHidden = false
    }
}
