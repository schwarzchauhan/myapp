//
//  ItineraryService.swift
//  MyApp
//
//  Created by Harsh Chauhan on 26/07/26.
//

import Foundation

struct ItineraryService {
    static let showLatestBookingKey = "shouldShowLatestBooking"

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

    func setItineraries(query: String) {
        defaults.set(query, forKey: "lastItineraryQuery")
    }

    func saveFlightBooking(_ booking: FlightBooking) {
        guard let data = try? JSONEncoder().encode(booking) else { return }
        defaults.set(data, forKey: "flightBooking")
        // Also mirror to standard defaults so App Intents can read without App Group.
        UserDefaults.standard.set(data, forKey: "flightBooking")
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
