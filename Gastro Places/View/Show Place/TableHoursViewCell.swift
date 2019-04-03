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
    @IBOutlet weak var isOpenLabel: UILabel!
    
    func setHours(openingTime: OpeningTime) {
        daysLabel.text = openingTime.stringDays
        hoursLabel.text = openingTime.stringHours
        
        switch openingTime.isOpen() {
        case .open:
            isOpenLabel.text = "Open"
            isOpenLabel.textColor = #colorLiteral(red: 0.0139625147, green: 0.79621768, blue: 0.45854491, alpha: 1)
        case .closed:
            isOpenLabel.text = "Closed"
            isOpenLabel.textColor = #colorLiteral(red: 0.8823529412, green: 0.3450980392, blue: 0.1607843137, alpha: 1)
        case .unknown:
            isOpenLabel.text = ""
        }
        
    }
}
