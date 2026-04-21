//
//  SwipeCard.swift
//  PhotosRecreate
//
//  Created by Mayun Suryatama on 20/04/26.
//

import SwiftUI

struct SwipeCardView : View{
    @State private var images : [ImageModel] = ImageModel.imageSet
    @State private var currentIndex: Int = 0
    @State private var showSummary: Bool = false
    
    private var remainingImages: ArraySlice<ImageModel> {
        images[currentIndex...]
    }
    
    var body: some View{
        VStack {
            if showSummary {
                SummaryView(images: images, onReset: {
                    images = ImageModel.imageSet
                    showSummary = false
                })
            } else if currentIndex >= images.count {
                Button("Review Result"){
                    showSummary = true
                }
            } else{
                ZStack{
                    ForEach(remainingImages.indices.reversed(), id: \.self){ index in
                        let stackPosition = index - currentIndex
                        CardView(image: images[index], index: index, onSwiped: { bucket in
                            handleSwipe(bucket: bucket)
                        })
                        .scaleEffect(1 - CGFloat(stackPosition) * 0.03)
                        .offset(y: CGFloat(stackPosition) * 8)
                    }
                }
            }
            
            
            // Debug button
            Button("Print images (\(images.count))") {
                print("--- images array ---")
                for (i, img) in images.enumerated() {
                    print("[\(i)] \(img.name) bucket: \(img.bucket?.rawValue ?? "nil")")
                }
                print("--------------------")
            }
            .padding(.top, 20)
            .font(.caption)
        }
    }
    
    private func handleSwipe(bucket: BucketType) {
        guard currentIndex < images.count else { return }
        images[currentIndex].bucket = bucket
        currentIndex += 1
    }
}

#Preview {
    SwipeCardView()
}
