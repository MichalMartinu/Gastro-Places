//
//  CreatePlaceViewController.swift
//  Gastro Places
//
//  Created by Michal Martinů on 11/03/2019.
//  Copyright © 2019 Michal Martinů. All rights reserved.
//

import UIKit
import CloudKit

protocol CreatePlaceViewControllerDelegate: AnyObject {
    func deleteAnnotation(with id: String)
}

class CreatePlaceViewController: UITableViewController, ImageContextDelegate {

    @IBOutlet weak var cathegoryPickerView: UIPickerView!
    @IBOutlet weak var imageCollectionView: UICollectionView!
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var nameTextFieldLine: UIView!
    
    @IBOutlet weak var webpageLabel: UILabel!
    @IBOutlet weak var webpageTextField: UITextField!
    @IBOutlet weak var webpageTextFieldLine: UIView!
    
    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var phoneNumberTextField: UITextField!
    @IBOutlet weak var phoneNumberTextFieldLine: UIView!
    
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var emailTextFieldLine: UIView!
   
    @IBOutlet weak var openingHoursDaysLabel: UILabel!
    @IBOutlet weak var openingHoursLabel: UILabel!
    
    @IBOutlet weak var editImagesButton: UIButton!
    @IBOutlet weak var openingHoursButton: UIButton!
    
    
    let wrongInputColor = #colorLiteral(red: 0.8823529412, green: 0.3450980392, blue: 0.1607843137, alpha: 1)
    let blackColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
    
    var placeContext: PlaceContext!
    
    private let cathegories = Cathegories.init(type: .normal)
        
    var imageContext: ImageContext!
    
    var openingTime: OpeningTime!
    
    var sourceIsShowPlace = false
    
    weak var delegate: CreatePlaceViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createOpeningTimeAndImageContext()
        cathegoryPickerView.dataSource = cathegories
        cathegoryPickerView.delegate = cathegories
        roundButtons()
        imageCollectionView.delegate = self
        imageCollectionView.dataSource = self
        checkIfPlaceContextIsFinished()
        imageContext.delegate = self
        if let id = placeContext.place.placeID {
            imageContext.fetchImageIDs(placeID: id)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        openingHoursDaysLabel.text = openingTime.stringDays
        openingHoursLabel.text = openingTime.stringHours
        
        if placeContext.state == .Finished {
            setToolbarHidden(with: false)
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        setToolbarHidden(with: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        imageCollectionView.reloadData()
    }
    
    private func roundButtons() {
        editImagesButton.roundCornersLarge()
        openingHoursButton.roundCornersLarge()
    }
    
    private func resetWrongInputErrors() {
        nameLabel.textColor = blackColor
        nameTextFieldLine.backgroundColor = blackColor
        
        webpageLabel.textColor = blackColor
        webpageTextFieldLine.backgroundColor = blackColor
        
        phoneLabel.textColor = blackColor
        phoneNumberTextFieldLine.backgroundColor = blackColor
        
        emailLabel.textColor = blackColor
        emailTextFieldLine.backgroundColor = blackColor
    }
    
    private func enableNavigationBarButtons(enabled: Bool) {
        navigationItem.rightBarButtonItem?.isEnabled = enabled
        navigationItem.leftBarButtonItem?.isEnabled = enabled
    }
    
    private func getCathegory() -> String {
        return cathegories.cathegories[cathegoryPickerView.selectedRow(inComponent: 0)].name
    }
    
    private func checkIfPlaceContextIsFinished() {
        if placeContext.state == .Finished {
            let place = placeContext.place
            nameTextField.text = place.name
            webpageTextField.text = place.web
            emailTextField.text = place.email
            phoneNumberTextField.text = place.phone
            guard let cathegory = place.cathegory, let row = cathegories.indexForCathegory(cathegory) else { return }
            cathegoryPickerView.selectRow(row, inComponent: 0, animated: false)
        }
    }
    
    private func createOpeningTimeAndImageContext() {
        if openingTime == nil {
            openingTime = OpeningTime(intervalInMinutes: 15)
        }
        if imageContext == nil {
            imageContext = ImageContext()
        }
    }
    
    private func setToolbarHidden(with value: Bool) {
        navigationController?.setToolbarHidden(value, animated: true)
    }
    
    private func wrongName() {
        nameLabel.textColor = wrongInputColor
        nameTextFieldLine.backgroundColor = wrongInputColor
    }
    
    private func wrongWeb() {
        webpageLabel.textColor = wrongInputColor
        webpageTextFieldLine.backgroundColor = wrongInputColor
    }
    
    private func wrongPhone() {
        phoneLabel.textColor = wrongInputColor
        phoneNumberTextFieldLine.backgroundColor = wrongInputColor
    }
    
    private func wrongEmail() {
        emailLabel.textColor = wrongInputColor
        emailTextFieldLine.backgroundColor = wrongInputColor
    }
    
    private func isICloudKitContainerAvailable() -> Bool {
        // Check if iCloud is currently available
        if FileManager.default.ubiquityIdentityToken != nil {
            return true
        }
        else {
            return false
        }
    }
    
    @IBAction private func saveButtonIsPressed(_ sender: UIBarButtonItem) {       
        enableNavigationBarButtons(enabled: false)
        
        if isICloudKitContainerAvailable() == false {
            showAlert(title: "iCloud account needed", message: "You need to login to your iCloud account on iPhone.", confirmTitle: "Ok")
            enableNavigationBarButtons(enabled: true)
            return
        }
        
        let name = nameTextField.text!
        let web = webpageTextField.text!
        let email = emailTextField.text!
        let phone = phoneNumberTextField.text!
        let cathegory = getCathegory()
        
        resetWrongInputErrors()
        
        placeContext?.changeData(cathegory: cathegory, name: name, phone: phone, email: email, web: web)
        
        let wrongInput = placeContext?.checkInput()
        if let _wrongInput = wrongInput, _wrongInput.count > 0 {
           
            let wrongInputString = setWrongInput(_wrongInput)
            showAlert(title: "Invalid input", message: wrongInputString, confirmTitle: "Ok")
            //self.view.activityStopAnimating()
            enableNavigationBarButtons(enabled: true)
            return
        }
        
        performSegue(withIdentifier: "savePlaceIndicator", sender: self)
    }
    
    private func setWrongInput(_ wrongInput: [InputTypes]) -> String {
        var wrongInputString = "Invalid:"
        var firstFlag = true
        
        for input in wrongInput {
            if firstFlag != true {
                wrongInputString += ","
            }
            firstFlag = false
            
            switch input {
            case .name:
                wrongName()
            case .web:
                wrongWeb()
            case .phone:
                wrongPhone()
            case .email:
                wrongEmail()
            }
            wrongInputString += " \(input.rawValue)"
        }
        return wrongInputString
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "openingTimeTableViewController" {
            if let vc = segue.destination as? OpeningTimeTableViewController {
               vc.openingTime = openingTime
            }
        }
        
        if segue.identifier == "createImages" {
            if let vc = segue.destination as? ImagesToSaveTableViewController {
                vc.imageContext = imageContext
                vc.placeContext = placeContext
            }
        }
        
        if segue.identifier == "savePlaceIndicator" {
            if let vc = segue.destination as? CreatePlaceIndicatorViewController {
                vc.placeContext = placeContext
                vc.openingTime = openingTime
                vc.imageContext = imageContext
                vc.sourceIsShowPlace = sourceIsShowPlace
            }
        }
    }
    
    private func showAlert(title: String?, message: String?, confirmTitle: String?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: confirmTitle, style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    private func showDeleteAlert() {
        let alert = UIAlertController(title: "Delete place", message: "Do you really want to delete this place?", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "No", style: .default, handler: nil))
        alert.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: deletePlace))
        
        self.present(alert, animated: true)
    }
    
    @IBAction private func cancelButtonIsPressed(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func deleteButtonIsPressed(_ sender: Any) {
        showDeleteAlert()
    }
    
    func imageContextDidloadIDs() {
        imageCollectionView.reloadData()
    }
    
    private func deletePlace(alert: UIAlertAction?) {
        guard let id = placeContext.place.placeID else { return }
        
        let container = CKContainer.default()
        let publicDB = container.publicCloudDatabase
        
        let recordID = CKRecord.ID(recordName: id)
        publicDB.delete(withRecordID: recordID) { (recordID, error) in
            if let _error = error {
                // TODO: error handle
                return
            }
            
            DispatchQueue.main.async {
                self.setToolbarHidden(with: true)
                if let _recordID = recordID?.recordName {
                    self.delegate?.deleteAnnotation(with: _recordID)
                }
                self.performSegue(withIdentifier: "backToMapFromEdit", sender: self)
            }
        }
    }
}

extension CreatePlaceViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return imageContext.imageIDs.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "createPlaceImageCollectionViewCell", for: indexPath) as! ShowPlaceImageCollectionViewCell
        
        let id = imageContext.imageIDs[indexPath.row]
        cell.id = id
        
        if let image = imageContext.getLocalImageForID(with: id) {
            cell.setCell(image: image)
        } else {
            cell.setCell(image: nil)
            
            DispatchQueue.global().async {
                let cellFetcher = ImageCellFetcher()
                cellFetcher.delegateCell = cell
                cellFetcher.fetchImage(identifier: id, placeId: self.placeContext.place.placeID!)
            }
        }
        
        return cell
    }
}
