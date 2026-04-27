//
//  Untitled.swift
//  PhotosRecreate
//
//  Created by Mayun Suryatama on 21/04/26.
//

import SwiftUI

struct SummaryView: View {
    let images: [ImageModel]
    var onReset: () -> Void  

    // split images into 3 buckets
    private var toDelete: [ImageModel] { images.filter { $0.bucket == .delete } }
    private var maybe:    [ImageModel] { images.filter { $0.bucket == .maybe  } }
    private var toKeep:   [ImageModel] { images.filter { $0.bucket == .keep   } }

    var body: some View {
        NavigationView {
            List {
                bucketSection("🗑 Delete (\(toDelete.count))", items: toDelete, color: .red)
                bucketSection("🤔 Maybe (\(maybe.count))",    items: maybe,    color: .orange)
                bucketSection("💚 Keep (\(toKeep.count))",    items: toKeep,   color: .green)
            }
            .navigationTitle("Review Buckets")
            .toolbar {
                ToolbarItem(placement: .bottomBar) {
                    Button("Confirm & Delete \(toDelete.count) photos") {
                        performDelete()
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.red)
                    .disabled(toDelete.isEmpty)
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Start Over", action: onReset)
                }
            }
        }
    }

    private func bucketSection(_ title: String, items: [ImageModel], color: Color) -> some View {
        Section(header: Text(title).foregroundColor(color)) {
            ForEach(items) { item in
                HStack {
                    Image(item.name)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 60, height: 60)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    Text(item.name)
                        .font(.subheadline)
                }
            }
        }
    }

    private func performDelete() {
        let toDeleteNames = toDelete.map { $0.name }
        print("Deleting: \(toDeleteNames)")

        // later when SwiftData is ready:
        // let toDeleteIDs = toDelete.map { $0.id }
        // modelContext.deletePhotos(ids: toDeleteIDs)
    }
}
