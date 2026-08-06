//
//  ItineraryService.swift
//  MyApp
//
//  Created by Harsh Chauhan on 26/07/26.
//

import Foundation

struct ItineraryService {
    static let showLatestBookingKey = "shouldShowLatestBooking"
    static let pendingFlightSearchKey = "pendingFlightSearch"

    private let defaults: UserDefaults
    static let shared = ItineraryService()

    private init() {
        defaults = UserDefaults(suiteName: "group.com.yourcompany.MyApp") ?? .standard
    }

    func requestOpenLatestBooking() {
        defaults.set(true, forKey: Self.showLatestBookingKey)
        UserDefaults.standard.set(true, forKey: Self.showLatestBookingKey)
    }

    func consumeOpenLatestBookingRequest() -> Bool {
        let shouldOpen = defaults.bool(forKey: Self.showLatestBookingKey)
            || UserDefaults.standard.bool(forKey: Self.showLatestBookingKey)
        guard shouldOpen else { return false }
        defaults.set(false, forKey: Self.showLatestBookingKey)
        UserDefaults.standard.set(false, forKey: Self.showLatestBookingKey)
        return true
    }

    func setPendingFlightSearch(_ term: String) {
        defaults.set(term, forKey: Self.pendingFlightSearchKey)
        UserDefaults.standard.set(term, forKey: Self.pendingFlightSearchKey)
    }

    func consumePendingFlightSearch() -> String? {
        let term = defaults.string(forKey: Self.pendingFlightSearchKey)
            ?? UserDefaults.standard.string(forKey: Self.pendingFlightSearchKey)
        guard let term, !term.isEmpty else { return nil }
        defaults.removeObject(forKey: Self.pendingFlightSearchKey)
        UserDefaults.standard.removeObject(forKey: Self.pendingFlightSearchKey)
        return term
    }

    func setItineraries(query: String) {
        defaults.set(query, forKey: "lastItineraryQuery")
    }

    @MainActor
    func saveFlightBooking(_ booking: FlightBooking) {
        guard let data = try? JSONEncoder().encode(booking) else { return }
        defaults.set(data, forKey: "flightBooking")
        UserDefaults.standard.set(data, forKey: "flightBooking")

        Task {
            debugPrint(booking, "booking")
//            await FlightBookingIndexer.index(booking)
        }
        
        let calendarManager = CalendarManager.shared
        _ = try? calendarManager.createCalendar(title: "Upcoming Flights", color: "Blue")
        
        let calendarModels = try? calendarManager.fetchCalendars()
        
        if let calendarModel = calendarModels?.first {
            _ = try? calendarManager.createEvent(
                title: "Upcoming Flight \(booking.fromCity.name) → \(booking.toCity.name)",
                startDate: Date(),
                endDate: Date(),
                calendar: calendarModel
            )
        }
    }

    func getFlightBooking() -> FlightBooking? {
        let data = defaults.data(forKey: "flightBooking")
            ?? UserDefaults.standard.data(forKey: "flightBooking")
        guard let data else { return nil }
        return try? JSONDecoder().decode(FlightBooking.self, from: data)
    }

    func getItinerary(lob: Lob) -> (String?, Lob) {
        switch lob {
        case .Flight:
            guard let booking = getFlightBooking() else {
                return (nil, lob)
            }
            let string = "\(booking.fromCity.name) => \(booking.toCity.name)"
            debugPrint(string)
            return (string, lob)

        case .Hotel:
            let string = defaults.string(forKey: "lastItineraryQuery")
                ?? UserDefaults.standard.string(forKey: "lastItineraryQuery")
            debugPrint(string)
            return (string, lob)
        }
    }
}
