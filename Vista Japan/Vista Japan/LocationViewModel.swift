//
//  LocationViewModel.swift
//  Vista Japan
//
//  Created by Daniel Liu  on 22/3/2026.
//

import Foundation
import SwiftUI
import MapKit
import Combine

class LocationViewModel: ObservableObject {
    @Published var fetchedLocation: PlaceData?
    @Published var isLoading = false
    
    private var activeSearch: MKLocalSearch?

    struct PlaceData {
        let name: String
        let coordinate: CLLocationCoordinate2D
        let imageURL: String? // Add this back as an optional
        let googleMapsURL: URL
    }

    func fetchWikiData(for coordinate: CLLocationCoordinate2D) {
        isLoading = true
        activeSearch?.cancel()
        
        let request = MKLocalSearch.Request()
        request.pointOfInterestFilter = .includingAll
        request.region = MKCoordinateRegion(
            center: coordinate,
            latitudinalMeters: 50,
            longitudinalMeters: 50
        )
        
        activeSearch = MKLocalSearch(request: request)
        activeSearch?.start { [weak self] response, error in
            guard let self = self else { return }
            defer { DispatchQueue.main.async { self.isLoading = false } }
            
            guard let item = response?.mapItems.first else { return }
            
            let name = item.name ?? item.placemark.name ?? "Dropped Pin"
            
            // Format for Google Maps Universal Link
            let lat = coordinate.latitude
            let lon = coordinate.longitude
            let urlString = "https://www.google.com/maps/search/?api=1&query=\(lat),\(lon)"
            
            guard let url = URL(string: urlString) else { return }
            
            DispatchQueue.main.async {
                self.fetchedLocation = PlaceData(
                    name: name,
                    coordinate: coordinate,
                    imageURL: nil, // Default to nil for now
                    googleMapsURL: url
                )
            }
        }
    }
}
