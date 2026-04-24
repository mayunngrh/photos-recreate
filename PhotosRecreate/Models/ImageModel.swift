//
//  ImageModel.swift
//  test
//
//  Created by Alex on 20/04/26.
//
import SwiftUI
import SwiftData

@Model
class ImageModel: Identifiable{
    var name: String
    var isSelected: Bool
    var id: UUID
    var bucket: BucketType?
    
    @Attribute(.externalStorage)
    var imageData: Data
    
    init(name: String, imageData: Data) {
        self.id = UUID()
        self.isSelected = false
        self.name = name
        self.bucket = nil
        self.imageData = imageData

    }
    
    static var imageSet:[ImageModel] = [
        ImageModel(name: "photo_10",imageData: Data()),
        ImageModel(name: "photo_11",imageData: Data()),
        ImageModel(name: "photo_12",imageData: Data()),
        ImageModel(name: "photo_13",imageData: Data()),
        ImageModel(name: "photo_14",imageData: Data()),
        ImageModel(name: "photo_15",imageData: Data()),
        ImageModel(name: "photo_16",imageData: Data()),
        ImageModel(name: "photo_17",imageData: Data()),
        ImageModel(name: "photo_18",imageData: Data()),
        ImageModel(name: "photo_19",imageData: Data()),
        ImageModel(name: "photo_20",imageData: Data()),
    ]
}



