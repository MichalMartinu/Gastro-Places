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

struct Image {
    var id: String
    var picture: UIImage
    
    init(id: String, picture: UIImage) {
        self.id = id
        self.picture = picture
    }
}

protocol ImageContextDelegate: AnyObject {
    func imageContextDidloadIDs()
}

class ImageContext {
    
    var images = [Image]()
    private var imagesToDelete = [String]()
    private var imagesToSave = [String]()
    
    var imageIDs = [String]()
    private var cache = NSCache<NSString, UIImage>()

    
    private static let imageContextQueue = DispatchQueue(label: "imageContextQueue", qos: .utility, attributes: .concurrent)

    weak var delegate: ImageContextDelegate?
    
    func insertNewImage(image: UIImage) {
        let uuid = UUID().uuidString
        images.append(Image.init(id: uuid, picture: image))
        imagesToSave.append(uuid)
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
        if let saveIndex = imagesToSave.firstIndex(of: images[index].id) {
            imagesToSave.remove(at: saveIndex)
        }
        
        images.remove(at: index)
    }
    
    func fetchImageIDs(placeID: String) {
        ImageContext.imageContextQueue.async {
            self.gtfetchImageIDs(placeID: placeID)
        }
    }
    
    private func gtfetchImageIDs(placeID: String) {
        let container = CKContainer.default()
        let publicDB = container.publicCloudDatabase
        
        let recordID = CKRecord.ID(recordName: placeID)
        let recordToMatch = CKRecord.Reference(recordID: recordID, action: .deleteSelf)
        
        let predicate = NSPredicate(format: "place == %@", recordToMatch)
        let query = CKQuery(recordType: "Image", predicate: predicate)
        let operation = CKQueryOperation(query: query)
        operation.desiredKeys = []
        operation.queryCompletionBlock = { results, error in
            
            if error != nil {
                return
            }
            
            DispatchQueue.main.async {
                self.delegate?.imageContextDidloadIDs()
            }
        }
        
        operation.recordFetchedBlock = ( { (record) -> Void in
            self.imageIDs.append(record.recordID.recordName)
        })
        
        publicDB.add(operation)
    }
    
    func fetchedImage(identifier: String) -> UIImage? {
        return cache.object(forKey: identifier as NSString)
    }
    
    func fetchImage(identifier: String) {
        // TODO delegat
    }
    
    /*func gtFetchImage(identifier: String) {
        
    }*/
}
