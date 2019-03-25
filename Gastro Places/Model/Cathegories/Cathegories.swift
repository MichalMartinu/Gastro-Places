//
//  Cathegories.swift
//  Gastro Places
//
//  Created by Michal Martinů on 09/03/2019.
//  Copyright © 2019 Michal Martinů. All rights reserved.
//

import UIKit

enum CathegoryType {
    case all, normal
}

struct CathegoryAndColor {
    let name: String
    let color: UIColor
    
    init( name: String, color: UIColor) {
        self.name = name
        self.color = color
    }
}

let placesCathegories = PlacesCathegories()

class PlacesCathegories {
    // To add new cathegory add variable here, add to function colorForCathegory and also append to cathegories
    static let all = CathegoryAndColor(name: "All", color: #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1))
    static let restaurant = CathegoryAndColor(name: "Restaurant", color: #colorLiteral(red: 0.3647058904, green: 0.06666667014, blue: 0.9686274529, alpha: 1))
    static let caffe = CathegoryAndColor(name: "Caffe", color: #colorLiteral(red: 0.5058823824, green: 0.3372549117, blue: 0.06666667014, alpha: 1))
    static let pub = CathegoryAndColor(name: "Pub", color: #colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 1))
    static let pizzeria = CathegoryAndColor(name: "Pizzeria", color: #colorLiteral(red: 0.9686274529, green: 0.78039217, blue: 0.3450980484, alpha: 1))
    static let fastfood = CathegoryAndColor(name: "FastFood", color: #colorLiteral(red: 0.8078431487, green: 0.02745098062, blue: 0.3333333433, alpha: 1))
    
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
    
    static var cathegories: [CathegoryAndColor] {
        var result = [CathegoryAndColor]()
        
        result.append(PlacesCathegories.restaurant)
        result.append(PlacesCathegories.caffe)
        result.append(PlacesCathegories.pub)
        result.append(PlacesCathegories.pizzeria)
        result.append(PlacesCathegories.fastfood)
        
        return result
    }
    
    static var cathegoriesWithAll: [CathegoryAndColor] {
        var result = [CathegoryAndColor]()
        result.append(PlacesCathegories.all)
        result.append(contentsOf: cathegories)
        return result
    }
}

class Cathegories: NSObject {
    
    let cathegories: [CathegoryAndColor]
    var selectedIndex = 0
    
    init(type: CathegoryType) {
        if type == .all{
            cathegories = PlacesCathegories.cathegoriesWithAll
        } else
        {
            cathegories = PlacesCathegories.cathegories
        }
    }
    
    func selectedCathegory() -> String {
        return cathegories[selectedIndex].name
    }
    
    func getColorForSelectedIndex() -> UIColor {
        return cathegories[selectedIndex].color
    }
    
    func indexForCathegory(_ cathegory: String) -> Int? {
        return cathegories.index(where: { $0.name == cathegory })
    }
}

// MARK: Data source of Mapview
extension Cathegories: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return cathegories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cathegoryCollectionViewCell", for: indexPath) as! CathegoryCollectionViewCell
        let data = cathegories[indexPath.row]
        var selected = false
        
        if indexPath.row == selectedIndex {
            selected = true
        }
        
        cell.initData(color: data.color, text: data.name, selected: selected)
        return cell
    }
}

extension Cathegories: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return cathegories.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return cathegories[row].name
    }
    
}
