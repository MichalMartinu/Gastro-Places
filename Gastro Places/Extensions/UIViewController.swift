//
//  UIViewController.swift
//  Gastro Places
//
//  Created by Michal Martinů on 18/04/2019.
//  Copyright © 2019 Michal Martinů. All rights reserved.
//

import UIKit

extension UIViewController {
    func showAlert(title: String?, message: String?, confirmTitle: String?, handler: ((UIAlertAction) -> Void)?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        
        alert.addAction(UIAlertAction(title: confirmTitle, style: UIAlertAction.Style.default, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
    }

}
