//
//  ImageCKRecords.swift
//  Gastro Places
//
//  Created by Michal Martinů on 20/03/2019.
//  Copyright © 2019 Michal Martinů. All rights reserved.
//

import UIKit
import CoreData
import CloudKit
import CoreLocation


class ImageCKRecord {
    var record = [CKRecord]()
    
    func initImages(images: [Image], recordReference: CKRecord) {
        for image in images {
            let recordID = CKRecord.ID(recordName: image.id)
            let _record = CKRecord(recordType: "Image", recordID: recordID)
            let reference = CKRecord.Reference(record: recordReference, action: .deleteSelf)
            
            _record["place"] = reference
            
            let imageURL = saveImageToTmpDirectory(image)
            
            if let _imageURL = imageURL {
                _record["picture"] = CKAsset(fileURL: _imageURL)
            }
            
            record.append(_record)
        }
    }
    
    func saveImageToTmpDirectory(_ image: Image) -> URL? {
        // When saving image to CloudKit you need to create url of file
        
        let url = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
            .appendingPathComponent(image.id, isDirectory: false)
            .appendingPathExtension("jpg")
        
        // Write to disk
        let scaledImage = image.picture.scaled(width: 800)
        if let data = scaledImage.jpegData(compressionQuality: 0.4) {
            do {
                try data.write(to: url)
                return url
            } catch {
                print("Handle the error, i.e. disk can be full")
            }
            return nil
        }
        return nil
    }
}

