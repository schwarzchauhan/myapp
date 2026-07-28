//
//  LobAppEnum.swift
//  myapp
//

import AppIntents

enum LobAppEnum: String, AppEnum {
    case flight
    case hotel

    static var typeDisplayRepresentation = TypeDisplayRepresentation(name: "Booking Type")

    static var caseDisplayRepresentations: [LobAppEnum: DisplayRepresentation] = [
        .flight: DisplayRepresentation(title: "Flight", image: .init(systemName: "airplane")),
        .hotel: DisplayRepresentation(title: "Hotel", image: .init(systemName: "house.fill"))
    ]

    var asLob: Lob {
        switch self {
        case .flight: return .Flight
        case .hotel: return .Hotel
        }
    }
}
