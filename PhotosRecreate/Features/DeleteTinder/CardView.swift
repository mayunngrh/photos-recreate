//
//  SwipeCard.swift
//  PhotosRecreate
//
//  Created by Mayun Suryatama on 20/04/26.
//

import SwiftUI

struct CardView: View {
    let image: ImageModel
    let index: Int
    var onSwiped: (BucketType) -> Void
    
    @State private var overlayType: BucketType? = nil
    @State private var dragOffset: CGSize = .zero
    
    var body: some View {
        ZStack{
            Image(image.name)
                .resizable()
                .scaledToFill()
                .frame(width: 350, height: 520)
                .clipShape(RoundedRectangle (cornerRadius: 20))
            
            dragOverlay
            
            // Debug info
            VStack {
                Spacer()
                Text("[\(index)] \(image.name)")
                    .font(.caption.bold())
                    .foregroundColor(.white)
                    .padding(6)
                    .background(.black.opacity(0.6))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .padding(.bottom, 12)
            }
            .frame(width: 350, height: 520)
        }
        .offset(dragOffset)
        .rotationEffect(Angle(degrees: dragOffset.width / 20))
        .gesture(dragGesture)
    }
    
    private var dragGesture : some Gesture {
        DragGesture()
            .onChanged { value in
                dragOffset = value.translation
                withAnimation(.easeInOut(duration: 0.2)) {
                    if value.translation.height < -30 {
                        overlayType = .maybe
                    } else if value.translation.width < -30 {
                        overlayType = .delete
                    } else if value.translation.width > 30 {
                        overlayType = .keep
                    } else {
                        overlayType = nil
                    }
                }
            }
            .onEnded { value in
                let h = value.translation.width
                let v = value.translation.height
                
                if h < -100 {
                    flyOff(x: -550, y: 0, bucket: .delete)
                } else if h > 100 {
                    flyOff(x: 550, y: 0, bucket: .keep)
                } else if v < -100 {
                    flyOff(x: 0, y: -700, bucket: .maybe)
                } else {
                    withAnimation(.spring()) {
                        dragOffset = .zero
                        overlayType = nil
                    }
                }
            }
    }
    private func flyOff(x: CGFloat, y: CGFloat, bucket: BucketType) {
        withAnimation(.easeOut(duration: 0.3)) {
            dragOffset = CGSize(width: x, height: y)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            onSwiped(bucket)
        }
    }
    
    private var dragOverlay: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.red.opacity(0.5))
                .opacity(overlayType == .delete ? 1 : 0)
            
            Text("DELETE")
                .font(.largeTitle.bold())
                .foregroundColor(.white)
                .opacity(overlayType == .delete ? 1 : 0)
            
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.green.opacity(0.5))
                .opacity(overlayType == .keep ? 1 : 0)
            
            Text("KEEP")
                .font(.largeTitle.bold())
                .foregroundColor(.white)
                .opacity(overlayType == .keep ? 1 : 0)
            
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.orange.opacity(0.5))
                .opacity(overlayType == .maybe ? 1 : 0)
            
            Text("MAYBE")
                .font(.largeTitle.bold())
                .foregroundColor(.white)
                .opacity(overlayType == .maybe ? 1 : 0)
        }
        .frame(width: 350, height: 520)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}

