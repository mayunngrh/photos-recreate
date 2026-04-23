//
//  ContentView.swift
//  PhotosRecreate
//
//  Created by Mayun Suryatama on 15/04/26.
//

import SwiftUI
import SwiftData

struct MainTabView: View {
    @State private var searchText: String = ""
    @Query var items: [ImageModel]
    @State var imageData: [ImageModel] = ImageModel.imageSet
    @State var selectedImageData: [ImageModel] = []
    @State var selectedImage: ImageModel? = nil
    @State var isSelectMode: Bool = false
    
    
    var body: some View {
        TabView{

            
            Tab("Library", systemImage: "photo.fill.on.rectangle.fill") {
                LibraryView(gallery: $imageData,  isSelectMode: $isSelectMode, selectedImageData: $selectedImageData)
            }
            
            Tab("Collection", systemImage: "photo.stack") {
                CollectionView()
            }
            
            Tab("Delete System", systemImage: "photo.stack") {
                SwipeCardView()
            }
            
            Tab(role: .search){
                Text("Coming Soon! :)")
            }
        }.onAppear{
            for item in items {
                imageData.append(item)
            }
            print(imageData)
        }
    }
}

#Preview {
    MainTabView()
}
