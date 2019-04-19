//
//  SaveReviewViewController.swift
//  Gastro Places
//
//  Created by Michal Martinů on 02/04/2019.
//  Copyright © 2019 Michal Martinů. All rights reserved.
//

import UIKit

class SaveReviewViewController: UIViewController {
    var reviewsContext: ReviewsContext!
    var placeContext: PlaceContext!
    var review: Review!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.isNavigationBarHidden = true
        
        reviewsContext.delegateSave = self
        
        guard let place = placeContext.placeCoreData else { return }
        
        reviewsContext.saveToCloudkit(review: review, place: place)
    }
    
    
    func backToMap(alert: UIAlertAction!) {
        navigationController?.isNavigationBarHidden = false
        performSegue(withIdentifier: "showPlace", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showPlace" {
            if let vc = segue.destination as? ShowPlaceTableViewController {
                vc.reviewsContext.changeCurrentUserReview(with: reviewsContext.currentUserReview!)
            }
        }
    }
    
}

extension SaveReviewViewController: ReviewsContextSaveDelegate {
    func reviewSaved(error: Error?) {
        
        if let _error = error {
            showAlert(title: "Error when saving review!", message: _error.localizedDescription, confirmTitle: "Ok", handler: backToMap)
            return
        }
        
        navigationController?.isNavigationBarHidden = false
        performSegue(withIdentifier: "showPlace", sender: self)
    }
}
