//
//  ImageContext.swift
//  Gastro Places
//
//  Created by Michal Martinů on 14/03/2019.
//  Copyright © 2019 Michal Martinů. All rights reserved.
//

import UIKit

class ImageContext {
    
    var images = [UIImage]()
    var imagesToDelete = [UIImage]()
    var imagesToSave = [UIImage]()
    
    func insertImage(image: UIImage) {
        images.append(image)
        imagesToSave.append(image)
    }
    
}
