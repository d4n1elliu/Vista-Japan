//
//  ContentView.swift
//  Vista Japan
//
//  Created by Daniel Liu  on 17/3/2026.
//

import SwiftUI
import MapKit
import SafariServices

struct ContentView: View {
    // 1. Initial State
    private let tokyoStation = CLLocationCoordinate2D(latitude: 35.6812, longitude: 139.7671)
    
    @State private var position: MapCameraPosition = .camera(
        MapCamera(centerCoordinate: .init(latitude: 35.6812, longitude: 139.7671), distance: 1500, pitch: 60)
    )
    
    @State private var selectedMarkerID: Int?
    @State private var showWebView = false

    var body: some View {
        Map(position: $position, selection: $selectedMarkerID) {
            // Adding the tag(1) makes the marker "selectable"
            Marker("Tokyo Station", coordinate: tokyoStation)
                .tag(1)
                .tint(.red)
        }
        // Realistic 3D buildings and terrain
        .mapStyle(.standard(elevation: .realistic))
        
        // --- CRITICAL FIX: Keeps camera synced during pans ---
        .onMapCameraChange { context in
            position = .camera(context.camera)
        }
        
        // Map Control
        .mapControls {
            MapPitchToggle()
            MapCompass().mapControlVisibility(.hidden)
        }
        
        // 2. Web Import Trigger
        .onChange(of: selectedMarkerID) {
            if selectedMarkerID != nil {
                showWebView = true
            }
        }
        // Added wikipedia article
        .sheet(isPresented: $showWebView, onDismiss: { selectedMarkerID = nil }) {
            SafariView(url: URL(string: "https://en.wikipedia.org/wiki/Tokyo_Station")!)
                .presentationDetents([.medium, .large])
        }
        
        // 3. UI Overlay
        .safeAreaInset(edge: .bottom) {
            HStack {
                // Zoom Controls
                VStack(spacing: 12) {
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
                
                // Recenter Button
                Button {
                    withAnimation(.spring()) {
                        position = .camera(
                            MapCamera(centerCoordinate: tokyoStation, distance: 1500, heading: 0, pitch: 60)
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
    }

    // 4. Helper for Smooth Zooming
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

// 5. Safari Web View Wrapper
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
