//
//  PlaceCathegories.swift
//  Gastro Places
//
//  Created by Michal Martinů on 03/04/2019.
//  Copyright © 2019 Michal Martinů. All rights reserved.
//

import UIKit

class PlacesCathegories {
    // To add new cathegory add variable here, add to function colorForCathegory and also append to cathegories
    
    static let all = Cathegory(name: "All", color: #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1))
    static let restaurant = Cathegory(name: "Restaurant", color: #colorLiteral(red: 0.3647058904, green: 0.06666667014, blue: 0.9686274529, alpha: 1))
    static let caffe = Cathegory(name: "Caffe", color: #colorLiteral(red: 0.5058823824, green: 0.3372549117, blue: 0.06666667014, alpha: 1))
    static let pub = Cathegory(name: "Pub", color: #colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 1))
    static let pizzeria = Cathegory(name: "Pizzeria", color: #colorLiteral(red: 0.9686274529, green: 0.78039217, blue: 0.3450980484, alpha: 1))
    static let fastfood = Cathegory(name: "FastFood", color: #colorLiteral(red: 0.8078431487, green: 0.02745098062, blue: 0.3333333433, alpha: 1))
    
    class func colorForCathegory(cathegory: String) -> UIColor {
        switch cathegory {
        case all.name:
            return all.color
        case restaurant.name:
            return restaurant.color
        case caffe.name:
            return caffe.color
        case pub.name:
            return pub.color
        case pizzeria.name:
            return pizzeria.color
        case fastfood.name:
            return fastfood.color
        default:
            return UIColor.red
        }
    }
    
    static var cathegories: [Cathegory] {
        var result = [Cathegory]()
        
        result.append(PlacesCathegories.restaurant)
        result.append(PlacesCathegories.caffe)
        result.append(PlacesCathegories.pub)
        result.append(PlacesCathegories.pizzeria)
        result.append(PlacesCathegories.fastfood)
        
        return result
    }
    
    static var cathegoriesWithAll: [Cathegory] {
        var result = [Cathegory]()
        result.append(PlacesCathegories.all)
        result.append(contentsOf: cathegories)
        return result
    }
}
