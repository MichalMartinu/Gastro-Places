//
//  CreateReviewTableViewCell.swift
//  Gastro Places
//
//  Created by Michal Martinů on 02/04/2019.
//  Copyright © 2019 Michal Martinů. All rights reserved.
//

import UIKit

protocol CreateReviewTableViewCellDelegate: AnyObject {
    func createButtonPressed()
}

class CreateReviewTableViewCell: UITableViewCell {
    
    weak var delegate: CreateReviewTableViewCellDelegate?
    
    @IBAction func createReviewButtonIsPressed(_ sender: Any) {
        delegate?.createButtonPressed()
    }
}
