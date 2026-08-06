//
//  EventSnippetView.swift
//  myapp
//
//  Created by Harsh Chauhan on 06/08/26.
//


/*
See the LICENSE.txt file for this sample's licensing information.

Abstract:
Renders a compact event summary card for Siri snippet results.
*/
import AppIntents
import GeoToolbox
import SwiftUI

struct EventSnippetView: View {

    let event: EventEntity

    var body: some View {
        HStack(spacing: 12) {
            // Accent bar with subtle gradient.
            RoundedRectangle(cornerRadius: 3)
                .fill(
                    LinearGradient(
                        colors: [.gray, .indigo, .purple, .blue, .teal, .gray],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: 5)

            VStack(alignment: .leading, spacing: 4) {
                Text(event.title)
                    .font(.body.weight(.semibold))
                    .foregroundStyle(.white)

                Text(formattedTime)
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.7))

                if let location = locationText {
                    HStack(spacing: 3) {
                        Image(systemName: "location.north.circle")
                        Text(location)
                    }
                    .font(.caption2)
                    .foregroundStyle(.white.opacity(0.6))
                }

                Text(event.calendar.title)
                    .font(.caption2)
                    .foregroundStyle(.white.opacity(0.5))
            }

            Spacer()

            if event.isFavorite {
                Image(systemName: "star.fill")
                    .font(.title3)
                    .foregroundStyle(event.isFavorite ? .yellow : .white.opacity(0.4))
            }
        }
        .padding(14)
        .background(Color(red: 0.05, green: 0.05, blue: 0.2))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    // MARK: Helpers

    private var locationText: String? {
        guard let location = event.location else { return nil }
        return switch location {
        case .address(let str): str
        case .place(let place): place.commonName ?? place.address
        }
    }

    private var formattedTime: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium

        let timeFormatter = DateFormatter()
        timeFormatter.timeStyle = .short

        if event.isAllDay {
            return "All Day · \(dateFormatter.string(from: event.startDate))"
        }
        let start = dateFormatter.string(from: event.startDate)
        let startTime = timeFormatter.string(from: event.startDate)
        let endTime = timeFormatter.string(from: event.endDate)
        return "\(start) · \(startTime) – \(endTime)"
    }
}

#Preview {
    EventSnippetView(
        event: EventEntity(
            event: EventModel(
                title: "Space Race Championships",
                startDate: Date(),
                endDate: Date(),
                isFavorite: true,
                calendar: CalendarModel(
                    title: "Zoom zoom",
                    color: "red"
                )
            )
        )
    )
}
