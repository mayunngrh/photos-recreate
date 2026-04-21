//
//  ImageModel.swift
//  test
//
//  Created by Alex on 20/04/26.
//
import SwiftUI

struct ImageModel: Identifiable{
//    let UID: UUID()
    var name: String
    var isSelected: Bool = false
    var bucket: BucketType?
    let id: UUID = UUID()
    
    static var imageSet:[ImageModel] = [
        ImageModel(name: "photo_10"),
        ImageModel(name: "photo_11"),
        ImageModel(name: "photo_12"),
        ImageModel(name: "photo_13"),
        ImageModel(name: "photo_14"),
        ImageModel(name: "photo_15"),
        ImageModel(name: "photo_16"),
        ImageModel(name: "photo_17"),
        ImageModel(name: "photo_18"),
        ImageModel(name: "photo_19"),
        ImageModel(name: "photo_20"),
    ]
//
    
}
