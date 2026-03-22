//
//  ContentView.swift
//  Vista Japan
//
//  Created by Daniel Liu  on 17/3/2026.
//

import SwiftUI
import MapKit
import SafariServices
import Combine

// MARK: - Main View
struct ContentView: View {
    @StateObject private var viewModel = LocationViewModel()
    
    private let tokyoStation = CLLocationCoordinate2D(latitude: 35.6812, longitude: 139.7671)
    
    // 1. Added is3D state to track the perspective
    @State private var is3D = true
    @State private var position: MapCameraPosition = .camera(
        MapCamera(centerCoordinate: .init(latitude: 35.6812, longitude: 139.7671), distance: 1500, heading: 0, pitch: 60)
    )
    
    @State private var showWebView = false
    
    var body: some View {
        // ... (ZStack and MapReader remains the same)
        ZStack {
            MapReader { proxy in
                Map(position: $position) {
                    Marker("Tokyo Station", coordinate: tokyoStation)
                        .tint(.red)
                    
                    if let location = viewModel.fetchedLocation {
                        Annotation(location.name, coordinate: location.coordinate) {
                            WikiAnnotationView(imageURL: location.imageURL)
                                .onTapGesture {
                                    showWebView = true
                                }
                        }
                    }
                }
                .mapStyle(.standard(elevation: .realistic))
                .onMapCameraChange { context in
                    position = .camera(context.camera)
                    // Update is3D based on manual user tilt
                    is3D = context.camera.pitch > 0
                }
                .onTapGesture { screenPoint in
                    if let coordinate = proxy.convert(screenPoint, from: .local) {
                        viewModel.fetchWikiData(for: coordinate)
                    }
                }
            }
            
            if viewModel.isLoading {
                VStack {
                    ProgressView("Searching Wikipedia...")
                        .padding()
                        .background(.ultraThinMaterial)
                        .cornerRadius(12)
                    Spacer()
                }
                .padding(.top, 40)
            }
        }
        .safeAreaInset(edge: .bottom) {
            bottomUIOverlay
        }
        .sheet(isPresented: $showWebView) {
            if let url = viewModel.fetchedLocation?.wikiURL {
                SafariView(url: url)
                    .presentationDetents([.medium, .large])
            }
        }
    }
    
    private var bottomUIOverlay: some View {
        HStack {
            VStack(spacing: 12) {
                // Perspective Toggle Button
                Button(action: togglePerspective) {
                    Text(is3D ? "2D" : "3D")
                        .font(.system(size: 14, weight: .bold))
                        .frame(width: 44, height: 44)
                        .background(.thinMaterial)
                        .clipShape(Circle())
                }

                Button(action: { zoom(by: 0.7) }) {
                    Image(systemName: "plus.magnifyingglass")
                        .font(.title2)
                        .padding(10)
                        .background(.thinMaterial)
                        .clipShape(Circle())
                }
                Button(action: { zoom(by: 1.5) }) {
                    Image(systemName: "minus.magnifyingglass")
                        .font(.title2)
                        .padding(10)
                        .background(.thinMaterial)
                        .clipShape(Circle())
                }
            }
            .padding(.leading)

            Spacer()
            
            Button {
                withAnimation(.spring()) {
                    // Recenter now respects the 3D toggle
                    position = .camera(
                        MapCamera(centerCoordinate: tokyoStation, distance: 1500, heading: 0, pitch: is3D ? 60 : 0)
                    )
                }
            } label: {
                Label("Recenter", systemImage: "location.fill")
                    .padding()
                    .background(.thinMaterial)
                    .cornerRadius(12)
            }
            .padding()
        }
    }

    // New Function to handle the swap
    func togglePerspective() {
        is3D.toggle()
        if let camera = position.camera {
            withAnimation(.spring()) {
                position = .camera(
                    MapCamera(
                        centerCoordinate: camera.centerCoordinate,
                        distance: camera.distance,
                        heading: camera.heading,
                        pitch: is3D ? 60 : 0
                    )
                )
            }
        }
    }

    func zoom(by factor: Double) {
        if let camera = position.camera {
            withAnimation(.easeInOut) {
                position = .camera(
                    MapCamera(
                        centerCoordinate: camera.centerCoordinate,
                        distance: camera.distance * factor,
                        heading: camera.heading,
                        pitch: camera.pitch
                    )
                )
            }
        }
    }
}


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

struct SafariView: UIViewControllerRepresentable {
    let url: URL
    func makeUIViewController(context: Context) -> SFSafariViewController {
        SFSafariViewController(url: url)
    }
    func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {}
}

#Preview {
    ContentView()
}
