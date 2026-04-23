//
//  HomeView.swift
//  PhotosRecreate
//
//  Created by Mayun Suryatama on 15/04/26.
//

import SwiftUI

struct HomeView: View {

    enum Filter: String, CaseIterable, Identifiable {
        case recentlyAdded = "Recently Added",
             dateCaptured = "Date Captured"
        var id: Self { self }
    }
    enum FilterSelector: String, CaseIterable, Identifiable {
        case favorites, edited, photos,videos, screenshots,
             sharedWithYou = "Shared With You",
             notInAnAlbum = "Not in an Album"
        
        var iconName: String {
            switch self {
            case .favorites: return "heart"
            case .edited: return "slider.horizontal.3"
            case .photos: return "photo"
            case .videos: return "video"
            case .screenshots: return "inset.filled.rectangle.and.person.filled.circle"
            case .sharedWithYou: return "sharedwithyou"
            case .notInAnAlbum: return "rectangle.stack.slash"
            }
        }
        
        var id: Self { self }
    }
    
    @State private var selectedFilter: Filter = .recentlyAdded
    @State private var showingPopover = false
    @State private var images = (10...20).map{ "photo_\($0)"}
    
    let columns = [
        GridItem(.flexible(),spacing: 2),
        GridItem(.flexible(),spacing: 2),
        GridItem(.flexible(),spacing: 2),
    ]
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: columns,spacing: 2) {
                    ForEach(images, id: \.self) { image in
                        Image(image)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(minWidth: 0, maxWidth: .infinity)
                            .aspectRatio(1, contentMode: .fill)
                            .clipShape(RoundedRectangle(cornerRadius: 3))
                        
                    }
                }
            }
            .navigationTitle("Home")
            .navigationSubtitle("15 April")
            .toolbarTitleDisplayMode(.inlineLarge)
            .toolbarRole(.editor)
            .toolbar{
                ToolbarItem{
                    
                    Menu {
                        Picker("Flavor", selection: $selectedFilter) {
                            ForEach(Filter.allCases) { filter in
                                Text(filter.rawValue.capitalized)
                                    .tag(filter)
                            }
                        }.onChange(of: selectedFilter) { _, newValue in
                            images.shuffle()
                        }
                        
                        //INSIDE MENU
                        Menu {
                            Picker("Category", selection: $selectedFilter) {
                                ForEach(FilterSelector.allCases) { category in
                                    Label(category.rawValue.capitalized, systemImage: category.iconName)
                                        .padding()
                                }
                            }.onChange(of: selectedFilter) { _, newValue in
                                images.shuffle()
                            }
                        } label: {
                            Text("Filter")
                        }
                    } label: {
                        Label("Filter", systemImage: "line.3.horizontal.decrease")
                    }
                }
                ToolbarSpacer()
                ToolbarItem{
                    Text("Select")
                        .padding(10)
                }
            }
        }
    }
}

#Preview {
    HomeView()
}

