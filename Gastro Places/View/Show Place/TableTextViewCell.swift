//
//  ShowPlaceTableViewController.swift
//  Gastro Places
//
//  Created by Michal Martinů on 22/03/2019.
//  Copyright © 2019 Michal Martinů. All rights reserved.
//

import UIKit

class ShowPlaceTableTextViewCell: UITableViewCell {
    
    @IBOutlet weak var itemTextLabel: UILabel!
    
    private var defaultFontSize: CGFloat = 17.0
    
    func setText(_ textCell: TextCell) {
        itemTextLabel.text = textCell.text
        
        if textCell.bold == true {
            itemTextLabel.font = UIFont.boldSystemFont(ofSize: defaultFontSize)
        } else {
            itemTextLabel.font = UIFont.systemFont(ofSize: defaultFontSize)
        }
        
        itemTextLabel.textColor = textCell.color
        
        if let _size = textCell.size {
            itemTextLabel.font = itemTextLabel.font.withSize(_size)
        } else {
            itemTextLabel.font = itemTextLabel.font.withSize(defaultFontSize)
        }
        
    }
}
