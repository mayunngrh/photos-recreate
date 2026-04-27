//
//  AddToAlbumSheet.swift
//  PhotosRecreate
//
//  Created by Alex on 24/04/26.
//
import SwiftUI
import SwiftData
struct AddToAlbumSheet: View {
    let image: ImageModel?
    @Query(sort: \Album.createdAt) var albums: [Album]
    @Environment(\.modelContext) var context
    @Environment(\.dismiss) var dismiss

    @State private var showNewAlbumAlert = false
    @State private var newAlbumName = ""

    var body: some View {
        NavigationStack {
            List {
                Button {
                    showNewAlbumAlert = true
                } label: {
                    Label("New Album", systemImage: "plus")
                }
                ForEach(albums) { album in
                    Button {
                        addToAlbum(album)
                    } label: {
                        HStack {
                            Text(album.name)
                            Spacer()
                            if let image, album.images.contains(image) {
                                Image(systemName: "checkmark")
                                    .foregroundStyle(.blue)
                            }
                        }
                    }
                    .foregroundStyle(.primary)
                }
            }
            .navigationTitle("Add to Album")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
            .alert("New Album", isPresented: $showNewAlbumAlert) {
                TextField("Album name", text: $newAlbumName)
                Button("Create") { createAndAdd() }
                Button("Cancel", role: .cancel) { newAlbumName = "" }
            }
        }
    }

    private func addToAlbum(_ album: Album) {
        guard let image, !album.images.contains(image) else { return }
        album.images.append(image)
        dismiss()
    }

    private func createAndAdd() {
        guard !newAlbumName.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        let album = Album(name: newAlbumName)
        context.insert(album)
        if let image { album.images.append(image) }
        newAlbumName = ""
        dismiss()
    }
}


struct AddMultipleToAlbumSheet: View {
    @Binding var selectedIDs: Set<UUID>
    @Query(sort: \Album.createdAt) var albums: [Album]
    @Query(sort: \ImageModel.name) var images: [ImageModel]
    @Environment(\.modelContext) var context
    @Environment(\.dismiss) var dismiss

    @State private var showNewAlbumAlert = false
    @State private var newAlbumName = ""

    var body: some View {
        NavigationStack {
            List {
                Button {
                    showNewAlbumAlert = true
                } label: {
                    Label("New Album", systemImage: "plus")
                }
                ForEach(albums) { album in
                    Button {
                        print("some")
                        addToAlbumMultiple(album)
                    } label: {
                        HStack {
                            Text(album.name)
                            Spacer()
                        }
                    }
                    .foregroundStyle(.primary)
                }
            }
            .navigationTitle("Add to Album")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
            .alert("New Album", isPresented: $showNewAlbumAlert) {
                TextField("Album name", text: $newAlbumName)
                Button("Create") { createAndAdd() }
                Button("Cancel", role: .cancel) { newAlbumName = "" }
            }
        }
    }

    private func addToAlbumMultiple(_ album: Album) {
        print("inside")
        print(images)
        print(selectedIDs)
        images
            .filter { selectedIDs.contains($0.id) }
            .forEach { image in
                print("why")
                if !album.images.contains(image) {
                    album.images.append(image)
                }
                print("something")
            }
        selectedIDs.removeAll()
        dismiss()
    }

    private func createAndAdd() {
        guard !newAlbumName.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        let album = Album(name: newAlbumName)
        context.insert(album)
        images
            .filter { selectedIDs.contains($0.id) }
            .forEach { image in
                print("why")
                if !album.images.contains(image) {
                    album.images.append(image)
                }
                print("something")
            }
        selectedIDs.removeAll()
        newAlbumName = ""
        dismiss()
    }
}
