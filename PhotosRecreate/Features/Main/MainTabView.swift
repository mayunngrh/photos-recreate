//
//  ContentView.swift
//  PhotosRecreate
//
//  Created by Mayun Suryatama on 15/04/26.
//

import SwiftUI

struct MainTabView: View {
    @State private var searchText: String = ""
    var body: some View {
        TabView{
            Tab("Home", systemImage: "house.fill") {
                HomeView()
            }
            
            Tab("Collection", systemImage: "photo.stack") {
                CollectionView()
            }
            
            Tab(role: .search){
                Text("Coming Soon! :)")
            }
        }
    }
}

#Preview {
    MainTabView()
}
