//
//  ImageTab.swift
//  BennySpeak
//
//  Created by James on 11/18/25.
//

import SwiftUI

struct ImageRow: View {
    
    var imageUrl: String
    var name: String
    var imageMeta: SearchImage?
    
    init(imageUrl: String, name: String, imageMeta: SearchImage?) {
        self.imageUrl = imageUrl
        self.name = name
        self.imageMeta = imageMeta
    }
    
    @ViewBuilder
    private var placeholderView: some View {
        ZStack {
            if let thumbURL = URL(string: imageMeta?.thumbnailLink ?? "") {
                AsyncImage(url: thumbURL) { phase in
                    if case .success(let thumbImage) = phase {
                        thumbImage
                            .resizable()
                            .scaledToFill()
                    } else {
                        Color.gray.opacity(0.2)
                    }
                }
            } else {
                Color.gray.opacity(0.2)
            }
            ProgressView()
        }
        .frame(width: 600, height: 600)
        .clipped()
        .cornerRadius(24)
    }
    
    var body: some View {
        VStack {
            Text(name)
                .font(.largeTitle)
                .bold()
                .multilineTextAlignment(.center)
                .foregroundStyle(.white)
                .frame(width: 600)
            if let url = URL(string: self.imageUrl) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 600, height: 600)
                            .clipped()
                            .cornerRadius(24)
                    case .failure:
                        placeholderView
                    case .empty:
                        placeholderView
                    @unknown default:
                        placeholderView
                    }
                }
            } else {
                Image(systemName: "xmark")
                    .font(.title)          // size via font
                    .foregroundStyle(.red)
                    .padding(8)
                    .background(.black.opacity(0.6))
                    .clipShape(Circle())
            }
        }
    }
}
