//
//  ShowCityFlightIntent.swift
//  myapp
//

import AppIntents
import SwiftUI

/// Dedicated intent with a required city — works better for parameterized App Shortcuts.
struct ShowFromCityFlightIntent: AppIntent {
    static var title: LocalizedStringResource = "Show From City Flight"
    static var description = IntentDescription("Show flight details for a departure city.")
    static var openAppWhenRun: Bool = true

    @Parameter(title: "From City", requestValueDialog: "Which city are you flying from?")
    var fromCity: CityEntity

    static var parameterSummary: some ParameterSummary {
        Summary("Show \(\.$fromCity) flight")
    }

    func perform() async throws -> some IntentResult & ProvidesDialog & ShowsSnippetView {
        ItineraryService.shared.requestOpenLatestBooking()
        let text = ItineraryService.shared.getItinerary(lob: .Flight).0
            ?? "\(fromCity.name) flight"
        return .result(
            dialog: IntentDialog("Opening latest booking for \(fromCity.name)."),
            view: IntentFlightView(itineraryText: text, lob: .Flight)
        )
    }
}

struct ShowToCityFlightIntent: AppIntent {
    static var title: LocalizedStringResource = "Show To City Flight"
    static var description = IntentDescription("Show flight details for an arrival city.")
    static var openAppWhenRun: Bool = true

    @Parameter(title: "To City", requestValueDialog: "Which city are you flying to?")
    var toCity: CityEntity

    static var parameterSummary: some ParameterSummary {
        Summary("Show flight to \(\.$toCity)")
    }

    func perform() async throws -> some IntentResult & ProvidesDialog & ShowsSnippetView {
        ItineraryService.shared.requestOpenLatestBooking()
        let text = ItineraryService.shared.getItinerary(lob: .Flight).0
            ?? "Flight to \(toCity.name)"
        return .result(
            dialog: IntentDialog("Opening latest booking for \(toCity.name)."),
            view: IntentFlightView(itineraryText: text, lob: .Flight)
        )
    }
}


// updateAppShortcutParameters
