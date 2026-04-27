//
//  CollectionView.swift
//  PhotosRecreate
//
//  Created by Mayun Suryatama on 15/04/26.
//

import SwiftUI
import SwiftData

struct AlbumThumbnailView: View {
    let album: Album

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            if let firstImage = album.images.first,
               let uiImage = UIImage(data: firstImage.imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(1, contentMode: .fill)
                    .clipped()
                    .cornerRadius(8)
            } else {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(.systemGray5))
                    .aspectRatio(1, contentMode: .fit)
                    .overlay {
                        Image(systemName: "photo.on.rectangle")
                            .foregroundStyle(.secondary)
                    }
            }

            Text(album.name)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundStyle(.primary)

            Text("\(album.images.count) photos")
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
    }
}

struct AlbumGridView: View {
    @Query(sort: \Album.createdAt) var albums: [Album]
    @Environment(\.modelContext) var context

    @State private var showNewAlbumAlert = false
    @State private var newAlbumName = ""

    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(albums) { album in
                        NavigationLink(destination: AlbumDetailView(album: album)) {
                            AlbumThumbnailView(album: album)
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Albums")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showNewAlbumAlert = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .alert("New Album", isPresented: $showNewAlbumAlert) {
                TextField("Album name", text: $newAlbumName)
                Button("Create") { createAlbum() }
                Button("Cancel", role: .cancel) { newAlbumName = "" }
            }
        }
    }

    private func createAlbum() {
        guard !newAlbumName.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        context.insert(Album(name: newAlbumName))
        newAlbumName = ""
    }
}


struct CollectionView: View {
    var body: some View {
        AlbumGridView()
        
        
    }
}
