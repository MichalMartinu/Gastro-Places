//
//  ShowPlaceImageCollectionViewCell.swift
//  Gastro Places
//
//  Created by Michal Martinů on 24/03/2019.
//  Copyright © 2019 Michal Martinů. All rights reserved.
//

import UIKit

class ShowPlaceImageCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var labelik: UILabel!
    
    var id: String?
    
    func setLabel(text: String) {
        labelik.text = text
    }
}
