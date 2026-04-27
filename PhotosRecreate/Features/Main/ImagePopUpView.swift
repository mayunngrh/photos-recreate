//
//  ImagePopUpView.swift
//  PhotosRecreate
//

import SwiftUI
import SwiftData

struct ImagePopUpView: View {

    @Query var gallery: [ImageModel]
    @Environment(\.modelContext) var context
    @State private var showAddToAlbum = false
    @Environment(\.dismiss) private var dismiss

    @State private var selectedID: ImageModel.ID

    init(initialID: ImageModel.ID) {
        self._selectedID = State(initialValue: initialID)
    }

    var body: some View {
        NavigationStack {
            TabView(selection: $selectedID) {
                ForEach(gallery) { item in
                    if let uiImage = UIImage(data: item.imageData) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .tag(item.id)
                    }
                }
            }
            .overlay(alignment: .bottom) {thumbnailStrip}
            .tabViewStyle(.page(indexDisplayMode: .never))
            .toolbarTitleDisplayMode(.inline)
            .navigationTitle(currentImage?.name ?? "")
            .navigationSubtitle("\(currentIndex + 1) of \(gallery.count)")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Label("Close", systemImage: "xmark")
                    }
                }
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        showAddToAlbum = true
                    } label: {
                        Label("AddToAlbum", systemImage: "rectangle.stack.badge.plus")
                    }
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Button {} label: {
                            Label("Copy", systemImage: "document.on.document")
                        }
                        Button {} label: {
                            Label("Duplicate", systemImage: "plus.square.on.square")
                        }
                        Button {} label: {
                            Label("Hide", systemImage: "eye.slash")
                        }
                        Button {} label: {
                            Label("Slideshow", systemImage: "play.rectangle")
                        }
                        Divider()
                        Button {
                            showAddToAlbum = true
                        } label: {
                            Label("Add to Album", systemImage: "rectangle.stack.badge.plus")
                        }
                        Button {} label: {
                            Label("Move to Shared Library", systemImage: "person.2")
                        }
                        Divider()
                        Button {} label: {
                            Label("Adjust Date & Time", systemImage: "calendar.badge.clock")
                        }
                        Button {} label: {
                            Label("Adjust Location", systemImage: "mappin.circle")
                        }
                        Divider()
                        Button(role: .destructive) {
                            deleteCurrentImage()
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    } label: {
                        Label("Options", systemImage: "line.3.horizontal.decrease")
                    }
                }
            }
        }
        .sheet(isPresented: $showAddToAlbum) {
            AddToAlbumSheet(image: currentImage)
        }

    }

    // MARK: - Thumbnail strip

    private var thumbnailStrip: some View {
        let rows = [GridItem(.fixed(60))]
        
        return ScrollViewReader { proxy in
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHGrid(rows: rows, spacing: 4) {
                    ForEach(gallery) { item in
                        if let uiImage = UIImage(data: item.imageData) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .aspectRatio(1, contentMode: .fill)
                                .frame(width: 60, height: 60)
                                .clipped()
                                .cornerRadius(4)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 4)
                                        .stroke(Color.white, lineWidth: item.id == selectedID ? 2 : 0)
                                )
                                .id(item.id)
                                .onTapGesture {
                                    withAnimation { selectedID = item.id }
                                }
                        }
                    }
                }
                .padding(.horizontal, 8)
            }
            .frame(height: 76)
            .background(.ultraThinMaterial)
            .onChange(of: selectedID) { _, newID in
                withAnimation { proxy.scrollTo(newID, anchor: .center) }
            }
        }
        .padding(.bottom, 16)
    }

    // MARK: - Helpers
// computed property
    private var currentImage: ImageModel? {
        gallery.first { $0.id == selectedID }
    }

    private var currentIndex: Int {
        gallery.firstIndex { $0.id == selectedID } ?? 0
    }

    private func deleteCurrentImage() {
        // Step to a neighbour before deleting so the TabView doesn't show a blank page
        if let image = currentImage {
            if currentIndex > 0 {
                selectedID = gallery[currentIndex - 1].id
            } else if gallery.count > 1 {
                selectedID = gallery[currentIndex + 1].id
            } else {
                // Last image deleted — close the view
//                isPresented = false
            }
            context.delete(image)
        }
    }
}
