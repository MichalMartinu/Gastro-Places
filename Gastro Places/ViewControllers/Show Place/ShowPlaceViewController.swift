//
//  ShowPlaceViewController.swift
//  Gastro Places
//
//  Created by Michal Martinů on 22/03/2019.
//  Copyright © 2019 Michal Martinů. All rights reserved.
//

import UIKit
import MapKit

class ShowPlaceTableViewController: UITableViewController, PlaceContextDelegateLoad, OpeningTimeDelegate, ImageContextDelegate {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var cathegoryLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var webLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    
    @IBOutlet weak var phoneCell: UITableViewCell!
    @IBOutlet weak var webCell: UITableViewCell!
    @IBOutlet weak var emailCell: UITableViewCell!
    
    
    var placeContext: PlaceContext!
    var imageContext = ImageContext()
    var openingTime = OpeningTime(intervalInMinutes: 15)
    private var  placeRepresentation = PlaceRepresentation()
    let reviewsContext = ReviewsContext()
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        openingTime.generateTime()
        
        placeContext.delegateLoad = self
        placeContext.loadPlace()
        
        reviewsContext.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.isNavigationBarHidden = false
        
        if imageContext.imageIDs.count > 0 {
            placeRepresentation.changeImageCell()
        }
        
        if imageContext.state == .Finished, let _placeID = placeContext.place.placeID {
            imageContext = ImageContext()
            imageContext.delegate = self
            imageContext.fetchImageIDs(placeID: _placeID, placeCoreData: placeContext.placeCoreData)
        }
        
        if openingTime.state == .Finished, let _placeID = placeContext.place.placeID {
            openingTime = OpeningTime(intervalInMinutes: 15)
            openingTime.delegate = self
            openingTime.fetchOpeningHours(placeID: _placeID, placeCoreData: placeContext.placeCoreData)
        }
        
        if placeRepresentation.userReviewIndex != nil {
            _ = placeRepresentation.changeUserReview(userReview: reviewsContext.currentUserReview)
        }
        
        tableView.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationController?.setToolbarHidden(false, animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setToolbarHidden(true, animated: false)
    }
    
    func placeContextLoadedPlace() {
        if placeContext.state == .Failed {
            showAlert(title: "Error", message: "Some error occurred, try again later please.", confirmTitle: "Ok", handler: popViewController)
            return
        }
        placeRepresentation.initFromPlace(placeContext: placeContext, openingTime: openingTime)
        if let _placeID = placeContext.place.placeID {
            openingTime.delegate = self
            openingTime.fetchOpeningHours(placeID: _placeID, placeCoreData: placeContext.placeCoreData)
            
            imageContext.delegate = self
            imageContext.fetchImageIDs(placeID: _placeID, placeCoreData: placeContext.placeCoreData)
            
            reviewsContext.delegate = self
            reviewsContext.fetchReviews(placeID: _placeID, place: placeContext.placeCoreData!)
        }
        
        tableView.reloadData()
    }
    
    private func popViewController(alert: UIAlertAction!) {
        navigationController?.popViewController(animated: true)
    }
    
    func openingTimeDidLoad() {
        guard let index = placeRepresentation.changeOpeningTime(openingTime: openingTime) else { return }
        let indexPath = IndexPath.init(row: index, section: 0)
        tableView.reloadRows(at: [indexPath], with: .none)
    }
    
    func imageContextDidloadIDs() {
        if imageContext.imageIDs.count > 0 {
            placeRepresentation.changeImageCell()
            tableView.reloadData()
        }
    }
    
    @IBAction func navigateToPlaceButtonIsPressed(_ sender: Any) {
        let latitude = placeContext.annotation.coordinate.latitude
        let longitude = placeContext.annotation.coordinate.longitude
        
        let desitnation = MKMapItem(placemark: MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: latitude, longitude: longitude)))
        desitnation.name = placeContext.place.name
        
        MKMapItem.openMaps(with: [desitnation], launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving])
    }
    
    @IBAction func unwindToShowPlaceViewController(segue: UIStoryboardSegue) {
        if segue.source is CreatePlaceIndicatorViewController {
            placeRepresentation = PlaceRepresentation()
            placeRepresentation.initFromPlace(placeContext: placeContext, openingTime: openingTime)
        }
        if segue.source is SaveReviewViewController {
            guard let review = reviewsContext.currentUserReview,
                let index = placeRepresentation.changeUserReview(userReview: review) else { return }
            let indexPath = IndexPath(row: index, section: 0)
            tableView.reloadRows(at: [indexPath], with: .automatic)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "editPlace" {
            if let vc = segue.destination as? CreatePlaceViewController {
                vc.placeContext = placeContext
                vc.openingTime = openingTime
                vc.sourceIsShowPlace = true
            }
        }
        if segue.identifier == "editReview" {
            if let vc = segue.destination as? EditReviewTableViewController {
                vc.placeContext = placeContext
                vc.reviewsContext = reviewsContext
            }
        }
        if segue.identifier == "editButton" {
            if let vc = segue.destination as? EditReviewTableViewController {
                vc.placeContext = placeContext
                vc.reviewsContext = reviewsContext
            }
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return placeRepresentation.cells.count
    }
}

extension ShowPlaceTableViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageContext.imageIDs.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "showImageCell", for: indexPath) as! ShowPlaceImageCollectionViewCell
        let id = imageContext.imageIDs[indexPath.row]
        cell.id = id
        
        cell.setCell(image: nil)
        
        DispatchQueue.global().async {
            let cellFetcher = ImageCellFetcher()
            cellFetcher.delegateCell = cell
            cellFetcher.fetchImage(identifier: id, placeId: self.placeContext.place.placeID!)
        }
        
        return cell
    }
}

extension ShowPlaceTableViewController: ReviewsContextDelegate {
    func fetchedMyReviews() {
        placeRepresentation.changeReviews(userReview: reviewsContext.currentUserReview, reviews: reviewsContext.reviews)
        
        tableView.reloadData()
    }
}

extension ShowPlaceTableViewController: CreateReviewTableViewCellDelegate {
    func createButtonPressed() {
        performSegue(withIdentifier: "editReview", sender: self)
    }
}

extension ShowPlaceTableViewController {
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let place = placeRepresentation.cells[indexPath.row]
        
        switch place.cell {
        case .image:
            let cell = tableView.dequeueReusableCell(withIdentifier: place.cell.rawValue, for: indexPath) as! ShowPlaceTableImageViewCell
            if imageContext.state == .Finished {
                cell.imageCollectionView.dataSource = self
                cell.loaded()
            } else { cell.reload(); cell.setSpinning() }
            return cell
        case .text:
            let cell = tableView.dequeueReusableCell(withIdentifier: place.cell.rawValue, for: indexPath) as! ShowPlaceTableTextViewCell
            let textData = place.data as! TextCell
            cell.setText(textData)
            return cell
        case .link:
            let cell = tableView.dequeueReusableCell(withIdentifier: place.cell.rawValue, for: indexPath) as! ShowPlaceTableLinkViewCell
            let textData = place.data as! LinkCell
            cell.setWeb(linkCell: textData)
            return cell
        case .hour:
            let cell = tableView.dequeueReusableCell(withIdentifier: place.cell.rawValue, for: indexPath) as! ShowPlaceTableHoursViewCell
            let textData = place.data as! OpeningTime
            cell.setHours(openingTime: textData)
            return cell
        case .review:
            let cell = tableView.dequeueReusableCell(withIdentifier: place.cell.rawValue, for: indexPath) as! ShowPlaceReviewTableViewCell
            let data = place.data as! Review
            cell.setValues(review: data)
            return cell
        case .loading:
            let cell = tableView.dequeueReusableCell(withIdentifier: place.cell.rawValue, for: indexPath) as! LoadingTableViewCell
            cell.setSpinning()
            return cell
        case .createReview:
            let cell = tableView.dequeueReusableCell(withIdentifier: place.cell.rawValue, for: indexPath) as! CreateReviewTableViewCell
            cell.delegate = self
            return cell
        case .userReview:
            let cell = tableView.dequeueReusableCell(withIdentifier: place.cell.rawValue, for: indexPath) as! UserReviewTableViewCell
            cell.showButtons(with: reviewsContext.hasUserReview)
            return cell
        case .rating:
            let cell = tableView.dequeueReusableCell(withIdentifier: place.cell.rawValue, for: indexPath) as! RatingTableViewCell
            cell.setData(count: reviewsContext.count, rating: reviewsContext.rating)
            return cell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: place.cell.rawValue, for: indexPath)
            return cell
        }
    }
    
}


