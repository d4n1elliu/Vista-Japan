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

// Location View Model
class LocationViewModel: ObservableObject {
    @Published var fetchedLocation: PlaceData?
    @Published var isLoading = false
    private let geocoder = CLGeocoder()

    struct PlaceData {
        let name: String
        let coordinate: CLLocationCoordinate2D
        let imageURL: String?
        let wikiURL: URL
    }

    func fetchWikiData(for coordinate: CLLocationCoordinate2D) {
        isLoading = true
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        
        geocoder.reverseGeocodeLocation(location) { placemarks, _ in
            guard let place = placemarks?.first,
                  let name = place.name ?? place.locality ?? place.administrativeArea else {
                DispatchQueue.main.async { self.isLoading = false }
                return
            }
            
            let query = name.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
            let urlString = "https://en.wikipedia.org/w/api.php?action=query&prop=pageimages&format=json&piprop=original|thumbnail&pithumbsize=500&titles=\(query)&redirects=1"
            
            guard let url = URL(string: urlString) else { return }
            
            URLSession.shared.dataTask(with: url) { data, _, _ in
                defer { DispatchQueue.main.async { self.isLoading = false } }
                
                guard let data = data,
                      let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                      let queryNode = json["query"] as? [String: Any],
                      let pages = queryNode["pages"] as? [String: Any],
                      let firstPage = pages.values.first as? [String: Any] else { return }
                
                let original = firstPage["original"] as? [String: Any]
                let thumbnail = firstPage["thumbnail"] as? [String: Any]
                let imageSource = (original?["source"] as? String) ?? (thumbnail?["source"] as? String)
                
                let wikiPageURL = URL(string: "https://en.wikipedia.org/wiki/\(query)")!
                
                DispatchQueue.main.async {
                    self.fetchedLocation = PlaceData(
                        name: name,
                        coordinate: coordinate,
                        imageURL: imageSource,
                        wikiURL: wikiPageURL
                    )
                }
            }.resume()
        }
    }
}
 
