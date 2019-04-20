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
    
    var openingTimeBackup: OpeningTime!
    var imageContextBackup: ImageContext!

    
    var sourceIsShowPlace = false

    var segueIdentifier: String {
        if sourceIsShowPlace == true {
            return "backToShowPlace"
        } else {
            return "unwindToMapViewController"
        }
    }
    
    private var annotation: PlaceAnnotation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        placeContext.delegateSave = self
        placeContext.save(openingTime: openingTime, images: imageContext)
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
            showAlert(title: "Cannot create place!", message: _error.localizedDescription, confirmTitle: "Ok", handler: backToMap)
            self.annotation = nil
            return
        } else {
            if let _annotation = annotation {
                self.annotation = _annotation
            }
        }
        navigationController?.isNavigationBarHidden = false
        performSegue(withIdentifier: segueIdentifier, sender: self)
    }
    
    func backToMap(alert: UIAlertAction!) {
        performSegue(withIdentifier: segueIdentifier, sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "unwindToMapViewController" {
            if let vc = segue.destination as? MapViewController {
                if let _annotation = annotation {
                    vc.geoContext?.appendAnnotation(_annotation)
                }
            }
        }
        if segue.identifier == "backToShowPlace" {
            imageContext.deleteCreatedImages()
            
            guard let placeID = placeContext.place.placeID, let title = placeContext.place.name, let cathegory = placeContext.place.cathegory else { return }
            
            let data = ["id": placeID, "title": title, "cathegory": cathegory]
            
            NotificationCenter.default.post(name: .didChangePlace, object: nil, userInfo: data)

        }
    }
}
