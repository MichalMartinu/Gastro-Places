//
//  OpeningHoursTableViewCell.swift
//  Gastro Places
//
//  Created by Michal Martinů on 12/03/2019.
//  Copyright © 2019 Michal Martinů. All rights reserved.
//

import UIKit

class OpeningHoursTableViewCell: UITableViewCell {
    
    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var switchLabel: UISwitch!
    @IBOutlet weak var hourPickerView: UIPickerView!
    
    weak var delegate: OpeningTimeTableCellDelegate?
    var times = [Time]()
    
    func setValues(day: Day, times: [Time]){
        dayLabel.text = day.name
        self.times = times
        hourPickerView.delegate = self
        hourPickerView.dataSource = self
        if let _from = day.from, let _to = day.to {
            switchLabel.isOn = true
            hourPickerView.isHidden = false
            guard let indexFrom = indexOfTime(_from.string), let indexTo = indexOfTime(_to.string) else { return }
            hourPickerView.selectRow(indexFrom, inComponent: 0, animated: false)
            hourPickerView.selectRow(indexTo, inComponent: 1, animated: false)
        }
    }
    
    func indexOfTime(_ searched: String) -> Int? {
        for (index, time) in times.enumerated() {
            if time.string == searched {
                return index
            }
        }
        return nil
    }
    
    @IBAction func daySwitchTapped(_ sender: Any) {
        hourPickerView.isHidden.toggle()
        var from: Time?
        var to: Time?
        if hourPickerView.isHidden == false {
            from = times[hourPickerView.selectedRow(inComponent: 0)]
            to = times[hourPickerView.selectedRow(inComponent: 1)]
        }
       
        delegate?.tableViewCellDidTappedDaySwitch(sender: self, from: from, to: to)
    }
}

extension OpeningHoursTableViewCell: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return times.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return times[row].string
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let from = times[hourPickerView.selectedRow(inComponent: 0)]
        let to = times[hourPickerView.selectedRow(inComponent: 1)]
        
        delegate?.tableViewCellDidChangedValue(sender: self, from: from, to: to)
    }
}
