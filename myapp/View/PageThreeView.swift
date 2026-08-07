//
//  PageThreeView.swift
//  myapp
//

import SwiftUI 

struct PageThreeView: View {
    /// Event id to show. `nil` = no event selected.
    var searchTerm: UUID?

    private var event: EventModel? {
        guard let searchTerm else { return nil }
        return try? CalendarManager.shared.fetchEvent(with: searchTerm)
    }

    var body: some View {
        Form {
            if let event {
                Section("Event") {
                    LabeledContent("Title") {
                        Text(event.title)
                    }
                    if let fromCity = event.fromCity {
                        LabeledContent("From") {
                            Text(fromCity)
                        }
                    }
                    if let toCity = event.toCity {
                        LabeledContent("To") {
                            Text(toCity)
                        }
                    }
                    if let departureTerminal = event.departureTerminal {
                        LabeledContent("Departure terminal") {
                            Text(departureTerminal)
                        }
                    }
                    if let arrivalTerminal = event.arrivalTerminal {
                        LabeledContent("Arrival terminal") {
                            Text(arrivalTerminal)
                        }
                    }
                    if let airlineName = event.airlineName {
                        LabeledContent("Airline") {
                            Text(airlineName)
                        }
                    }
                    if let flightNumber = event.flightNumber {
                        LabeledContent("Flight number") {
                            Text(flightNumber)
                        }
                    }
                    LabeledContent("Calendar") {
                        Text(event.calendar.title)
                    }
                    LabeledContent("Starts") {
                        Text(event.startDate.formatted(date: .abbreviated, time: .shortened))
                    }
                    if let endDate = event.endDate {
                        LabeledContent("Ends") {
                            Text(endDate.formatted(date: .abbreviated, time: .shortened))
                        }
                    }
                    if event.isAllDay {
                        LabeledContent("All day") {
                            Text("Yes")
                        }
                    }
                    if let location = event.location, !location.isEmpty {
                        LabeledContent("Location") {
                            Text(location)
                        }
                    }
                    if let note = event.note, !note.isEmpty {
                        LabeledContent("Notes") {
                            Text(note)
                        }
                    }
                    if event.isFavorite {
                        LabeledContent("Favorite") {
                            Image(systemName: "star.fill")
                                .foregroundStyle(.yellow)
                        }
                    }
                }

                if !event.attendees.isEmpty {
                    Section("Attendees") {
                        ForEach(event.attendees, id: \.id) { attendee in
                            VStack(alignment: .leading, spacing: 2) {
                                Text(attendee.name)
                                if !attendee.email.isEmpty {
                                    Text(attendee.email)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                    }
                }
            } else if searchTerm != nil {
                Section {
                    ContentUnavailableView(
                        "Event not found",
                        systemImage: "calendar.badge.exclamationmark",
                        description: Text("No event matches this id.")
                    )
                }
            } else {
                Section {
                    ContentUnavailableView(
                        "No event selected",
                        systemImage: "calendar",
                        description: Text("Open an event from Siri or pick one from your calendar.")
                    )
                }
            }
        }
        .navigationTitle(event?.title ?? "Event")
    }
}

#Preview {
    NavigationStack {
        PageThreeView(searchTerm: nil)
    }
}
