//
//  CreatePlaceIndicatorViewController.swift
//  Gastro Places
//
//  Created by Michal Martinů on 21/03/2019.
//  Copyright © 2019 Michal Martinů. All rights reserved.
//

import UIKit

class CreatePlaceIndicatorViewController: UIViewController, PlaceContextDelegateSave {
    
    var placeContext: PlaceContext!
    var imageContext: ImageContext!
    var openingTime: OpeningTime!
    
    private var annotation: PlaceAnnotation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        placeContext.delegateSave = self
        placeContext.save(days: openingTime.days, images: imageContext)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.isNavigationBarHidden = false
    }
    
    func placeContextSaved(annotation: PlaceAnnotation?, error: Error?) {
        FileManager.default.clearTmpDirectory()
        
        if let _error = error {
            showAlert(title: "Cannot create place!", message: _error.localizedDescription, confirmTitle: "Ok")
            self.annotation = nil
            return
        } else {
            if let _annotation = annotation {
                self.annotation = _annotation
            }
        }
        navigationController?.isNavigationBarHidden = false
        performSegue(withIdentifier: "unwindToMapViewController", sender: self)
    }
    
    private func showAlert(title: String?, message: String?, confirmTitle: String?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: confirmTitle, style: UIAlertAction.Style.default, handler: backToMap))
        self.present(alert, animated: true, completion: nil)
    }
    
    func backToMap(alert: UIAlertAction!) {
        performSegue(withIdentifier: "unwindToMapViewController", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "unwindToMapViewController" {
            if let vc = segue.destination as? MapViewController {
                if let _annotation = annotation {
                    vc.geoContext?.appendAnnotation(_annotation)
                }
            }
        }
    }
}
