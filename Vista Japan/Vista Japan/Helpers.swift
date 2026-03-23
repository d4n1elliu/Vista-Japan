//
//  Helpers.swift
//  Vista Japan
//
//  Created by Daniel Liu  on 22/3/2026.
//

import SwiftUI

// Circular image component for icons and placeholders
struct CircleImage: View {
    var body: some View {
        Image(systemName: "mappin.circle.fill")
            .resizable()
            .foregroundColor(.blue)
            .background(Color.white)
            .clipShape(Circle())
    }
}
