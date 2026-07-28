//
//  IntentFlightView.swift
//  myapp
//
//  Created by Harsh Chauhan on 26/07/26.
//

import SwiftUI

struct IntentFlightView: View {
    let itineraryText: String?
    let lob: Lob
    
    var body: some View {
        VStack {
            HStack {
                VStack {
                    Text(lob.text)
                        .font(.headline)
                    if let itineraryText = itineraryText {
                        Text(itineraryText)
                            .font(.subheadline)
                    }
                }
                lob.img
            }
        }
    }
}

enum Lob {
    case Flight
    case Hotel
    
    var img: Image {
        switch self {
            case .Flight:
            return Image(systemName: "airplane")
        case .Hotel:
            return Image(systemName: "house.fill")
        }
    }
    
    var text: String {
        switch self {
        case .Flight:
            return "Your upcoming Flight info"
        case .Hotel:
            return "Your upcoming Hotel reservation"
        }
    }
}
