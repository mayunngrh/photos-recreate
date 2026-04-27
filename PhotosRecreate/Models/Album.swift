//
//  Album.swift
//  PhotosRecreate
//
//  Created by Alex on 24/04/26.
//
import SwiftData
import Foundation

@Model
class Album {
    var id: UUID
    var name: String
    var createdAt: Date
    
    @Relationship(deleteRule: .nullify, inverse: \ImageModel.albums)
    var images: [ImageModel]

    init(name: String) {
        self.id = UUID()
        self.name = name
        self.createdAt = Date()
        self.images = []
    }
}
