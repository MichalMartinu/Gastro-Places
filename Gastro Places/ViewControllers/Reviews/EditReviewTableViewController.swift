//
//  EditReviewTableViewController.swift
//  Gastro Places
//
//  Created by Michal Martinů on 02/04/2019.
//  Copyright © 2019 Michal Martinů. All rights reserved.
//

import UIKit
import Cosmos

class EditReviewTableViewController: UITableViewController {
    
    @IBOutlet weak var reviewTextView: UITextView!
    @IBOutlet weak var reviewStarView: CosmosView!
    
    var reviewsContext: ReviewsContext?
    var placeContext: PlaceContext!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        initReviewTextView()
        initFields()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        navigationController?.setToolbarHidden(true, animated: true)
    }
    
    private func initReviewTextView() {
        reviewTextView.roundCornersLittle()
        reviewTextView.layer.borderColor = UIColor.lightGray.cgColor
        reviewTextView.layer.borderWidth = 1
    }

    
    func initFields() {
        if let userReview = reviewsContext?.currentUserReview {
            reviewStarView.rating = Double(userReview.rating)
            reviewTextView.text = userReview.text
            
            if userReview.cloudID != nil {
                navigationController?.setToolbarHidden(false, animated: true)
            }
        }
    }
    
    @IBAction func cancelButtonIsPressed(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func saveButtonIsPressed(_ sender: Any) {
        performSegue(withIdentifier: "saveReview", sender: self)
    }
    
    func createReviewToSave() -> Review {
        let rating = Int(reviewStarView.rating)
        let text = reviewTextView.text

        return Review(rating: rating, text: text)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "saveReview" {
            if let vc = segue.destination as? SaveReviewViewController {
                vc.reviewsContext = reviewsContext
                vc.review = createReviewToSave()
                vc.placeContext = placeContext
            }
        }
    }
    
    @IBAction func deleteButtonIsPressed(_ sender: Any) {
        showDeleteAlert()
    }
    
    private func showDeleteAlert() {
        let alert = UIAlertController(title: "Delete review", message: "Do you really want to delete review", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "No", style: .default, handler: nil))
        alert.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: deleteReview))
        
        self.present(alert, animated: true)
    }
    
    private func deleteReview(alert: UIAlertAction?) {
        reviewsContext?.deleteUserReview()
    }
    
    
}
