//
//  MaybeReviewView.swift
//  PhotosRecreate
//
//  Created by Mayun Suryatama on 21/04/26.
//

import SwiftUI

struct MaybeReviewView :View {
    @Binding var images: [ImageModel]
    var onNext : () -> Void
    
    @State private var isSelectionMode: Bool = false
    @State private var selectedIDs: Set<UUID> = []
    @State private var fullscreenImage :ImageModel? = nil
    @State private var showKeepConfirmation: Bool = false
    
    private var maybeImages: [ImageModel] {
        images.filter{$0.bucket == .maybe}
    }
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        NavigationView{
            ZStack{
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 8) {
                        ForEach(maybeImages) { item in
                            MaybePhotoCell(
                                item: item,
                                isSelectionMode: isSelectionMode,
                                isSelected: selectedIDs.contains(item.id),
                                onHold: { fullscreenImage = item },
                                onTap: {handleOnTap(item: item)}
                            )
                        }
                    }
                    .padding()
                }
                
                if let photo = fullscreenImage {
                    fullscreenOverlay(photo)
                }
                
                if isSelectionMode {
                    keepButton
                } else{
                    nextButton
                }
            }
            .navigationTitle("Maybe (\(maybeImages.count))")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar{
                ToolbarItem(placement: .topBarTrailing) {
                    if isSelectionMode{
                        Button("Cancel"){
                            isSelectionMode = false
                            selectedIDs = []
                        }
                    }
                }
                ToolbarSpacer(placement: .topBarTrailing)
                ToolbarItem(placement: .topBarTrailing) {
                    if isSelectionMode{
                    } else {
                        Button("Select"){
                            isSelectionMode = true
                        }
                    }
                }
            }
        }
        .alert("Confirm", isPresented: $showKeepConfirmation) {
            Button("Confirm", role: .destructive) {
                applyKeep()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            let deleteCount = maybeImages.count - selectedIDs.count
            Text("Keep \(selectedIDs.count) photos and move \(deleteCount) photos to DELETE?")
        }
        
    }
    private func fullscreenOverlay(_ item: ImageModel) -> some View {
        ZStack {
            Color.black.opacity(0.5)
                .ignoresSafeArea()
                .onTapGesture { fullscreenImage = nil }
            
            Image(item.name)
                .resizable()
                .scaledToFit()
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .padding(24)
        }
    }
    private var keepButton: some View {
        VStack {
            Spacer()
            Button {
                showKeepConfirmation = true
            } label: {
                Text("Keep \(selectedIDs.count) photos")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(selectedIDs.isEmpty ? Color.gray : Color.green)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .padding(.horizontal, 24)
                    .padding(.bottom, 32)
            }
            .disabled(selectedIDs.isEmpty)
        }
    }
    private var nextButton: some View {
        VStack {
            Spacer()
            Button {
                
            } label: {
                Text("Next")
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
    private func applyKeep() {
        for index in images.indices {
            guard images[index].bucket == .maybe else { continue }

            if selectedIDs.contains(images[index].id) {
                images[index].bucket = .keep
            } else {
                images[index].bucket = .delete
            }
        }
        isSelectionMode = false
        selectedIDs = []
    }
    private func handleOnTap(item: ImageModel) {
        if isSelectionMode {
            if selectedIDs.contains(item.id){
                selectedIDs.remove(item.id)
            } else{
                selectedIDs.insert(item.id)
            }
        } else{
            fullscreenImage = item
        }
    }
}

#Preview {
    @Previewable @State var images = ImageModel.imageSet.map { img in
        var copy = img
        copy.bucket = .maybe
        return copy
    }
    MaybeReviewView(images: $images, onNext: {})
}
