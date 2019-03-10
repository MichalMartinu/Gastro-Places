//
//  String.swift
//  Gastro Places
//
//  Created by Michal Martinů on 10/03/2019.
//  Copyright © 2019 Michal Martinů. All rights reserved.
//

import UIKit

extension String {    
    func width(withConstrainedHeight height: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: height)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [.font: font], context: nil)
        
        return ceil(boundingBox.width)
    }
}
