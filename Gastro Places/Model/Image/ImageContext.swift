//
//  ImageContext.swift
//  Gastro Places
//
//  Created by Michal Martinů on 14/03/2019.
//  Copyright © 2019 Michal Martinů. All rights reserved.
//

import UIKit
import CloudKit
import CoreData

protocol ImageContextDelegate: AnyObject {
    func imageContextDidloadIDs()
}

class ImageContext: Operation {
    
    var images = [Image]()
    var imagesToDelete = [CKRecord.ID]()
    private var imagesToSave = [String]()
    
    var imageIDs = [String]()
    
    private static let imageContextQueue = DispatchQueue(label: "imageContextQueue", qos: .userInteractive, attributes: .concurrent)

    weak var delegate: ImageContextDelegate?
    
    func insertNewImage(image: UIImage) {
        let uuid = UUID().uuidString
        images.append(Image.init(id: uuid, picture: image))
        imagesToSave.append(uuid)
        imageIDs.append(uuid)
    }
    
    func getImagesToSave() -> [Image] {
        var images = [Image]()
        for id in imagesToSave {
            let image = self.images.filter { $0.id == id }
            
            if let _image = image.first {
                images.append(_image)
            }
        }
        return images
    }
    
    func deleteImageAtIndex(index: Int) {
        if let saveIndex = imagesToSave.firstIndex(of: imageIDs[index]) {
            imagesToSave.remove(at: saveIndex)
        } else {
            let deleteID = imageIDs[index]
            imagesToDelete.append(CKRecord.ID(recordName: deleteID))
        }
        
        imageIDs.remove(at: index)
    }
 
    func fetchImageIDs(placeID: String, placeCoreData: PlaceCoreData?) {
        state = .Executing
        let context = AppDelegate.viewContext
        
        if let imageIDs = ImageCoreData.findSavedIDs(placeCoreData: placeCoreData!, context: context) {
            self.imageIDs = imageIDs
            self.state = .Finished
            self.delegate?.imageContextDidloadIDs()
            return
        }
        
        let container = CKContainer.default()
        let publicDB = container.publicCloudDatabase
        
        let recordID = CKRecord.ID(recordName: placeID)
        let recordToMatch = CKRecord.Reference(recordID: recordID, action: .deleteSelf)
        
        let predicate = NSPredicate(format: "place == %@", recordToMatch)
        let query = CKQuery(recordType: "Image", predicate: predicate)
        query.sortDescriptors?.append(NSSortDescriptor(key: "creationDate", ascending: false))
        
        let operation = CKQueryOperation(query: query)
        operation.qualityOfService = .userInteractive        
        operation.queryCompletionBlock = { results, error in
            
            if error != nil {
                self.state = .Failed
                DispatchQueue.main.async {
                    self.delegate?.imageContextDidloadIDs()
                }
                return
            }
            
            self.state = .Finished
            DispatchQueue.main.async {
                self.delegate?.imageContextDidloadIDs()
            }
        }
        
        operation.recordFetchedBlock = ( { (record) -> Void in
            
            DispatchQueue.main.async {
                ImageCoreData.saveID(imageID: record.recordID.recordName, creationDate: record.creationDate!,placeID: placeID, context: context)
            }
            
            self.imageIDs.append(record.recordID.recordName)
        })
        
        publicDB.add(operation)
    }
    
    func getLocalImageForID(with id: String) -> UIImage? {
        if let index = images.firstIndex(where: { $0.id == id }) {
            return images[index].picture
        }
        return nil
    }
    
    func deleteCreatedImages() {
        images = [Image]()
        imagesToDelete = [CKRecord.ID]()
        imagesToSave = [String]()
    }
}
