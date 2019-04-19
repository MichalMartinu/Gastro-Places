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
    case review = "reviewTableViewCell"
    case createReview = "createReviewTableViewCell"
    case userReview = "userReviewTableViewCell"
    case loading = "loadingTableViewCell"
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
    
    var userReviewIndex: Int?
    
    func initFromPlace(placeContext: PlaceContext, openingTime: OpeningTime) {
        let place = placeContext.place
        
        cells.append(PlaceCell.init(type: CellTypes.image))
                
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
        
        cells.append(PlaceCell.init(type: CellTypes.space))

        cells.append(basicTextCell(text: "Reviews", bold: true, size: 18, color: nil))
        cells.append(PlaceCell.init(type: CellTypes.loading))
    }
    
    func changeImageCell() {
        cells[0] = PlaceCell.init(type: CellTypes.image)
    }
    
    private func basicTextCell(text: String, bold: Bool, size: CGFloat?, color: UIColor?) -> PlaceCell {
        let textCell = TextCell.init(text: text, bold: bold, size: size, color: color)
        let placeCell = PlaceCell.init(type: .text, data: textCell)
        
        return placeCell
    }
    
    private func linkCell(link: String, type: LinkType) -> PlaceCell {
        let linkCell = LinkCell.init(link: link, type: type)
        let placeCell = PlaceCell.init(type: .link, data: linkCell)
        return placeCell
    }
    
    private func hourCell(openintTime: OpeningTime) -> PlaceCell {
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
    
    private func createNewReviewCell() -> PlaceCell {
        let placeCell = PlaceCell.init(type: .createReview)
        return placeCell
    }
    
    private func createUserReviewCell() -> PlaceCell {
        let placeCell = PlaceCell.init(type: .userReview)
        return placeCell
    }
    
    private func createReviewCell(review: Review) -> PlaceCell {
        let placeCell = PlaceCell.init(type: .review, data: review)
        return placeCell
    }
    
    func changeUserReview(userReview: Review?) -> Int? {
        guard let index = userReviewIndex else { return nil }

        if let _userReview = userReview {
            cells[index] = createReviewCell(review: _userReview)
        } else {
            cells[index] = createNewReviewCell()
        }
        
        return index
    }
    
    func changeReviews(userReview: Review?, reviews: [Review]) {
        cells.removeLast()
        cells.removeLast()
        
        cells.append(createUserReviewCell())
        
        if let _userReview = userReview {
            cells.append(createReviewCell(review: _userReview))
        } else {
            cells.append(createNewReviewCell())
        }
        userReviewIndex = cells.count - 1
        
        if reviews.count == 0 {
            return
        }
        
        cells.append(PlaceCell.init(type: CellTypes.space))
        cells.append(basicTextCell(text: "Reviews", bold: true, size: 17, color: nil))
        
        for review in reviews {
            cells.append(createReviewCell(review: review))
        }

    }
}
