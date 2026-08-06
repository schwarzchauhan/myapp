//
//  FlightBookingEntity.swift
//  myapp
//

import AppIntents
import Foundation

/// Indexed flight booking for Spotlight / Siri.
struct FlightBookingEntity: AppEntity, IndexedEntity {
    static var typeDisplayRepresentation = TypeDisplayRepresentation(name: "Flight Booking")
    static var defaultQuery = FlightBookingEntityQuery()

    var id: String

    @Property(title: "Name")
    var name: String

    @Property(title: "From City")
    var fromCity: String

    @Property(title: "To City")
    var toCity: String

    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(
            title: "\(fromCity) → \(toCity)",
            subtitle: "\(name)",
            image: .init(systemName: "airplane"),
            synonyms: [
                LocalizedStringResource(stringLiteral: fromCity),
                LocalizedStringResource(stringLiteral: toCity),
                LocalizedStringResource(stringLiteral: name),
                LocalizedStringResource(stringLiteral: "bookings"),
                LocalizedStringResource(stringLiteral: "booking"),
                LocalizedStringResource(stringLiteral: "flight"),
                LocalizedStringResource(stringLiteral: "flights")
            ]
        )
    }

    init(booking: FlightBooking) {
        let from = booking.fromCity.name
        let to = booking.toCity.name
        self.id = "\(booking.fromCity.code)-\(booking.toCity.code)"
        self.name = "Bookings \(from) \(to)"
        self.fromCity = from
        self.toCity = to
    }

    @MainActor
    static func allSaved() -> [FlightBookingEntity] {
        guard let booking = ItineraryService.shared.getFlightBooking() else { return [] }
        return [FlightBookingEntity(booking: booking)]
    }

    @MainActor
    static func matches(_ term: String) -> [FlightBookingEntity] {
        let lowered = term.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !lowered.isEmpty else { return allSaved() }

        // Ignore filler words Siri often appends ("booking", "flights", etc.)
        let stopWords: Set<String> = [
            "booking", "bookings", "flight", "flights",
            "my", "the", "a", "an", "from", "to", "in", "for"
        ]

        let tokens = lowered
            .split(whereSeparator: { !$0.isLetter && !$0.isNumber })
            .map(String.init)
            .filter { !stopWords.contains($0) && $0.count >= 2 }

        // Fall back to full string if everything was stop words
        let needles = tokens.isEmpty ? [lowered] : tokens

        return allSaved().filter { entity in
            let haystack = [
                entity.name,
                entity.fromCity,
                entity.toCity
            ].joined(separator: " ").lowercased()

            // Match if any meaningful token hits name / from / to
            return needles.contains { needle in
                haystack.contains(needle)
            }
        }
    }
}

nonisolated struct FlightBookingEntityQuery: EntityQuery {
    nonisolated init() {}

    @MainActor
    func entities(for identifiers: [FlightBookingEntity.ID]) async throws -> [FlightBookingEntity] {
        FlightBookingEntity.allSaved().filter { identifiers.contains($0.id) }
    }

    @MainActor
    func suggestedEntities() async throws -> [FlightBookingEntity] {
        FlightBookingEntity.allSaved()
    }
}

extension FlightBookingEntityQuery: EnumerableEntityQuery {
    @MainActor
    func allEntities() async throws -> [FlightBookingEntity] {
        FlightBookingEntity.allSaved()
    }
}

extension FlightBookingEntityQuery: EntityStringQuery {
    @MainActor
    func entities(matching string: String) async throws -> [FlightBookingEntity] {
        FlightBookingEntity.matches(string)
    }
}
