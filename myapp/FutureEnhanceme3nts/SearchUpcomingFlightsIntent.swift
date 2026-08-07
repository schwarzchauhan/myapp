//
//  SearchUpcomingFlightsIntent.swift
//  myapp
//
//  Created by Harsh Chauhan on 05/08/26.
//

//import AppIntents

// CUSTOM INTENT
//struct SearchUpcomingFlightsIntent: AppIntent {
//    static var title: LocalizedStringResource = "Search Flights"
//    static var description = IntentDescription("Searches for flight bookings by origin, destination, or date.")
//
//    // Siri AI automatically maps "Delhi" from the prompt to this variable
//    @Parameter(title: "Origin City")
//    var originCity: String?
//
//    @Parameter(title: "Destination City")
//    var destinationCity: String?
//
//    @Parameter(title: "Time Frame", default: .upcoming)
//    var timeFrame: FlightTimeFrame
//
//    @MainActor
//    func perform() async throws -> some IntentResult & ReturnsValue<[FlightBookingEntity]> & ShowsSnippetView {
//        let matches = FlightBookingEntity.matches(originCity)
//        if let booking = matches.first {
//            let summary = "Your myapp booking: \(booking.fromCity) to \(booking.toCity)."
//            return .result(
//                dialog: IntentDialog("\(summary)"),
//                view: IntentFlightView(
//                    itineraryText: "\(booking.fromCity) → \(booking.toCity)",
//                    lob: .Flight
//                )
//            )
//        }
//    }
//}
//
//enum FlightTimeFrame: String, AppEnum {
//    case upcoming
//    case past
//    case all
//
//    static var typeDisplayRepresentation = TypeDisplayRepresentation(name: "Time Frame")
//    static var caseDisplayRepresentations: [FlightTimeFrame: DisplayRepresentation] = [
//        .upcoming: "Upcoming",
//        .past: "Past",
//        .all: "All"
//    ]
//}
