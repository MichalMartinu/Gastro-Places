//
//  ImageContext.swift
//  Gastro Places
//
//  Created by Michal Martinů on 14/03/2019.
//  Copyright © 2019 Michal Martinů. All rights reserved.
//

import UIKit

struct Image {
    var id: String?
    var picture: UIImage
    
    init(id: String?, picture: UIImage) {
        self.id = id
        self.picture = picture
    }
}

class ImageContext {
    
    var images = [Image]()
    var imagesToDelete = [String]()
    var imagesToSave = [String]()
    
    func insertNewImage(image: UIImage) {
        let uuid = UUID().uuidString
        images.append(Image.init(id: uuid, picture: image))
        imagesToSave.append(uuid)
    }
    
    func deleteImageAtIndex(index: Int) {
        if let _id = images[index].id {
            if let saveIndex = imagesToSave.firstIndex(of: _id) {
                imagesToSave.remove(at: saveIndex)
            }
            
            images.remove(at: index)
        }
    }
    
}
