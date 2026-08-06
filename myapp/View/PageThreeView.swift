//
//  PageThreeView.swift
//  myapp
//

import SwiftUI

struct PageThreeView: View {
    var searchTerm: String? = nil

    private var booking: FlightBooking? {
        ItineraryService.shared.getFlightBooking()
    }

    private var matchesSearch: Bool {
        guard let booking else { 
            debugPrint("No booking found")
            return false
         }
        guard let searchTerm, !searchTerm.isEmpty else { return true }
        let q = searchTerm.lowercased()
        let name = "Bookings \(booking.fromCity.name) \(booking.toCity.name)".lowercased()
        return name.contains(q)
            || booking.fromCity.name.lowercased().contains(q)
            || booking.toCity.name.lowercased().contains(q)
            || booking.fromCity.code.lowercased().contains(q)
            || booking.toCity.code.lowercased().contains(q)
    }

    var body: some View {
        Form {
            if let searchTerm, !searchTerm.isEmpty {
                Section("Search") {
                    Text("Results for “\(searchTerm)”")
                        .foregroundStyle(.secondary)
                }
            }

            if let booking, matchesSearch {
                Section("Latest booking") {
                    LabeledContent("Name") {
                        Text("Bookings \(booking.fromCity.name) \(booking.toCity.name)")
                    }
                    LabeledContent("From") {
                        Text("\(booking.fromCity.name) (\(booking.fromCity.code))")
                    }
                    LabeledContent("To") {
                        Text("\(booking.toCity.name) (\(booking.toCity.code))")
                    }
                    LabeledContent("Route") {
                        Text("\(booking.fromCity.name) => \(booking.toCity.name)")
                            .fontWeight(.semibold)
                    }
                }
            } else if booking != nil {
                Section {
                    ContentUnavailableView(
                        "No match",
                        systemImage: "magnifyingglass",
                        description: Text("No booking matched “\(searchTerm ?? "")”.")
                    )
                }
            } else {
                Section {
                    ContentUnavailableView(
                        "No booking yet",
                        systemImage: "airplane",
                        description: Text("Book a flight on the Flight screen first.")
                    )
                }
            }
        }
        .navigationTitle("My Booking")
    }
}

#Preview {
    NavigationStack {
        PageThreeView(searchTerm: "Indore")
    }
}
