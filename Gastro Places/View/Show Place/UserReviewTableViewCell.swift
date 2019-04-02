//
//  MyReviewTableViewCell.swift
//  Gastro Places
//
//  Created by Michal Martinů on 02/04/2019.
//  Copyright © 2019 Michal Martinů. All rights reserved.
//

import UIKit

class UserReviewTableViewCell: UITableViewCell {
    
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    
    @IBOutlet weak var deleteButtonIsPressed: UIButton!
    @IBOutlet weak var editButtonIsPressed: UIButton!
    
    func showButtons(with value: Bool) {
        editButton.isHidden = !value
        deleteButton.isHidden = !value
    }
    
}
