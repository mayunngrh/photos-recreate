//
//  DeleteReviewView.swift
//  PhotosRecreate
//
//  Created by Mayun Suryatama on 24/04/26.
//

import SwiftUI
import SwiftData

struct DeleteReviewView: View {
    @Binding var images: [ImageModel]
    var onNext: () -> Void
    
    @Environment(\.modelContext) var databaseContext
    @State private var showConfirmation: Bool = false
    
    private var deleteImages: [ImageModel] {
        images.filter { $0.bucket == .delete }
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
                
                deleteButton
            }
            .navigationTitle("Delete (\(deleteImages.count))")
            .navigationBarTitleDisplayMode(.inline)
        }
        .alert("Permanent Delete", isPresented: $showConfirmation) {
            Button("Delete", role: .destructive) {
                performDelete()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("\(deleteImages.count) photos will be permanently deleted. This cannot be undone.")
        }
    }
    
    private var photoGrid: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 2) {
                ForEach(deleteImages) { item in
                    DeletePhotoCell(item: item)
                }
            }
        }
    }
    
    private var deleteButton: some View {
        VStack {
            Spacer()
            Button {
                showConfirmation = true
            } label: {
                Text("Delete \(deleteImages.count) photos")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(deleteImages.isEmpty ? Color.gray : Color.red)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .padding(.horizontal, 24)
                    .padding(.bottom, 32)
            }
            .disabled(deleteImages.isEmpty)
        }
    }
    
    private func performDelete() {
        let toDelete = images.filter { $0.bucket == .delete }
        for item in toDelete {
            databaseContext.delete(item)
        }
        images.removeAll { $0.bucket == .delete }
        try? databaseContext.save()
        onNext()
    }
}
