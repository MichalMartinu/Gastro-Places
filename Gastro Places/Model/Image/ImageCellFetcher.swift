//
//  ImageCellFetcher.swift
//  Gastro Places
//
//  Created by Michal Martinů on 25/03/2019.
//  Copyright © 2019 Michal Martinů. All rights reserved.
//

import UIKit
import CloudKit

protocol ImageContextDelegateCell: AnyObject {
    func imageLoaded(image: UIImage, id: String)
}

class ImageCellFetcher {
    
    weak var delegateCell: ImageContextDelegateCell?
    
    private static let imageCellQueue = DispatchQueue(label: "imageCellQueue", qos: .userInteractive, attributes: .concurrent)
    
    func fetchImage(identifier: String, placeId: String) {
        
        DispatchQueue.main.async {
            let context = AppDelegate.viewContext

            if let image = ImageCoreData.find(id: identifier, context: context) {
                    self.delegateCell?.imageLoaded(image: image, id: identifier)
            }
            else {
                ImageCellFetcher.imageCellQueue.async {
                    self.gtFetchImage(identifier: identifier, placeId: placeId)
                }
            }
        }
    }
    
    func gtFetchImage(identifier: String, placeId: String) {
        let container = CKContainer.default()
        let publicDB = container.publicCloudDatabase
        
        let recordID = CKRecord.ID(recordName: identifier)
        let predicate = NSPredicate(format: "recordID = %@", recordID)
        let query = CKQuery(recordType: "Image", predicate: predicate)
        let queryOperation = CKQueryOperation(query: query)
        queryOperation.qualityOfService = .userInteractive

        queryOperation.recordFetchedBlock = { (record) in
            
            guard let asset = record["picture"] as? CKAsset, let url = asset.fileURL, let data = try? Data(contentsOf: url), let image = UIImage(data: data) else {
                return
            }
            
            DispatchQueue.main.async {
                let context = AppDelegate.viewContext
                ImageCoreData.saveImage(imageID: identifier, data: data, placeID: placeId, context: context)
                self.delegateCell?.imageLoaded(image: image, id: identifier)
                
                try? context.save()
            }
        }
        queryOperation.queryCompletionBlock = { (cursor, error) in
        }
        
        publicDB.add(queryOperation)
    }
}
