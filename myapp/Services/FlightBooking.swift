//
//  FlightBooking.swift
//  myapp
//

import Foundation

struct FlightBooking: Codable, Hashable {
    let fromCity: City
    let toCity: City
    let departureDate: Date
    let landingDate: Date
    let boardingTime: Date
    let boardingGate: Int
    let departureTerminal: String
    let arrivalTerminal: String
    let airlineName: String
    let airlineCode: String
    let flightNumber: String
}
