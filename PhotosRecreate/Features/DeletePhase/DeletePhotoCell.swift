//
//  DeletePhotoCell.swift
//  PhotosRecreate
//
//  Created by Mayun Suryatama on 24/04/26.
//

import SwiftUI

struct DeletePhotoCell: View {
    let item: ImageModel
    
    var body: some View {
        Color.clear
            .aspectRatio(1, contentMode: .fit)
            .overlay(
                Image(uiImage: UIImage(data: item.imageData) ?? UIImage())
                    .resizable()
                    .scaledToFill()
            )
            .clipped()
            .overlay(
                RoundedRectangle(cornerRadius: 3)
                    .fill(Color.red.opacity(0.2))
            )
            .clipShape(RoundedRectangle(cornerRadius: 3))
    }
}
