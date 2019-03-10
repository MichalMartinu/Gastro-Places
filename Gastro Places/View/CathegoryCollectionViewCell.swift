//
//  CathegoryCollectionView.swift
//  Gastro Places
//
//  Created by Michal Martinů on 09/03/2019.
//  Copyright © 2019 Michal Martinů. All rights reserved.
//

import UIKit

class CathegoryCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var textLabel: UILabel!
    
    func initData(color: UIColor, text: String, selected: Bool) {
        textLabel.text = text
        textLabel.textColor = color
        
        if selected == true {
            textLabel.font = UIFont.boldSystemFont(ofSize: 18.0)
        } else {
            textLabel.font = UIFont.systemFont(ofSize: 16.0)
        }
    }
}
