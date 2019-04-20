//
//  SearchViewController.swift
//  Gastro Places
//
//  Created by Michal Martinů on 14/03/2019.
//  Copyright © 2019 Michal Martinů. All rights reserved.
//

import UIKit
import CoreLocation

class SearchViewController: UIViewController {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var resultsTableView: UITableView!
    
    var searchContext = SearchContext()
    
    var selectedIndex: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchBar.delegate = self
        
        resultsTableView.dataSource = self
        resultsTableView.delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(deletePlace(_:)), name: .didDeletePlace, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(changePlace(_:)), name: .didChangePlace, object: nil)

    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showPlaceFromSearch" {
            if let index = selectedIndex, let vc = segue.destination as? ShowPlaceTableViewController {
                vc.placeContext = searchContext.places[index]
            }
        }
        
    }
    
    @objc func deletePlace(_ notification: Notification){
        if let data = notification.userInfo as? [String: String], let id = data["id"], let index = searchContext.deletePlace(with: id) {
            let indexPath = IndexPath(row: index, section: 0)
            resultsTableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
    
    @objc func changePlace(_ notification: Notification){
        if let data = notification.userInfo as? [String: String] {
            
            guard let id = data["id"],
                let title = data["title"],
                let cathegory = data["cathegory"],
                let index = searchContext.changePlace(id: id, title: title, cathegory: cathegory)
                else { return }
            
            let indexPath = IndexPath(row: index, section: 0)
            resultsTableView.reloadRows(at: [indexPath], with: .automatic)
        }
    }
}

extension SearchViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchContext.places.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "placeCell") as! PlaceTableViewCell
        
        let place = searchContext.places[indexPath.row]
        
        var distance: CLLocationDistance? = nil
        
        if let currentLocation = CustomLocationManager.manager.location {
            
            distance = place.place.location!.distance(from: currentLocation)
        }
        
            
        cell.setValues(placeContext: place, distance: distance)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedIndex = indexPath.row
        performSegue(withIdentifier: "showPlaceFromSearch", sender: self)
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
    
}

extension SearchViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchContext = SearchContext()
        searchContext.delegate = self
        
        searchContext.fetchCloudkitPlaces(stringToMatch: searchBar.text)

        searchBar.resignFirstResponder()
        
        searchBar.setShowsCancelButton(true, animated: true)
        
        if let cancelButton = searchBar.value(forKey: "cancelButton") as? UIButton {
        cancelButton.isEnabled = true
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(false, animated: true)
        searchBar.text = ""
        searchContext = SearchContext()
        resultsTableView.reloadData()
    }
    
    @IBAction func unwindToSearchViewController(segue: UIStoryboardSegue) {
        if segue.source is CreatePlaceIndicatorViewController {

        }
    }
}

extension SearchViewController: SearchContextDelegate {
    func searchContextLoadedPlace() {
        resultsTableView.reloadData()
    }
}
