//
//  SafariView.swift
//  Vista Japan
//
//  Created by Daniel Liu  on 22/3/2026.
//

import Foundation
import SwiftUI
import MapKit
import Combine
import SafariServices

struct SafariView: UIViewControllerRepresentable {
    let url: URL
    func makeUIViewController(context: Context) -> SFSafariViewController {
        SFSafariViewController(url: url)
    }
    func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {}
}
