//
//  Untitled.swift
//  PhotosRecreate
//
//  Created by Mayun Suryatama on 24/04/26.
//

import SwiftUI
import SwiftData

struct KeepReviewView: View {
    @Binding var images: [ImageModel]
    var onDone: () -> Void
    
    @State private var activeAction: KeepAction? = nil
    
    enum KeepAction: String, Identifiable {
        case compress = "Compress All"
        case album = "Add to Album"
        case both = "Add to Album & Compress"
        
        var id: String { rawValue }
    }
    
    private var keepImages: [ImageModel] {
        images.filter { $0.bucket == .keep }
    }
    
    let columns = [
        GridItem(.flexible(), spacing: 2),
        GridItem(.flexible(), spacing: 2),
        GridItem(.flexible(), spacing: 2),
    ]
    
    var body: some View {
        NavigationView {
            ZStack {
                photoGrid
                
                doneButton
            }
            .navigationTitle("Keep (\(keepImages.count))")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Button("Compress All") {
                            activeAction = .compress
                        }
                        Button("Add to Album") {
                            activeAction = .album
                        }
                        Button("Add to Album & Compress") {
                            activeAction = .both
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
        }
        .alert(item: $activeAction) { action in
            Alert(
                title: Text(action.rawValue),
                message: Text("\(action.rawValue) \(keepImages.count) photos?"),
                primaryButton: .default(Text("Confirm"), action: {
                    performAction(action)
                }),
                secondaryButton: .cancel()
            )
        }
    }
    
    private var photoGrid: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 2) {
                ForEach(keepImages) { item in
                    KeepPhotoCell(item: item)
                }
            }
        }
    }
    
    private var doneButton: some View {
        VStack {
            Spacer()
            Button {
                onDone()
            } label: {
                Text("Done")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .padding(.horizontal, 24)
                    .padding(.bottom, 32)
            }
        }
    }
    
    private func performAction(_ action: KeepAction) {
        switch action {
        case .compress:
            print("Compressing \(keepImages.count) photos")
        case .album:
            print("Adding \(keepImages.count) photos to album")
        case .both:
            print("Adding to album & compressing \(keepImages.count) photos")
        }
    }
}
