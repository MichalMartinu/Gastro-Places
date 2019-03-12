//
//  String.swift
//  Gastro Places
//
//  Created by Michal Martinů on 10/03/2019.
//  Copyright © 2019 Michal Martinů. All rights reserved.
//

import UIKit

extension String {    
    func width(withConstrainedHeight height: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: height)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [.font: font], context: nil)
        
        return ceil(boundingBox.width)
    }
}

extension String {
    func isValidInput(type: InputTypes) -> Bool {
        var regexPattern = ""
        
        switch type {
        case .email:
            regexPattern = "[A-Z0-9a-z.-_]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,3}"
        case .web:
            let head = "((http|https)://)?([(w|W)]{3}+\\.)?"
            let tail = "\\.+[A-Za-z]{2,3}+(\\.)?+(/(.)*)?"
            regexPattern = head+"+(.)+"+tail
        case .phone:
            regexPattern = "(?:\\+\\d{2}\\s*(?:\\(\\d{2}\\))|(?:\\(\\d{2}\\)))?\\s*(\\d{4,5}\\-?\\d{4})"
        case .name:
            if self.count == 0 {
                return false
            } else {
                return true
            }
        }
        
        do {
            let regex = try NSRegularExpression(pattern: regexPattern)
            let nsString = self as NSString
            let results = regex.matches(in: self, range: NSRange(location: 0, length: nsString.length))
            
            if results.count == 0
            {
                return false
            }
            
            return true
        } catch {
            return false
        }
    }
    
}
