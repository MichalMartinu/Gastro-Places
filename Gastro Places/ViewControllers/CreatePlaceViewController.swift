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
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var nameTextFieldLine: UIView!
    
    @IBOutlet weak var webpageTextField: UITextField!
    @IBOutlet weak var webpageTextFieldLine: UIView!
    
    @IBOutlet weak var phoneNumberTextField: UITextField!
    @IBOutlet weak var phoneNumberTextFieldLine: UIView!
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var emailTextFieldLine: UIView!
    
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

    func checkInputName() -> String {
       return nameTextField.text!
    }
    
    func checkInputWebpage() -> String {
      return webpageTextField.text!
    }
    
    func checkInputPhone() -> String {
       return phoneNumberTextField.text!
    }
    
    func checkInputEmail() -> String {
       return emailTextField.text!
    }
    
    func getCathegory() -> String {
        return cathegories.cathegories[cathegoryPickerView.selectedRow(inComponent: 0)].name
    }
    
    @IBAction func saveButtonIsPressed(_ sender: UIBarButtonItem) {
        let name = checkInputName()
        let web = checkInputWebpage()
        let email = checkInputEmail()
        let phone = checkInputPhone()
        let cathegory = getCathegory()
        
        placeContext?.changeData(cathegory: cathegory, name: name, phone: phone, email: email, web: web)
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
