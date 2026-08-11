//
//  CitySearchService.swift
//  myapp
//
//  Created by Harsh Chauhan on 26/07/26.
//

import Foundation

struct City: Identifiable, Codable, Hashable {
    var id: String { code }
    let name: String
    let code: String
    let country: String
    let score: Double?

    enum CodingKeys: String, CodingKey {
        case name, code, country, score
    }
}

struct CitySearchResponse: Decodable {
    let query: String
    let results: [City]
}

enum CitySearchError: LocalizedError {
    case invalidURL
    case badResponse
    case serverMessage(String)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid search URL"
        case .badResponse:
            return "Could not reach city search server"
        case .serverMessage(let message):
            return message
        }
    }
}

struct CitySearchService {
    static let shared = CitySearchService()

    /// Simulator / Mac: localhost. On a physical device, use your Mac's LAN IP.
    private let baseURL = "http://10.106.136.75:5050"

    private init() {}

    func search(query: String) async throws -> [City] {
        var components = URLComponents(string: "\(baseURL)/search")
        components?.queryItems = [URLQueryItem(name: "q", value: query)]

        guard let url = components?.url else {
            throw CitySearchError.invalidURL
        }

        let (data, response) = try await URLSession.shared.data(from: url)

        guard let http = response as? HTTPURLResponse else {
            throw CitySearchError.badResponse
        }

        if http.statusCode != 200 {
            if let body = try? JSONDecoder().decode([String: String].self, from: data),
               let error = body["error"] {
                throw CitySearchError.serverMessage(error)
            }
            throw CitySearchError.badResponse
        }

        let decoded = try JSONDecoder().decode(CitySearchResponse.self, from: data)
        return decoded.results
    }
}
