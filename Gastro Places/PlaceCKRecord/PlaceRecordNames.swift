//
//  PlaceCKRecord.swift
//  Gastro Places
//
//  Created by Michal Martinů on 08/03/2019.
//  Copyright © 2019 Michal Martinů. All rights reserved.
//

import Foundation
import CloudKit

let placeRecord = PlaceCKRecordNames()

struct PlaceCKRecordNames {
    let record = "Place"
    let name = "name"
    let cathegory = "cathegory"
    let city = "city"
    let street = "street"
    let email = "email"
    let location = "location"
    let phone = "phone"
    let web = "web"
    let placeID = "recordName"
}
