//
//  ShowPlaceImageCollectionViewCell.swift
//  Gastro Places
//
//  Created by Michal Martinů on 24/03/2019.
//  Copyright © 2019 Michal Martinů. All rights reserved.
//

import UIKit

class ShowPlaceImageCollectionViewCell: UICollectionViewCell, ImageContextDelegateCell {
    
    @IBOutlet weak var pictureImageView: UIImageView!
    @IBOutlet weak var loadingView: UIView!
    
    
    var id: String?
    
    func setCell(image: UIImage?) {
        if let _image = image {
            pictureImageView.image = _image
            showImage()
        } else {
            showLoadingView()
        }
    }
    
    func imageLoaded(image: UIImage, id: String) {
        if self.id == id {
            pictureImageView.image = image
            showImage()
        }
    }
    
    private func showLoadingView() {
        loadingView.isHidden = false
        pictureImageView.isHidden = true
    }
    
    private func showImage() {
        loadingView.isHidden = true
        pictureImageView.isHidden = false
    }
}
