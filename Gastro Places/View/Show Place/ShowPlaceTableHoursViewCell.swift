//
//  ShowPlaceHoursCell.swift
//  Gastro Places
//
//  Created by Michal Martinů on 23/03/2019.
//  Copyright © 2019 Michal Martinů. All rights reserved.
//

import UIKit

class ShowPlaceTableHoursViewCell: UITableViewCell {
    
    @IBOutlet weak var daysLabel: UILabel!
    @IBOutlet weak var hoursLabel: UILabel!
    
    func setHours(openingTime: OpeningTime) {
        daysLabel.text = openingTime.stringDays
        hoursLabel.text = openingTime.stringHours
    }
}
