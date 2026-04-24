//
//  MaybePhotoCell.swift
//  PhotosRecreate
//
//  Created by Mayun Suryatama on 21/04/26.
//
import SwiftUI

struct MaybePhotoCell : View{
    let item: ImageModel
    var isSelectionMode: Bool
    var isSelected : Bool
    var onHold : () -> Void
    var onTap: () -> Void
    var namespace: Namespace.ID
    var isFullscreen: Bool
    
    @State private var isPressed: Bool = false
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            Color.clear
                .aspectRatio(1, contentMode: .fit)
                .overlay(
                    Image(uiImage: UIImage(data: item.imageData) ?? UIImage())
                        .resizable()
                        .scaledToFill()
                )
                .clipped()
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.green.opacity(isSelected ? 0.3 : 0))
                        .animation(.easeInOut(duration: 0.2), value: isSelected)
                )
            
            if isSelected {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.blue)
                    .background(Color.white.clipShape(Circle()))
                    .padding(6)
                    .transition(.scale)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 3))
        .opacity(isFullscreen ? 0 : 1)
        .matchedGeometryEffect(id: item.id, in: namespace)
        .onTapGesture(perform: onTap)
        .onLongPressGesture(perform: onHold)
    }
}
