//
//  ShowPlaceTableWebViewCell.swift
//  Gastro Places
//
//  Created by Michal Martinů on 22/03/2019.
//  Copyright © 2019 Michal Martinů. All rights reserved.
//

import UIKit

enum LinkType {
    case web
    case email
    case phone
}

class ShowPlaceTableWebViewCell: UITableViewCell {
    
    @IBOutlet weak var webButton: UIButton!
    
    var link: String?
    var type: LinkType?
    
    func setWeb(linkCell: LinkCell) {
        webButton.setTitle(linkCell.link, for: .normal)
        self.link = linkCell.link
        self.type = linkCell.type
    }
    
    @IBAction func webButtonIsPressed(_ sender: Any) {
        guard let _link = link else { return }
        
        var url: URL?
        switch type {
        case .web?:
            if _link.hasPrefix("http") {
                url = URL(string: _link)
            } else {
                url = URL(string: "http://\(_link)")
            }
        case .email?:
            url = URL(string: "mailto:\(_link)")
        case .phone?:
            url = URL(string:  "tel://\(_link)")
        case .none:
            return
        }
    
        UIApplication.shared.open(url!)

    }
}
