//
//  WikiAnnotationView.swift
//  Vista Japan
//
//  Created by Daniel Liu  on 22/3/2026.
//

import Foundation
import SwiftUI
import MapKit
import Combine

// MARK: - Helper Views

struct WikiAnnotationView: View {
    let imageURL: String?
    @State private var isAnimating = false

    var body: some View {
        Group {
            if let urlString = imageURL, let url = URL(string: urlString) {
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 50, height: 50)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.white, lineWidth: 2))
                } placeholder: {
                    ProgressView().frame(width: 50, height: 50)
                }
            } else {
                Image(systemName: "book.closed.circle.fill")
                    .resizable()
                    .frame(width: 50, height: 50)
                    .foregroundStyle(.blue)
                    .background(Color.white)
                    .clipShape(Circle())
            }
        }
        .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 3)
        .scaleEffect(isAnimating ? 1.05 : 0.95)
        .onAppear {
            withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) {
                isAnimating = true
            }
        }
    }
}
