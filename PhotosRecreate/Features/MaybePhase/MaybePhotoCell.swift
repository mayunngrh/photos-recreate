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

    
    var body: some View {
        ZStack(alignment: .topTrailing){
            Image(item.name)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(minWidth: 0, maxWidth: .infinity)
                .aspectRatio(1, contentMode: .fill)
                .clipShape(RoundedRectangle(cornerRadius: 3))
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
        .onTapGesture { onTap() }
        .onLongPressGesture { onHold() }
    }
}
