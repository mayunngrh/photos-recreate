//
//  PhotosRecreateApp.swift
//  PhotosRecreate
//
//  Created by Mayun Suryatama on 15/04/26.
//

import SwiftUI
import SwiftData

@main
struct PhotosRecreateApp: App {
    var body: some Scene {
        WindowGroup {
            MainTabView()
        }.modelContainer(for: ImageModel.self)
    }
}

