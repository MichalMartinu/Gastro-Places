//
//  OpeningTimeTableViewController.swift
//  Gastro Places
//
//  Created by Michal Martinů on 12/03/2019.
//  Copyright © 2019 Michal Martinů. All rights reserved.
//

import UIKit

protocol OpeningTimeTableCellDelegate: AnyObject {
    func tableViewCellDidTappedDaySwitch(sender: OpeningHoursTableViewCell, from: Time?, to: Time?)
    func tableViewCellDidChangedValue(sender: OpeningHoursTableViewCell, from: Time, to: Time)
}


class OpeningTimeTableViewController: UITableViewController, OpeningTimeTableCellDelegate {
    
    var openingTime: OpeningTime!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.tabBar.isHidden = false
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "OpeningHoursTableViewCell", for: indexPath) as! OpeningHoursTableViewCell
        cell.delegate = self
        cell.setValues(day: openingTime!.days[indexPath.row], times: openingTime!.times)
        return cell
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return openingTime.days.count
    }
    
    func tableViewCellDidTappedDaySwitch(sender: OpeningHoursTableViewCell,  from: Time?, to: Time?) {
        guard let indexPath = tableView.indexPath(for: sender) else { return }
        openingTime.setDay(indexPath: indexPath.row, from: from, to: to)
        tableView.reloadData()
    }
    
    func tableViewCellDidChangedValue(sender: OpeningHoursTableViewCell, from: Time, to: Time) {
        guard let indexPath = tableView.indexPath(for: sender) else { return }
        openingTime.setDay(indexPath: indexPath.row, from: from, to: to)
    }
    
}
