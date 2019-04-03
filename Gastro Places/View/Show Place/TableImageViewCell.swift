//
//  ShowPlaceTableImageViewCell.swift
//  Gastro Places
//
//  Created by Michal Martinů on 24/03/2019.
//  Copyright © 2019 Michal Martinů. All rights reserved.
//

import UIKit

class ShowPlaceTableImageViewCell: UITableViewCell {
    
    @IBOutlet weak var imageCollectionView: UICollectionView!
    @IBOutlet weak var loadingView: UIView!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    
    func loaded() {
        loadingView.isHidden = true
        imageCollectionView.isHidden = false
        
        imageCollectionView.reloadData()
        
        loadingIndicator.stopAnimating()
    }
    
    func reload() {
        imageCollectionView.reloadData()
    }
    
    func setSpinning() {
        loadingIndicator.startAnimating()
    }
}
