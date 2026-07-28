//
//  CityEntity.swift
//  myapp
//

import AppIntents
import Foundation

struct CityEntity: AppEntity {
    static var typeDisplayRepresentation = TypeDisplayRepresentation(name: "City")
    static var defaultQuery = CityEntityQuery()

    var id: String { code }

    @Property(title: "Name")
    var name: String

    @Property(title: "Code")
    var code: String

    @Property(title: "Country")
    var country: String

    init(name: String, code: String, country: String) {
        self.name = name
        self.code = code
        self.country = country
    }

    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(
            title: "\(name)",
            subtitle: "\(code) · \(country)",
            synonyms: [
                "\(code)",
                "\(name) \(code)",
                "\(name) airport"
            ]
        )
    }

    func asCity() -> City {
        City(name: name, code: code, country: country, score: nil)
    }

    static func from(_ city: City) -> CityEntity {
        CityEntity(name: city.name, code: city.code, country: city.country)
    }

    static let allCities: [CityEntity] = [
        .init(name: "Bengaluru", code: "BLR", country: "India"),
        .init(name: "Hubballi", code: "HBX", country: "India"),
        .init(name: "Mumbai", code: "BOM", country: "India"),
        .init(name: "Delhi", code: "DEL", country: "India"),
        .init(name: "Chennai", code: "MAA", country: "India"),
        .init(name: "Hyderabad", code: "HYD", country: "India"),
        .init(name: "Kolkata", code: "CCU", country: "India"),
        .init(name: "Pune", code: "PNQ", country: "India"),
        .init(name: "Ahmedabad", code: "AMD", country: "India"),
        .init(name: "Goa", code: "GOI", country: "India"),
        .init(name: "Jaipur", code: "JAI", country: "India"),
        .init(name: "Kochi", code: "COK", country: "India"),
        .init(name: "Thiruvananthapuram", code: "TRV", country: "India"),
        .init(name: "Coimbatore", code: "CJB", country: "India"),
        .init(name: "Mangaluru", code: "IXE", country: "India"),
        .init(name: "Mysuru", code: "MYQ", country: "India"),
        .init(name: "Visakhapatnam", code: "VTZ", country: "India"),
        .init(name: "Lucknow", code: "LKO", country: "India"),
        .init(name: "Chandigarh", code: "IXC", country: "India"),
        .init(name: "Indore", code: "IDR", country: "India"),
        .init(name: "Bhopal", code: "BHO", country: "India"),
        .init(name: "Nagpur", code: "NAG", country: "India"),
        .init(name: "Patna", code: "PAT", country: "India"),
        .init(name: "Guwahati", code: "GAU", country: "India"),
        .init(name: "Varanasi", code: "VNS", country: "India"),
        .init(name: "Srinagar", code: "SXR", country: "India"),
        .init(name: "Amritsar", code: "ATQ", country: "India"),
        .init(name: "Udaipur", code: "UDR", country: "India"),
        .init(name: "Madurai", code: "IXM", country: "India"),
        .init(name: "Tiruchirappalli", code: "TRZ", country: "India"),
        .init(name: "New York", code: "JFK", country: "USA"),
        .init(name: "Los Angeles", code: "LAX", country: "USA"),
        .init(name: "London", code: "LHR", country: "UK"),
        .init(name: "Dubai", code: "DXB", country: "UAE"),
        .init(name: "Singapore", code: "SIN", country: "Singapore"),
        .init(name: "Bangkok", code: "BKK", country: "Thailand"),
        .init(name: "Tokyo", code: "NRT", country: "Japan"),
        .init(name: "Paris", code: "CDG", country: "France"),
        .init(name: "Sydney", code: "SYD", country: "Australia"),
        .init(name: "Hong Kong", code: "HKG", country: "Hong Kong")
    ]
}

struct CityEntityQuery: EntityQuery {
    func entities(for identifiers: [CityEntity.ID]) async throws -> [CityEntity] {
        CityEntity.allCities.filter { identifiers.contains($0.id) }
    }

    func suggestedEntities() async throws -> [CityEntity] {
        // Include enough cities so Spotlight/Siri can resolve common names like Sydney.
        CityEntity.allCities
    }
}

extension CityEntityQuery: EnumerableEntityQuery {
    func allEntities() async throws -> [CityEntity] {
        CityEntity.allCities
    }
}

extension CityEntityQuery: EntityStringQuery {
    func entities(matching string: String) async throws -> [CityEntity] {
        let query = string.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else { return [] }

        // Local-first: App Shortcuts / Siri must not depend on the Python server.
        let lowered = query.lowercased()
        let local = CityEntity.allCities.filter { city in
            city.name.lowercased().contains(lowered)
                || city.code.lowercased().contains(lowered)
                || city.country.lowercased().contains(lowered)
        }

        if !local.isEmpty {
            return Array(local.prefix(5))
        }

        if let remote = try? await CitySearchService.shared.search(query: query), !remote.isEmpty {
            return remote.map(CityEntity.from)
        }

        return []
    }
}
