//
//  LibraryView.swift
//  PhotosRecreate
//

import SwiftUI
import PhotosUI
import SwiftData

extension UUID: @retroactive Identifiable {
    public var id: UUID { self }
}

// MARK: - PhotoView
struct PhotoView: View {
    let image: ImageModel
    let isSelectMode: Bool
    @Binding var selectedIDs: Set<UUID>
    @Binding var tappedImageID: ImageModel.ID?
    
    var isSelected: Bool { selectedIDs.contains(image.id) }
    
    var body: some View {
        if let uiImage = UIImage(data: image.imageData) {
            Image(uiImage: uiImage)
                .resizable()
                .aspectRatio(1, contentMode: .fill)
                .clipped()
                .cornerRadius(4)
                .opacity(isSelected ? 0.3 : 1)
                .overlay(alignment: .bottomTrailing) {
                    if isSelected {
                        ZStack {
                            Circle()
                                .fill(Color.blue)
                                .stroke(Color.white, lineWidth: 2)
                                .frame(width: 20, height: 20)
                                .offset(x: -10, y: -10)
                            Image(systemName: "checkmark")
                                .foregroundStyle(.white)
                                .font(.system(size: 10, weight: .bold))
                                .offset(x: -10, y: -10)
                        }
                    }
                }
                .onTapGesture {
                    if isSelectMode {
                        if isSelected { selectedIDs.remove(image.id) }
                        else { selectedIDs.insert(image.id) }
                    } else {
                        tappedImageID = image.id
                    }
                }
        }
    }
}

// MARK: - GalleryView
struct GalleryView: View {
    let images: [ImageModel]
    let isSelectMode: Bool
    @Binding var selectedIDs: Set<UUID>
    @Binding var tappedImageID: ImageModel.ID?
    
    private let columns = [
        GridItem(.flexible(), spacing: 2),
        GridItem(.flexible(), spacing: 2),
        GridItem(.flexible(), spacing: 2)
    ]
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: 2) {
            ForEach(images) { image in
                PhotoView(
                    image: image,
                    isSelectMode: isSelectMode,
                    selectedIDs: $selectedIDs,
                    tappedImageID: $tappedImageID
                )
            }
        }
    }
}

// MARK: - LibraryView
struct LibraryView: View {
    
    @Query(sort: \ImageModel.name) var images: [ImageModel]
    @Query var items: [ImageModel]
    
    @Environment(\.modelContext) var context
    @Environment(\.modelContext) var databaseContext
    
    @State private var selectedItems: [PhotosPickerItem] = []
    @State private var isSelectMode = false
    @State private var selectedIDs: Set<UUID> = []
    @State private var tappedImageID: ImageModel.ID?
    @State private var showAddMultipleToAlbum = false
    
    @State var selectedItem: [PhotosPickerItem] = []
 
    @State private var showAdvancedDelete: Bool = false
    @StateObject private var deleteSession = AdvancedDeleteSession()
    
    var body: some View {
        NavigationStack {
            ScrollView {
                GalleryView(
                    images: images,
                    isSelectMode: isSelectMode,
                    selectedIDs: $selectedIDs,
                    tappedImageID: $tappedImageID
                )
            }
            .toolbarTitleDisplayMode(.inline)
            .toolbar {
                leadingToolbar
                trailingMenuToolbar
                ToolbarSpacer(placement: .topBarTrailing)
                trailingSelectToolbar
            }
            .navigationTitle("Library")
            .navigationSubtitle("\(images.count) photos")
        }
        .fullScreenCover(item: $tappedImageID) { id in
            ImagePopUpView(initialID: id)
        }
        .sheet(isPresented: $showAddMultipleToAlbum) {
            AddMultipleToAlbumSheet(selectedIDs: $selectedIDs)
        }
        .onChange(of: selectedItems) { _, _ in
            Task {
                for item in selectedItems {
                    if let data = try? await item.loadTransferable(type: Data.self) {
                        context.insert(ImageModel(name: UUID().uuidString, imageData: data))
                    }
                }
                selectedItems.removeAll()
            }
        }
        .fullScreenCover(isPresented: $showAdvancedDelete, onDismiss: {
            deleteSession.selectedIDs = []
            selectedIDs.removeAll()
            isSelectMode = false
        }) {
            SwipeCardView(selectedIDs: deleteSession.selectedIDs)
                .environmentObject(deleteSession)
        }
    }
    
    private func deleteSelected() {
        images
            .filter { selectedIDs.contains($0.id) }
            .forEach { context.delete($0) }
        selectedIDs.removeAll()
        isSelectMode = false
    }
    
    private var leadingToolbar: some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            PhotosPicker(selection: $selectedItems, matching: .images) {
                Label("Choose Photo", systemImage: "photo")
            }
        }
    }
    private var trailingMenuToolbar: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Menu {
                Button("Sort by Recently Added") {}
                Button("Sort by Date Captured") {}
                Divider()
                Button("Both Libraries") {}
                Button("Personal Library") {}
                Button("Shared Library") {}
                Button("Add To Library") { showAddMultipleToAlbum.toggle() }
                Divider()
                Button("Advanced Delete") {
                    deleteSession.selectedIDs = Array(selectedIDs)
                    showAdvancedDelete = true
                }
                Button("Delete", role: .destructive) { deleteSelected() }
            } label: {
                Label("Options", systemImage: "line.3.horizontal.decrease")
            }
        }
    }
    private var trailingSelectToolbar: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            if isSelectMode {
                Button {
                    isSelectMode = false
                    selectedIDs.removeAll()
                } label: { Image(systemName: "xmark") }
            } else {
                Button("Select") { isSelectMode = true }
            }
        }
    }
    
    //    private func addToAlbumSelected() {
    //        images
    //            .filter { selectedIDs.contains($0.id) }
    //            .forEach { context.delete($0) }
    //        selectedIDs.removeAll()
    //        isSelectMode = false
    //    }
}

