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
    @IBOutlet weak var editingButton: UIBarButtonItem!
    
    var imageContext: ImageContext!
    var placeContext: PlaceContext!
    
    let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
       enableOrDisableEditButton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "imageTableViewCell", for: indexPath) as! ImageTableViewCell
        
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
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return imageContext.imageIDs.count
    }
    
    @IBAction private func newImageButtonPressed(_ sender: UIBarButtonItem) {
        imagePicker.sourceType = .savedPhotosAlbum
        imagePicker.allowsEditing = false
        imagePicker.delegate = self
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction private func editButtonPressed(_ sender: UIBarButtonItem) {
        if tableView.isEditing {
            tableView.setEditing(false, animated: true)
            editButton.title = "Edit"
            
        } else {
            tableView.setEditing(true, animated: true)
            editButton.title = "Done"
        }
    }
    
    private func enableOrDisableEditButton() {
        if imageContext.imageIDs.count > 0 {
            editButton.isEnabled = true
        } else {
            editButton.isEnabled = false
        }
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            imageContext.deleteImageAtIndex(index: indexPath.row)
            // delete the table view row
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
}

extension ImagesToSaveTableViewController: UINavigationControllerDelegate,  UIImagePickerControllerDelegate {
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let selectedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else {
            dismiss(animated: true, completion: nil)
            return
        }

        imageContext.insertNewImage(image: selectedImage)
        dismiss(animated: true, completion: nil) // Take image picker off the screen
        tableView.reloadData()
        enableOrDisableEditButton()
    }
}
