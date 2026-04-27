//
//  AdvancedDeleteWrapper.swift
//  PhotosRecreate
//
//  Created by Mayun Suryatama on 23/04/26.
//

import SwiftUI

struct AdvancedDeleteWrapper: View {
    let selectedIDs: [UUID]
    @Binding var isPresented: Bool

    var body: some View {
        SwipeCardView(selectedIDs: selectedIDs)
            .onAppear {
                print("--- wrapper selectedIDs ---")
                print("count: \(selectedIDs.count)")
                for id in selectedIDs { print(id) }
                print("---------------------------")
            }
    }
}

