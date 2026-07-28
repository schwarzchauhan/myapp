//
//  PageThreeView.swift
//  myapp
//

import SwiftUI

struct PageThreeView: View {
    private var booking: FlightBooking? {
        ItineraryService.shared.getFlightBooking()
    }

    var body: some View {
        Form {
            if let booking {
                Section("Latest booking") {
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
        PageThreeView()
    }
}
