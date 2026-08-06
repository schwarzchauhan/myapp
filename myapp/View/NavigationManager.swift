//
//  NavigationManager.swift
//  myapp
//
//  Created by Harsh Chauhan on 06/08/26.
//


/*
See the LICENSE.txt file for this sample's licensing information.

Abstract:
Tracks navigation state for programmatic sheet presentations and detail navigation.
*/
import SwiftUI

@MainActor @Observable
final class NavigationManager {

    // MARK: Static

    static let shared = NavigationManager()


    var selectedEventID: UUID?

    /// Navigates to the detail view for an event.
    func openEvent(_ eventID: UUID) {
        selectedEventID = eventID
    }
}
