//
//  LoadingTableViewCell.swift
//  Gastro Places
//
//  Created by Michal Martinů on 02/04/2019.
//  Copyright © 2019 Michal Martinů. All rights reserved.
//

import UIKit

class LoadingTableViewCell: UITableViewCell {
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    func setSpinning() {
        activityIndicator.startAnimating()
    }
    
}

