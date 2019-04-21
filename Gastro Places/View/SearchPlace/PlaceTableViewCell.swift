//
//  PlaceCell.swift
//  Gastro Places
//
//  Created by Michal Martinů on 19/04/2019.
//  Copyright © 2019 Michal Martinů. All rights reserved.
//

import UIKit
import CoreLocation

class PlaceTableViewCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    
    func setValues(placeContext: PlaceContext, distance: CLLocationDistance?) {
        
        titleLabel.text = placeContext.place.name
        subtitleLabel.text = placeContext.place.cathegory
        subtitleLabel.textColor = PlacesCathegories.colorForCathegory(cathegory: placeContext.place.cathegory!)
        
        if let _distance = distance {
            let distanceInKM: Double = (_distance / 1000)
            if distanceInKM < 1 {
                distanceLabel.text = "\(String(format: "%.0f", _distance)) m"
            } else {
                distanceLabel.text = "\(String(format: "%.2f", distanceInKM)) km"
            }
        } else {
            distanceLabel.text = ""
        }
    }
    
}
