//
//  Image.swift
//  Gastro Places
//
//  Created by Michal Martinů on 02/04/2019.
//  Copyright © 2019 Michal Martinů. All rights reserved.
//

import UIKit

struct Image {
    var id: String
    var picture: UIImage
    
    init(id: String, picture: UIImage) {
        self.id = id
        self.picture = picture
    }
}
