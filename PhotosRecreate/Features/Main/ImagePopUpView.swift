//
//  ImagePopUpView.swift
//  PhotosRecreate
//
//  Created by Alex on 22/04/26.
//

import SwiftUI

//delete

struct ImagePopUpScrollView: View {
    @State var id : String
    var body: some View {
        Image(id)
            .resizable()
            .aspectRatio(1, contentMode:.fill)
            .clipped()
            .cornerRadius(4)
    }
}

struct ImagePopUpView: View {
    @Binding var imageId : String
    @Binding var isPresented: Bool
    @Binding var image: ImageModel
    var body: some View {
        let rows = [GridItem(.fixed(60))]
        
        NavigationStack{
            VStack{
                if image.imageData != Data() {
                    if let uiImage: UIImage = UIImage(data: image.imageData)
                    {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFit()
                    }

                }
                else{
                    Image(imageId)
                        .resizable()
                        .scaledToFit()
                }
                
                
            }.toolbarTitleDisplayMode(.inline)
                .toolbar{
                    ToolbarItem(placement: .topBarLeading){
                        Button(action: {
                            self.isPresented.toggle()
                        }) {
                            Label("Close", systemImage: "xmark")
                        }
                    }
                    
                    ToolbarItem(placement: .topBarTrailing){
                        Menu {
                            Button(action: {}) {
                                HStack {
                                    Text("Copy")
                                    Image(systemName: "document.on.document")
                                }
                            }
                            Button(action: {}) {
                                HStack {
                                    Text("Duplicate")
                                    Image(systemName: "plus.square.on.square")
                                }
                            }
                            Button(action: {}) {
                                HStack {
                                    Text("Hide")
                                    Image(systemName: "eye.slash")
                                }
                            }
                            Button(action: {}) {
                                HStack {
                                    Text("Slideshow")
                                    Image(systemName: "play.rectangle")
                                }
                            }
                            Divider()
                            Button(action: {}) {
                                HStack {
                                    Text("Add to Album")
                                    Image(systemName: "rectangle.stack.badge.plus")
                                }
                            }
                            Button(action: {}) {
                                HStack {
                                    Text("Move to Shared Library")
                                    Image(systemName: "person.2")
                                }
                            }
                            Divider()
                            Button(action: {}) {
                                HStack {
                                    Text("Adjust Date & Time")
                                    Image(systemName: "calendar.badge.clock")
                                }
                            }
                            Button(action: {}) {
                                HStack {
                                    Text("Adjust Location")
                                    Image(systemName: "mappin.circle")
                                }
                            }
                            Divider()
                            Button(role: .destructive, action: {}) {
                                HStack {
                                    Text("Delete").foregroundStyle(.red)
                                    Image(systemName: "trash")
                                }
                            }
                        }
                        label: {
                            Label("Options", systemImage: "line.3.horizontal.decrease")
                        }
                    }
                    ToolbarSpacer(placement: .topBarTrailing)
                    
                }.navigationTitle("Hello, world!")
                .navigationSubtitle("Subtitle")
        }
        .overlay(){
            ScrollView(.horizontal){
                LazyHGrid(rows: rows) {
                    @State  var selectedItems: [Image] = []
// dothis
//                    ForEach(images, id: \.self) {
//                        image in
////                        Image(image)
//                        ImagePopUpScrollView(id: image)
//                        .onTapGesture {
//                            imageId = image
//                            }
//                    }
                }
            }.offset(y:300)
        }
    }
}




