//
//  CreateEventIntent.swift
//  myapp
//
//  Created by Harsh Chauhan on 06/08/26.
//


/*
See the LICENSE.txt file for this sample's licensing information.

Abstract:
Implements the calendar domain's create-event schema.
*/

//import AppIntents
//import GeoToolbox
//
//@AppIntent(schema: .calendar.createEvent)
//struct CreateEventIntent {
//
//    // MARK: Properties
//
//    var title: String
//    var startDate: Date
//    var endDate: Date?
//    var location: EventLocation?
//    var calendar: CalendarEntity
//    var isAllDay: Bool
//    var recurrence: Calendar.RecurrenceRule?
//    var attendees: [AttendeeEntity]
//    var note: AttributedString?
//
//    @Dependency
//    var calendarManager: CalendarManager
//
//    // MARK: Methods
//
//    @MainActor
//    func perform() async throws -> some ReturnsValue<EventEntity> {
//        // Resolve the calendar, falling back to the first available one.
//        let calendars = try calendarManager.fetchCalendars()
//        guard let targetCalendar = calendars.first(where: { $0.id == calendar.id }) ?? calendars.first else {
//            throw CalendarManager.DataError.calendarNotFound
//        }
//
//        // Extract the location string and coordinate.
//        var locationString: String?
//        var locationLatitude: Double?
//        var locationLongitude: Double?
//        if case .address(let str) = location {
//            locationString = str
//        } else if case .place(let place) = location {
//            locationString = place.commonName ?? place.address
//            if let coordinate = place.coordinate {
//                locationLatitude = coordinate.latitude
//                locationLongitude = coordinate.longitude
//            }
//        }
//
//        // Resolve recurrence when available.
//        let frequency = recurrence.flatMap { RecurrenceFrequency.from($0) }
//        let interval = recurrence?.interval ?? 1
//
//        let event = try calendarManager.createEvent(
//            title: title.capitalized,
//            startDate: startDate,
//            endDate: endDate ?? startDate.addingTimeInterval(3600),
//            isAllDay: isAllDay,
//            note: note.map { String($0.characters) },
//            location: locationString,
//            locationLatitude: locationLatitude,
//            locationLongitude: locationLongitude,
//            calendar: targetCalendar,
//            recurrence: frequency,
//            recurrenceInterval: interval,
//            donateIntent: false
//        )
//
//        return .result(value: event.entity)
//    }
//}
