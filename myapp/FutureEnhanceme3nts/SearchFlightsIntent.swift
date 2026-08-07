//
//  SearchFlightsIntent.swift
//  myapp
//
//  Docs: https://developer.apple.com/documentation/appintents/appschema/systemintent/searchinapp
//  On this SDK the schema symbol is `.system.search` (ShowInAppSearchResultsIntent).
//

//import AppIntents
//import SwiftUI

/// In-app search: Siri re-runs the user's query inside myapp.
//@AppIntent(schema: .system.search)
//struct SearchFlightsIntent: ShowInAppSearchResultsIntent {
//    static var openAppWhenRun: Bool = true
//    static var searchScopes: [StringSearchScope] = [.general]
//
//    var criteria: StringSearchCriteria
//
//    @MainActor
//    func perform() async throws -> some IntentResult & ProvidesDialog & ShowsSnippetView {
//        let term = criteria.term.trimmingCharacters(in: .whitespacesAndNewlines)
//        debugPrint(term, "term")
////        ItineraryService.shared.setPendingFlightSearch(term)
////        ItineraryService.shared.requestOpenLatestBooking()
//
//        let matches = FlightBookingEntity.matches(term)
//        if let booking = matches.first {
//                let summary = "Your myapp booking: \(booking.fromCity) to \(booking.toCity)."
//            return .result(
//                dialog: IntentDialog("\(summary)"),
//                view: IntentFlightView(
//                    itineraryText: "\(booking.fromCity) → \(booking.toCity)",
//                    lob: .Flight
//                )
//            )
//        }
//
//        return .result(
//            dialog: IntentDialog("No flight booking in myapp matches “\(term)”."),
//            view: IntentFlightView(itineraryText: "No match for \(term)", lob: .Flight)
//        )
//    }
//}
