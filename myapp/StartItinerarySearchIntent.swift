//
//  StartItinerarySearchIntent.swift
//  MyApp
//
//  Created by Harsh Chauhan on 26/07/26.
//

import AppIntents
import SwiftUI

struct StartItinerarySearchIntent: AppIntent {
    static var title: LocalizedStringResource = "Start Itinerary Search"
    static var description = IntentDescription("Show a flight or hotel itinerary from myapp.")
    static var openAppWhenRun: Bool = true

    @Parameter(title: "Type", default: .flight)
    var lob: LobAppEnum

    @Parameter(title: "From City")
    var fromCity: CityEntity?

    @Parameter(title: "To City")
    var toCity: CityEntity?

    static var parameterSummary: some ParameterSummary {
        Switch(\.$lob) {
            Case(.flight) {
                Summary("Get \(\.$lob) from \(\.$fromCity) to \(\.$toCity)")
            }
            Case(.hotel) {
                Summary("Get \(\.$lob) details")
            }
            DefaultCase {
                Summary("Get \(\.$lob) booking")
            }
        }
    }

    func perform() async throws -> some IntentResult & ProvidesDialog & ShowsSnippetView {
        ItineraryService.shared.requestOpenLatestBooking()
        let domainLob = lob.asLob
        let itineraryText = resolveItineraryText(for: domainLob)
        let dialog = IntentDialog("Opening latest booking for “\(itineraryText ?? "no booking")”.")

        return .result(
            dialog: dialog,
            view: IntentFlightView(itineraryText: itineraryText, lob: domainLob)
        )
    }

    private func resolveItineraryText(for domainLob: Lob) -> String? {
        if domainLob == .Flight {
            if let fromCity, let toCity {
                return "\(fromCity.name) => \(toCity.name)"
            }
            if let fromCity {
                return "\(fromCity.name) flight"
            }
            if let toCity {
                return "Flight to \(toCity.name)"
            }
        }

        return ItineraryService.shared.getItinerary(lob: domainLob).0
    }
}
