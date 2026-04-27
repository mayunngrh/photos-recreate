//
//  AlbumDetailView.swift
//  PhotosRecreate
//
//  Created by Alex on 24/04/26.
//


import SwiftUI
import SwiftData

struct AlbumDetailView: View {
    let album: Album

    @State private var isSelectMode = false
    @State private var selectedIDs: Set<UUID> = []
    @Environment(\.modelContext) var context

    var body: some View {
        ScrollView {
            // Reuse your existing GalleryView with a filter
            AlbumGalleryView(
                album: album,
                isSelectMode: isSelectMode,
                selectedIDs: $selectedIDs
            )
        }
        .navigationTitle(album.name)
        .navigationSubtitle("\(album.images.count) photos")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                if isSelectMode {
                    Button {
                        removeSelectedFromAlbum()
                    } label: {
                        Text("Remove")
                            .foregroundStyle(.red)
                    }
                } else {
                    Button("Select") {
                        isSelectMode = true
                    }
                }
            }
        }
    }

    private func removeSelectedFromAlbum() {
        album.images.removeAll { selectedIDs.contains($0.id) }
        selectedIDs.removeAll()
        isSelectMode = false
    }
}

// Filtered gallery — only shows images belonging to this album
struct AlbumGalleryView: View {
    let album: Album
    let isSelectMode: Bool
    @Binding var selectedIDs: Set<UUID>
    @State private var tappedImageID: ImageModel.ID?

    private let columns = [
        GridItem(.flexible(), spacing: 2),
        GridItem(.flexible(), spacing: 2),
        GridItem(.flexible(), spacing: 2)
    ]

    var body: some View {
        LazyVGrid(columns: columns, spacing: 2) {
            ForEach(album.images) { image in
                PhotoView(
                    image: image,
                    isSelectMode: isSelectMode,
                    selectedIDs: $selectedIDs,
                    tappedImageID: $tappedImageID
                )
            }
        }
        .fullScreenCover(item: $tappedImageID) { id in
            ImagePopUpView(initialID: id)
        }
    }
}
