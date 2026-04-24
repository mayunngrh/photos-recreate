//
//  SwipeCard.swift
//  PhotosRecreate
//
//  Created by Mayun Suryatama on 20/04/26.
//

import SwiftUI
import SwiftData

struct SwipeCardView: View {
    let selectedIDs: [UUID]

    @Environment(\.dismiss) private var dismiss
    @Query private var allImages: [ImageModel]
    @State private var allSortedImages: [ImageModel] = []
    @State private var currentIndex: Int = 0
    @State private var phase: ReviewPhase = .swiping

    private let preloadCount = 3

    var body: some View {
        VStack {
            switch phase {
            case .swiping:
                swipingView
                
            case .maybeReviewing:
                MaybeReviewView(images: $allSortedImages, onNext: {
                    phase = .deleteReview
                })

            case .deleteReview:
                DeleteReviewView(images: $allSortedImages, onNext: {
                    phase = .keepReviewing
                })

            case .keepReviewing:
                KeepReviewView(images: $allSortedImages, onDone: {
                    dismiss()
                })
            }

            // Debug button
//            Button("Print images (\(allSortedImages.count))") {
//                print("--- images array ---")
//                for (i, img) in allSortedImages.enumerated() {
//                    print("[\(i)] \(img.name) bucket: \(String(describing: img.bucket))")
//                }
//                print("currentIndex: \(currentIndex)")
//                print("--------------------")
//            }
//            .padding(.top, 20)
//            .font(.caption)
        }
        .onAppear {
            if allSortedImages.isEmpty {
                allSortedImages = allImages.filter { selectedIDs.contains($0.id) }
            }
        }
        .onChange(of: allImages) { _, newImages in
            if allSortedImages.isEmpty {
                allSortedImages = newImages.filter { selectedIDs.contains($0.id) }
            }
        }
    }

    private var swipingView: some View {
        ZStack {
            if currentIndex >= allSortedImages.count {
                Button("Review Photos") {
                    phase = .maybeReviewing
                }
                .buttonStyle(.borderedProminent)
            } else {
                let endIndex = min(currentIndex + preloadCount, allSortedImages.count)
                let visibleRange = (currentIndex..<endIndex).reversed()

                ForEach(Array(visibleRange), id: \.self) { index in
                    let stackPosition = index - currentIndex
                    CardView(image: allSortedImages[index], onSwiped: { bucket in
                        handleSwipe(bucket: bucket)
                    })
                    .scaleEffect(1 - CGFloat(stackPosition) * 0.03)
                    .offset(y: CGFloat(stackPosition) * 8)
                }
            }
        }
    }

    private func handleSwipe(bucket: BucketType) {
        guard currentIndex < allSortedImages.count else { return }
        allSortedImages[currentIndex].bucket = bucket
        currentIndex += 1  
    }
}
