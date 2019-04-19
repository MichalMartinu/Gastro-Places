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
    
    let searchContext = SearchContext()
    
    var selectedIndex: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchBar.delegate = self
        searchContext.delegate = self
        resultsTableView.dataSource = self
        resultsTableView.delegate = self
        
        searchContext.fetchCloudkitPlaces(stringToMatch: "b")
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showPlaceFromSearch" {
            if let index = selectedIndex, let vc = segue.destination as? ShowPlaceTableViewController {
                vc.placeContext = searchContext.places[index]
            }
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
        searchBar.resignFirstResponder()
    }
}

extension SearchViewController: SearchContextDelegate {
    func searchContextLoadedPlace() {
        resultsTableView.reloadData()
    }
}
