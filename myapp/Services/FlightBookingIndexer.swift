//
//  FlightBookingIndexer.swift
//  myapp
//

import AppIntents
import CoreSpotlight
import Foundation
import UniformTypeIdentifiers

//enum FlightBookingIndexer {
//    /// Indexes a booking so Siri / Spotlight can find and talk about it.
//    static func index(_ booking: FlightBooking) async {
//        let entity = FlightBookingEntity(booking: booking)
//
//        // Semantic index (IndexedEntity) — used by Apple Intelligence / Siri
//        do {
//            try await CSSearchableIndex.default().indexAppEntities([entity])
//            debugPrint("Indexed FlightBookingEntity:", entity.name)
//        } catch {
//            debugPrint("indexAppEntities failed:", error)
//        }
//
//        // Classic Spotlight item + associate entity for richer results
//        let attributes = CSSearchableItemAttributeSet(contentType: .text)
//        attributes.title = entity.name
//        attributes.displayName = "\(entity.fromCity) → \(entity.toCity)"
//        attributes.contentDescription =
//            "Flight booking in myapp from \(entity.fromCity) to \(entity.toCity)."
//        attributes.keywords = [
//            entity.fromCity,
//            entity.toCity,
//            entity.name,
//            "bookings",
//            "booking",
//            "flight",
//            "flights",
//            "myapp",
//            booking.fromCity.code,
//            booking.toCity.code
//        ]
//        attributes.associateAppEntity(entity)
//
//        let item = CSSearchableItem(
//            uniqueIdentifier: "flight-booking-\(entity.id)",
//            domainIdentifier: "com.myapp.bookings",
//            attributeSet: attributes
//        )
//
//        do {
//            try await CSSearchableIndex.default().indexSearchableItems([item])
//        } catch {
//            debugPrint("indexSearchableItems failed:", error)
//        }
//    }
//
//    static func reindexSavedBooking() async {
//        guard let booking = ItineraryService.shared.getFlightBooking() else { return }
//        await index(booking)
//    }
//}
