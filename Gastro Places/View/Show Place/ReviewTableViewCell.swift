//
//  ShowPlaceReviewTableViewCell.swift
//  Gastro Places
//
//  Created by Michal Martinů on 02/04/2019.
//  Copyright © 2019 Michal Martinů. All rights reserved.
//

import UIKit
import Cosmos

class ShowPlaceReviewTableViewCell: UITableViewCell {
    @IBOutlet weak var ratingView: CosmosView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var textReviewLabel: UILabel!
    
    func setValues(review: Review) {
        ratingView.rating = Double(review.rating)
        dateLabel.text = getFormatedDate(date: review.date)
        textReviewLabel.text = review.text
    }
    
    private func getFormatedDate(date: Date?) -> String? {
        let dateFormatterPrint = DateFormatter()
        dateFormatterPrint.dateFormat = "MMM dd yyyy"
        
        guard let _date = date else { return nil }
        
        return dateFormatterPrint.string(from: _date)
    }
    
}
