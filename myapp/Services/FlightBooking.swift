//
//  FlightBooking.swift
//  myapp
//

import Foundation

struct FlightBooking: Codable, Hashable {
    let fromCity: City
    let toCity: City
    let departureDate: Date
    let departureTerminal: String
    let arrivalTerminal: String
    let airlineName: String
    let airlineCode: String
    let flightNumber: String
}
