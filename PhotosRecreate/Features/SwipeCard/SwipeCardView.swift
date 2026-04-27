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
    @State private var undoHistory: [(index: Int, previousBucket: BucketType?)] = []
    @State private var imageCache: [UUID: UIImage] = [:]

    private let preloadCount = 5

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
                let images = allImages.filter { selectedIDs.contains($0.id) }
                images.forEach { $0.bucket = nil }
                allSortedImages = images
                preloadImages(from: 0)
            }
        }
        .onChange(of: allImages) { _, newImages in
            if allSortedImages.isEmpty {
                let images = newImages.filter { selectedIDs.contains($0.id) }
                images.forEach { $0.bucket = nil }
                allSortedImages = images
                preloadImages(from: 0)
            }
        }
        .onChange(of: currentIndex) { _, newIndex in
            preloadImages(from: newIndex)
        }
    }

    private var swipingView: some View {
        VStack(spacing: 0) {
            HStack {
                Button(action: handleUndo) {
                    Image(systemName: "arrow.uturn.left")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.primary)
                        .frame(width: 36, height: 36)
                        .background(.regularMaterial, in: Circle())
                }
                .disabled(undoHistory.isEmpty)
                .opacity(undoHistory.isEmpty ? 0.4 : 1)
                .animation(.easeInOut(duration: 0.2), value: undoHistory.isEmpty)

                Spacer()

                HStack(spacing: 4) {
                    Text("\(max(0, allSortedImages.count - currentIndex))")
                        .font(.subheadline.weight(.semibold))
                        .monospacedDigit()
                        .contentTransition(.numericText(countsDown: true))
                        .animation(.spring(duration: 0.4), value: currentIndex)
                    Text("left")
                        .font(.subheadline.weight(.semibold))
                }
                .foregroundStyle(.primary)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(.regularMaterial, in: Capsule())
            }
            .padding(.horizontal)
            .padding(.top, 8)
            .padding(.bottom, 16)

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
                        CardView(
                            image: allSortedImages[index],
                            cachedImage: imageCache[allSortedImages[index].id],
                            onSwiped: { bucket in handleSwipe(bucket: bucket) }
                        )
                        .scaleEffect(1 - CGFloat(stackPosition) * 0.03)
                        .offset(y: CGFloat(stackPosition) * 8)
                    }
                }
            }
            .frame(minHeight: 500)

            HStack(spacing: 0) {
                bucketCounter(icon: "trash.fill", color: .red, count: deleteCount)
                Divider().frame(height: 32)
                bucketCounter(icon: "questionmark.circle.fill", color: .orange, count: maybeCount)
                Divider().frame(height: 32)
                bucketCounter(icon: "checkmark.circle.fill", color: .green, count: keepCount)
            }
            .padding(.vertical, 14)
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 24))
            .padding(.horizontal)
            .padding(.top, 16)
        }
    }

    private func bucketCounter(icon: String, color: Color, count: Int) -> some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .foregroundStyle(color)
                .font(.system(size: 18))
            Text("\(count)")
                .font(.headline.weight(.bold))
                .monospacedDigit()
                .contentTransition(.numericText())
                .animation(.spring(duration: 0.3), value: count)
        }
        .frame(maxWidth: .infinity)
    }

    private func handleSwipe(bucket: BucketType) {
        guard currentIndex < allSortedImages.count else { return }
        let previousBucket = allSortedImages[currentIndex].bucket
        undoHistory.append((index: currentIndex, previousBucket: previousBucket))
        allSortedImages[currentIndex].bucket = bucket
        currentIndex += 1
    }

    private func handleUndo() {
        guard let lastAction = undoHistory.popLast() else { return }
        currentIndex = lastAction.index
        allSortedImages[lastAction.index].bucket = lastAction.previousBucket
    }

    private func preloadImages(from index: Int) {
        let end = min(index + preloadCount + 2, allSortedImages.count)
        guard index < end else { return }
        for i in index..<end {
            let model = allSortedImages[i]
            guard imageCache[model.id] == nil else { continue }
            let data = model.imageData
            let id = model.id
            Task.detached(priority: .userInitiated) {
                guard let uiImage = UIImage(data: data) else { return }
                await MainActor.run { imageCache[id] = uiImage }
            }
        }
    }

    private var deleteCount: Int {
        allSortedImages.filter { $0.bucket == .delete }.count
    }

    private var maybeCount: Int {
        allSortedImages.filter { $0.bucket == .maybe }.count
    }

    private var keepCount: Int {
        allSortedImages.filter { $0.bucket == .keep }.count
    }
}
