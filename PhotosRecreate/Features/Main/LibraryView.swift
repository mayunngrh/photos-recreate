//
//  LibraryView.swift
//  PhotosRecreate
//
//  Created by Alex on 22/04/26.
//


import SwiftUI
import PhotosUI
import SwiftData



struct PhotoView: View {
    @Binding var isSelectMode: Bool
    @Binding var selectedImageData: [ImageModel]
    @Binding var image: ImageModel
    @State private var presentImage: Bool = false
    
    var body: some View {
        if let uiImage: UIImage = UIImage(data: image.imageData)
        {
            Image(uiImage: uiImage)
                .resizable()
                .aspectRatio(1, contentMode:.fill)
                .clipped()
                .cornerRadius(4)
                .opacity(image.isSelected ? 0.3 : 1)
                .overlay(alignment: .bottomTrailing){
                    
                    if image.isSelected {
                        ZStack {
                            Circle()
                                .fill(Color.blue)
                                .stroke(Color.white, lineWidth: 2)
                                .frame(width: 20, height: 20)
                                .offset(x: -10,y: -10)
                            Image(systemName: "checkmark")
                                .foregroundStyle(.white)
                                .frame(width: 10, height: 10)
                                .font(.system(size: 10, weight: .bold))
                                .offset(x: -10,y: -10)
                        }
                    }
                    
                }
            
                .onTapGesture {
                    if isSelectMode {
                        image.isSelected.toggle()
                    } else {
                        presentImage = true
                    }
                    
                }.fullScreenCover(isPresented: $presentImage) {
                    ImagePopUpView(imageId: $image.name, isPresented: $presentImage, image: $image)
                        .presentationDragIndicator(.visible)
                }
        }
        
        
    }
    
}

struct GalleryView: View {
    @Binding var gallery: [ImageModel]
    @Binding var isSelectMode: Bool
    @Binding var selectedImageData: [ImageModel]
    var body: some View {
        let columns = [GridItem(.flexible(), spacing: 2),
                       GridItem(.flexible(), spacing: 2),
                       GridItem(.flexible(), spacing: 2)
        ]
        LazyVGrid(columns: columns,spacing: 2,
        ) {
            @State  var selectedItems: [String] = []
            ForEach($gallery) {
                $itemImage in
                PhotoView(isSelectMode: $isSelectMode,
                          selectedImageData: $selectedImageData,image: $itemImage)
            }
        }
        
    }
    
}

struct LibraryView: View {
    
    @State var selectedItem: [PhotosPickerItem] = []
    @Binding var gallery:[ImageModel]
    @Binding var isSelectMode: Bool
    @Binding var selectedImageData: [ImageModel]
    @Environment(\.modelContext) var databaseContext
    @Query var items: [ImageModel]
    
    
    var body: some View {
        NavigationStack{
            ScrollView{
                GalleryView(gallery: $gallery, isSelectMode: $isSelectMode, selectedImageData: $selectedImageData)
            }
            .toolbarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading){
                    PhotosPicker(selection: $selectedItem, matching: .images) {
                        Label("Choose Photo", systemImage: "photo")
                    }
                }
                ToolbarItem(placement: .topBarTrailing){
                    Menu {
                        
                        Button("Sort by Recently Added", action: {
                            
                        }
                        )
                        
                        Button("Sort by Date Captured", action: {})
                        Divider()
                        Button("Both Libraries", action: {})
                        Button("Personal Library", action: {})
                        Button("Shared Library", action: {})
                        Divider()
                        Button("Advanced Delete", action: {
                            let selectedImageDatapp: [ImageModel] =
                            gallery.filter { image in
                                image.isSelected
                            }
                            
                            let selectedImageId: [UUID] = selectedImageDatapp.map(\.id)

                            
                            // nanti kirim ini aja ke tempat uselectedImageId
                            
                            
                        })
                        Button("Delete", action: {
                            
                            let selectedImageDatapp: [ImageModel] =
                            gallery.filter { image in
                                image.isSelected
                            }
                            
                            for item in selectedImageDatapp{
                                if let index = gallery.firstIndex(of: item) {
                                    gallery.remove(at: index)
                                    databaseContext.delete(item)
                                }
                            }
                            
                        })
                        
                        
                        
                    }
                    label: {
                        Label("Options", systemImage: "line.3.horizontal.decrease")
                    }
                    
                }
                ToolbarSpacer(placement: .topBarTrailing)
                ToolbarItemGroup(placement: .topBarTrailing){
                    if isSelectMode {
                        Image(systemName: "xmark").onTapGesture {
                            isSelectMode.toggle()
                            gallery.indices.forEach { index in
                                gallery[index].isSelected = false
                            }
                        }
                    }
                    else {
                        Text("Select").onTapGesture {
                            isSelectMode.toggle()
                            print(isSelectMode)
                        }
                        
                    }
                    
                    
                    
                    
                }
            }.navigationTitle("Hello, world!")
                .navigationSubtitle("Subtitle")
            
        }
        .onChange(of: selectedItem) { _, _ in
            print("close")
            Task {
                if !selectedItem.isEmpty{
                    for item in selectedItem {
                        if let data = try? await item.loadTransferable(type: Data.self) {
                            let newImage = ImageModel(name: UUID().uuidString, imageData: data)
                            databaseContext.insert(newImage)
                            gallery.append(newImage)
                            print(databaseContext.insert(newImage))
                        }
                    }
                }
                selectedItem.removeAll()
            }
        }
    }
}






#Preview {
    MainTabView()
}


