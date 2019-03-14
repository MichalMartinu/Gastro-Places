//
//  ImagesToSaveTableViewController.swift
//  Gastro Places
//
//  Created by Michal Martinů on 14/03/2019.
//  Copyright © 2019 Michal Martinů. All rights reserved.
//

import UIKit

class ImagesToSaveTableViewController: UITableViewController {
    
    @IBOutlet weak var editButton: UIBarButtonItem!
    
    var imageContext: ImageContext!
    
    let imagePicker = UIImagePickerController()
    
    
    override func viewDidLoad() {
       enableOrDisableEditButton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.tabBar.isHidden = false
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "createImageTableViewCell", for: indexPath) as! CreateImageTableViewCell
        cell.setImage(imageContext.images[indexPath.row])
        return cell
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return imageContext.images.count
    }
    
    @IBAction func newImageButtonPressed(_ sender: UIBarButtonItem) {
        if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum) {
            
            imagePicker.delegate = self
            imagePicker.sourceType = .savedPhotosAlbum;
            imagePicker.allowsEditing = false
            
            self.present(imagePicker, animated: true, completion: nil)
        } else {
            // TODO error
        }
    }
    
    @IBAction func editButtonPressed(_ sender: UIBarButtonItem) {
        if tableView.isEditing {
            tableView.setEditing(false, animated: true)
        } else {
            tableView.setEditing(true, animated: true)
        }
    }
    
    func enableOrDisableEditButton() {
        if imageContext.images.count > 0 {
            editButton.isEnabled = true
        } else {
            editButton.isEnabled = false
        }
    }
}

extension ImagesToSaveTableViewController: UINavigationControllerDelegate,  UIImagePickerControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        imageContext.insertImage(image: image)
        dismiss(animated: true, completion: nil) // Take image picker off the screen
        tableView.reloadData()
        enableOrDisableEditButton()
    }
}
