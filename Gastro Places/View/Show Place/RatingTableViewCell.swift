//
//  RatingTableViewCell.swift
//  Gastro Places
//
//  Created by Michal Martinů on 20/04/2019.
//  Copyright © 2019 Michal Martinů. All rights reserved.
//

import UIKit
import Cosmos

class RatingTableViewCell: UITableViewCell {
    @IBOutlet weak var ratingView: CosmosView!
    
    func setData(count: Int, rating: Double) {
        
        ratingView.rating = rating
        ratingView.text = "(\(count))"
    }
    
}

