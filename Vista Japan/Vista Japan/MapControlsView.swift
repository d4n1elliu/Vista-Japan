//
//  MapControlsView.swift
//  Vista Japan
//
//  Created by Daniel Liu  on 22/3/2026.
//

import SwiftUI
import MapKit

struct MapControlsView: View {
    // These Bindings allow this file to talk back to ContentView
    @Binding var position: MapCameraPosition
    @Binding var is3D: Bool
    let tokyoStation: CLLocationCoordinate2D
    
    var body: some View {
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

    // Logic moved from ContentView
    private func togglePerspective() {
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

    private func zoom(by factor: Double) {
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
