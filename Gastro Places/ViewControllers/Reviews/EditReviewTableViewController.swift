//
//  EditReviewTableViewController.swift
//  Gastro Places
//
//  Created by Michal Martinů on 02/04/2019.
//  Copyright © 2019 Michal Martinů. All rights reserved.
//

import UIKit

class EditReviewTableViewController: UITableViewController {
    
    @IBOutlet weak var reviewTextView: UITextView!
    
    var reviewsContext: ReviewsContext?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initReviewTextView()
        initFields()
    }
    
    private func initReviewTextView() {
        reviewTextView.roundCornersLittle()
        reviewTextView.layer.borderColor = UIColor.lightGray.cgColor
        reviewTextView.layer.borderWidth = 1
    }

    
    func initFields() {
        if let userReview = reviewsContext?.currentUserReview {
            // TODO rating
            //reviewTextField.text = userReview.text
        } //TODO else pak s rating
    }
    
    @IBAction func cancelButtonIsPressed(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func saveButtonIsPressed(_ sender: Any) {
        performSegue(withIdentifier: "saveReview", sender: self)
    }
    
    func createReviewToSave() -> Review {
        let rating = 1
        let text = reviewTextView.text

        return Review(rating: rating, text: text)

    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "saveReview" {
            if let vc = segue.destination as? SaveReviewViewController {
                vc.reviewsContext = reviewsContext
                vc.review = createReviewToSave()
            }
        }
    }
    
}
