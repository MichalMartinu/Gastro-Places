//
//  ResizeImage.swift
//  Gastro Places
//
//  Created by Michal Martinů on 21/03/2019.
//  Copyright © 2019 Michal Martinů. All rights reserved.
//

import UIKit

extension UIImage {
    
    func scaled(width: CGFloat) -> UIImage {
        if self.size.height > width {
            
            let heightScale = width / self.size.width
            let size = CGSize(width: width, height: round(self.size.height * heightScale))
            
            UIGraphicsBeginImageContext(size)
            
            draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
            
            let image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            if let _image = image {
                return _image
            }
        }
        return self
    }
}
