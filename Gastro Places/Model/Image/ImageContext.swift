//
//  ImageContext.swift
//  Gastro Places
//
//  Created by Michal Martinů on 14/03/2019.
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

class ImageContext {
    
    var images = [Image]()
    private var imagesToDelete = [String]()
    private var imagesToSave = [String]()
    
    func insertNewImage(image: UIImage) {
        let uuid = UUID().uuidString
        images.append(Image.init(id: uuid, picture: image))
        imagesToSave.append(uuid)
    }
    
    func getImagesToSave() -> [Image] {
        var images = [Image]()
        for id in imagesToSave {
            let image = self.images.filter { $0.id == id }
            
            if let _image = image.first {
                images.append(_image)
            }
        }
        return images
    }
    
    func deleteImageAtIndex(index: Int) {
        if let saveIndex = imagesToSave.firstIndex(of: images[index].id) {
            imagesToSave.remove(at: saveIndex)
        }
        
        images.remove(at: index)
    }
}
