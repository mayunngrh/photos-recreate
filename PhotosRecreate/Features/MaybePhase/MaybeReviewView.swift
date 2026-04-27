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
    
    @Namespace private var namespace
    
    @State private var isSelectionMode: Bool = false
    @State private var selectedIDs: Set<UUID> = []
    @State private var fullscreenImage :ImageModel? = nil
    @State private var showKeepConfirmation: Bool = false
    
    private var maybeImages: [ImageModel] {
        images.filter{$0.bucket == .maybe}
    }
    
    let columns = [
        GridItem(.flexible(),spacing: 2),
        GridItem(.flexible(),spacing: 2),
        GridItem(.flexible(),spacing: 2),
    ]
    
    var body: some View {
        NavigationView{
            ZStack{
                photoGrid
                
                if let photo = fullscreenImage {
                       fullscreenOverlay(photo)
                           .zIndex(999)
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
    private var photoGrid: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 2) {
                ForEach(maybeImages) { item in
                    MaybePhotoCell(
                        item: item,
                        isSelectionMode: isSelectionMode,
                        isSelected: selectedIDs.contains(item.id),
                        onHold: {
                            withAnimation(.spring(duration: 0.4)) {
                                fullscreenImage = item
                            }
                        },
                        onTap: { handleOnTap(item: item) },
                        namespace: namespace,
                        isFullscreen: fullscreenImage?.id == item.id
                    )
                }
            }
        }
    }
    private func fullscreenOverlay(_ item: ImageModel) -> some View {
        ZStack {
            Color.black.opacity(0.5)
                .ignoresSafeArea()
                .onTapGesture {
                    withAnimation(.spring(duration: 0.4)) {
                        fullscreenImage = nil
                    }
                }
            
            if let uiImage = UIImage(data: item.imageData) {
                Image(uiImage: UIImage(data: item.imageData) ?? UIImage())
                    .resizable()
                    .scaledToFit()
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .padding(24)
                    .matchedGeometryEffect(id: item.id, in: namespace)
                    .onTapGesture {
                        withAnimation(.spring(duration: 0.4)) {
                            fullscreenImage = nil
                        }
                    }
            }
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
                for index in images.indices {
                    if images[index].bucket == .maybe {
                        images[index].bucket = .delete
                    }
                }
                onNext() 
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
        onNext()
    }
    private func handleOnTap(item: ImageModel) {
        if isSelectionMode {
            if selectedIDs.contains(item.id) {
                selectedIDs.remove(item.id)
            } else {
                selectedIDs.insert(item.id)
            }
        } else {
            withAnimation(.spring(duration: 0.4)) {  
                fullscreenImage = item
            }
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
