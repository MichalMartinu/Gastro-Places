//
//  ShowPlaceViewController.swift
//  Gastro Places
//
//  Created by Michal Martinů on 22/03/2019.
//  Copyright © 2019 Michal Martinů. All rights reserved.
//

import UIKit

class ShowPlaceTableViewController: UITableViewController, PlaceContextDelegateLoad, OpeningTimeDelegate {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var cathegoryLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var webLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    
    @IBOutlet weak var phoneCell: UITableViewCell!
    @IBOutlet weak var webCell: UITableViewCell!
    @IBOutlet weak var emailCell: UITableViewCell!
    
    
    var placeContext: PlaceContext!
    var openingTime = OpeningTime(intervalInMinutes: 15)
    var placeRepresentation = PlaceRepresentation()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        placeContext.delegateLoad = self
        placeContext.loadPlace()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.tabBar.isHidden = false
    }
    
    func placeContextLoadedPlace() {
        placeRepresentation.initFromPlace(placeContext: placeContext, openingTime: openingTime)
        if let _placeID = placeContext.place.placeID {
            openingTime.delegate = self
            openingTime.fetchOpeningHours(placeID: _placeID)
        }
        
        tableView.reloadData()
    }
    
    func openingTimeDidLoad() {
        guard let index = placeRepresentation.changeOpeningTime(openingTime: openingTime) else {
            return
        }
        let indexPath = IndexPath.init(row: index, section: 0)
        tableView.reloadRows(at: [indexPath], with: .none)
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let place = placeRepresentation.cells[indexPath.row]
        
        switch place.cell {
        case .image:
            let cell = tableView.dequeueReusableCell(withIdentifier: place.cell.rawValue, for: indexPath)
            return cell
        case .text:
            let cell = tableView.dequeueReusableCell(withIdentifier: place.cell.rawValue, for: indexPath) as! ShowPlaceTableTextViewCell
            let textData = place.data as! TextCell
            cell.setText(textData)
            return cell
        case .web:
            let cell = tableView.dequeueReusableCell(withIdentifier: place.cell.rawValue, for: indexPath) as! ShowPlaceTableWebViewCell
            let textData = place.data as! LinkCell
            cell.setWeb(linkCell: textData)
            return cell
        case .hour:
            let cell = tableView.dequeueReusableCell(withIdentifier: place.cell.rawValue, for: indexPath) as! ShowPlaceTableHoursViewCell
            let textData = place.data as! OpeningTime
            cell.setHours(openingTime: textData)
            return cell
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return placeRepresentation.cells.count
    }
}
