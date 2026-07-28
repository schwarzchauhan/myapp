//
//  ItineraryAppShortcut.swift
//  MyApp
//
//  Created by Harsh Chauhan on 26/07/26.
//

import AppIntents

struct ItineraryShortcut: AppShortcutsProvider {
    static var shortcutTileColor: ShortcutTileColor = .blue

    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: StartItinerarySearchIntent(),
            phrases: [
                "Get \(\.$lob) bookings from \(.applicationName)",
                "Flight Update from \(.applicationName)",
                "Hotel Details from \(.applicationName)",
                "Get Bookings from \(.applicationName)"
            ],
            shortTitle: "Get Booking",
            systemImageName: "airplane"
        )

        // Required (non-optional) city params resolve more reliably than optional ones.
        AppShortcut(
            intent: ShowFromCityFlightIntent(),
            phrases: [
                "Show \(\.$fromCity) flight in \(.applicationName)",
                "\(\.$fromCity) flight in \(.applicationName)"
            ],
            shortTitle: "From City Flight",
            systemImageName: "airplane.departure"
        )

        AppShortcut(
            intent: ShowToCityFlightIntent(),
            phrases: [
                "Show flight to \(\.$toCity) in \(.applicationName)",
                "Flight to \(\.$toCity) in \(.applicationName)"
            ],
            shortTitle: "To City Flight",
            systemImageName: "airplane.arrival"
        )
    }
}
