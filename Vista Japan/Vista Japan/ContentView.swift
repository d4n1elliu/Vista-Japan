//
//  ContentView.swift
//  Vista Japan
//
//  Created by Daniel Liu  on 17/3/2026.
//

import SwiftUI
import MapKit

// Main App View
struct ContentView: View {
    @StateObject private var viewModel = LocationViewModel()
    
    private let tokyoStation = CLLocationCoordinate2D(latitude: 35.6812, longitude: 139.7671)
    
    @State private var is3D = true
    @State private var position: MapCameraPosition = .camera(
        MapCamera(centerCoordinate: .init(latitude: 35.6812, longitude: 139.7671), distance: 1500, heading: 0, pitch: 60)
    )
    
    @State private var showWebView = false
    
    var body: some View {
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
            // This replaces the old bottomUIOverlay
            MapControlsView(
                position: $position,
                is3D: $is3D,
                tokyoStation: tokyoStation
            )
        }
        // Replace your current .sheet block with this
        .sheet(isPresented: $showWebView) {
            if let location = viewModel.fetchedLocation {
                SafariView(url: location.googleMapsURL)
                    .presentationDetents([.medium, .large])
            }
        }
    }
}
#Preview {
    ContentView()
}
