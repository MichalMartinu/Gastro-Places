//
//  PlaceRepresentation.swift
//  Gastro Places
//
//  Created by Michal Martinů on 22/03/2019.
//  Copyright © 2019 Michal Martinů. All rights reserved.
//

import UIKit

enum CellTypes: String {
    case image = "imageTableViewCell"
    case text = "textTableViewCell"
    case link = "linkTableViewCell"
    case hour = "hourTableViewCell"
    case space = "spaceTableViewCell"
}

class TextCell {
    var text: String
    var bold: Bool
    var size: CGFloat?
    var color: UIColor?
    
    init(text: String, bold: Bool, size: CGFloat?, color: UIColor?) {
        self.text = text
        self.bold = bold
        self.size = size
        self.color = color
    }
}

class LinkCell {
    var link: String
    var type: LinkType
    
    init(link: String, type: LinkType) {
        self.link = link
        self.type = type
    }
}

class PlaceCell {
    var cell: CellTypes
    var data: Any?
    
    init(type: CellTypes) {
        self.cell = type
    }
    
    init(type: CellTypes, data: Any) {
        self.cell = type
        self.data = data
    }
}

class PlaceRepresentation {
    
    var cells = [PlaceCell]()
    
    func initFromPlace(placeContext: PlaceContext, openingTime: OpeningTime) {
        let place = placeContext.place
                
        cells.append(PlaceCell.init(type: CellTypes.space))
        
        if let _name = place.name {
            cells.append(basicTextCell(text: _name, bold: true, size: 32, color: nil))
        }
        
        if let _cathegory = place.cathegory {
            cells.append(basicTextCell(text: _cathegory, bold: false, size: 24, color: PlacesCathegories.colorForCathegory(cathegory: _cathegory)))
        }
        
        if let _address = place.address?.full {
            cells.append(basicTextCell(text: _address, bold: false, size: nil, color: nil))
        }
        
        cells.append(hourCell(openintTime: openingTime))
        
        if let _phone = place.phone, _phone.count != 0 {
            cells.append(linkCell(link: _phone, type: .phone))
        }
        
        if let _web = place.web, _web.count != 0 {
            cells.append(linkCell(link: _web, type: .web))
        }
        
        if let _email = place.email, _email.count != 0 {
            cells.append(linkCell(link: _email, type: .email))
        }
        
    }
    
    func appendImageCell() {
        cells.insert(PlaceCell.init(type: CellTypes.image), at: 0)
    }
    
    
    func basicTextCell(text: String, bold: Bool, size: CGFloat?, color: UIColor?) -> PlaceCell {
        let textCell = TextCell.init(text: text, bold: bold, size: size, color: color)
        let placeCell = PlaceCell.init(type: .text, data: textCell)
        
        return placeCell
    }
    
    func linkCell(link: String, type: LinkType) -> PlaceCell {
        let linkCell = LinkCell.init(link: link, type: type)
        let placeCell = PlaceCell.init(type: .link, data: linkCell)
        return placeCell
    }
    
    func hourCell(openintTime: OpeningTime) -> PlaceCell {
        let placeCell = PlaceCell.init(type: .hour, data: openintTime)
        return placeCell
    }
    
    func changeOpeningTime(openingTime: OpeningTime) -> Int? {
        for (index, cell) in cells.enumerated() {
            if cell.cell == .hour {
                cell.data = openingTime
                return index
            }
        }
        
        return nil
    }
}
