//
//  Cathegories.swift
//  Gastro Places
//
//  Created by Michal Martinů on 09/03/2019.
//  Copyright © 2019 Michal Martinů. All rights reserved.
//

import UIKit

class Cathegories: NSObject {
    
    let cathegories: [Cathegory]
    
    var selectedIndex = 0 // Index of currently selected cathegory (default all)
    
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
        return cathegories.firstIndex(where: { $0.name == cathegory })
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
            // When cathegory is selected
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
