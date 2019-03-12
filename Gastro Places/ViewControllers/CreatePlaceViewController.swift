//
//  CreatePlaceViewController.swift
//  Gastro Places
//
//  Created by Michal Martinů on 11/03/2019.
//  Copyright © 2019 Michal Martinů. All rights reserved.
//

import UIKit
import CloudKit

class CreatePlaceViewController: UITableViewController, PlaceContextDelegate {
    
    @IBOutlet weak var cathegoryPickerView: UIPickerView!
    
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
    
    let wrongInputColor = #colorLiteral(red: 0.8823529412, green: 0.3450980392, blue: 0.1607843137, alpha: 1)
    let blackColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
    
    var placeContext: PlaceContext? {
        didSet {
            placeContext?.delegate = self
        }
    }
    let cathegories = Cathegories.init(type: .normal)
    
    var annotation: PlaceAnnotation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        cathegoryPickerView.dataSource = cathegories
        cathegoryPickerView.delegate = cathegories
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setToolbarHidden(false, animated: false)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setToolbarHidden(true, animated: false)
    }
    
    func resetWrongInputErrors() {
        nameLabel.textColor = blackColor
        nameTextFieldLine.backgroundColor = blackColor
        
        webpageLabel.textColor = blackColor
        webpageTextFieldLine.backgroundColor = blackColor
        
        phoneLabel.textColor = blackColor
        phoneNumberTextFieldLine.backgroundColor = blackColor
        
        emailLabel.textColor = blackColor
        emailTextFieldLine.backgroundColor = blackColor
    }
    
    func getCathegory() -> String {
        return cathegories.cathegories[cathegoryPickerView.selectedRow(inComponent: 0)].name
    }
    
    func wrongName() {
        nameLabel.textColor = wrongInputColor
        nameTextFieldLine.backgroundColor = wrongInputColor
    }
    
    func wrongWeb() {
        webpageLabel.textColor = wrongInputColor
        webpageTextFieldLine.backgroundColor = wrongInputColor
    }
    
    func wrongPhone() {
        phoneLabel.textColor = wrongInputColor
        phoneNumberTextFieldLine.backgroundColor = wrongInputColor
    }
    
    func wrongEmail() {
        emailLabel.textColor = wrongInputColor
        emailTextFieldLine.backgroundColor = wrongInputColor
    }
    
    
    
    @IBAction func saveButtonIsPressed(_ sender: UIBarButtonItem) {
        let name = nameTextField.text!
        let web = webpageTextField.text!
        let email = emailTextField.text!
        let phone = phoneNumberTextField.text!
        let cathegory = getCathegory()
        
        resetWrongInputErrors()
        
        placeContext?.changeData(cathegory: cathegory, name: name, phone: phone, email: email, web: web)
        
        let wrongInput = placeContext?.checkInput()
        if let _wrongInput = wrongInput, _wrongInput.count > 0 {
            var wrongInputString = "Invalid:"
            var firstFlag = true
            for input in _wrongInput {
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
            
            showAlert(title: "Invalid input", message: wrongInputString, confirmTitle: "Ok")
            return
        }
        placeContext?.save()
    }
    
    func placeContextSaved(annotation: PlaceAnnotation, error: Error?) {
        if let _error = error {
            showAlert(title: "Cannot create place!", message: _error.localizedDescription, confirmTitle: "Ok")
            self.annotation = nil
        } else {
            self.annotation = annotation
        }
        performSegue(withIdentifier: "unwindToMapViewController", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "unwindToMapViewController" {
            if let vc = segue.destination as? MapViewController {
                if let _annotation = annotation {
                    vc.geoContext?.annotations.append(_annotation)
                }
            }
        }
    }
    
    func showAlert(title: String?, message: String?, confirmTitle: String?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: confirmTitle, style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}
