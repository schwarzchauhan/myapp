//
//  ItineraryViewModel.swift
//  MyApp
//
//  Created by Harsh Chauhan on 26/07/26.
//

import Foundation
import SwiftUI
import Combine

class ItineraryViewModel: ObservableObject {
    @Published var lastQuery: String?
    
    init(lastQuery: String? = nil) {
        self.lastQuery = lastQuery
    }
    func setItineraries() {
        ItineraryService.shared.setItineraries(query: "Indigo from BLR to Hubbali HBX")
    }
}
