//
//  CreateImageTableViewCell.swift
//  Gastro Places
//
//  Created by Michal Martinů on 14/03/2019.
//  Copyright © 2019 Michal Martinů. All rights reserved.
//

import UIKit

class CreateImageTableViewCell: UITableViewCell {
    
    @IBOutlet weak var photoImageView: UIImageView!
    
    func setImage(_ image: UIImage) {
        photoImageView.image = image
    }
}
