//
//  Cathegory.swift
//  Gastro Places
//
//  Created by Michal Martinů on 03/04/2019.
//  Copyright © 2019 Michal Martinů. All rights reserved.
//

import UIKit

enum CathegoryType {
    case all, normal
}

struct Cathegory {
    let name: String
    let color: UIColor
    
    init( name: String, color: UIColor) {
        self.name = name
        self.color = color
    }
}
