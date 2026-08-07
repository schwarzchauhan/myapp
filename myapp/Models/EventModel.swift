//
//  EventModel.swift
//  myapp
//
//  Created by Harsh Chauhan on 06/08/26.
//


/*
See the LICENSE.txt file for this sample's licensing information.

Abstract:
Defines the SwiftData model for a calendar event.
*/
import Foundation
import SwiftData

@Model
final class EventModel {

    // MARK: Properties

    @Attribute(.unique)
    var id: UUID

    var title: String
    var startDate: Date
    var endDate: Date?
    var fromCity: String?
    var toCity: String?
    var departureTerminal: String?
    var arrivalTerminal: String?
    var airlineName: String?
    var airlineCode: String?
    var flightNumber: String?
    var bookingID: String?
    var boardingTime: Date?
    var boardingGate: Int?
    var isAllDay: Bool
    var note: String?
    var location: String?
    var locationLatitude: Double?
    var locationLongitude: Double?
    var isFavorite: Bool

    /// The recurrence frequency for repeating events.
    var recurrenceFrequency: String?

    /// The number of frequency periods between occurrences.
    var recurrenceInterval: Int

    @Relationship(deleteRule: .nullify)
    var calendar: CalendarModel

    @Relationship(deleteRule: .cascade, inverse: \AttendeeModel.event)
    var attendees: [AttendeeModel]

    /// A Boolean value that indicates whether the event repeats.
    var isRecurring: Bool {
        recurrenceFrequency != nil
    }

    /// The recurrence frequency as an enumeration case.
    var recurrence: RecurrenceFrequency? {
        get { recurrenceFrequency.flatMap { RecurrenceFrequency(rawValue: $0) } }
        set { recurrenceFrequency = newValue?.rawValue }
    }

    // MARK: Life cycle

    init(
        title: String,
        startDate: Date,
        endDate: Date? = nil,
        fromCity: String? = nil,
        toCity: String? = nil,
        departureTerminal: String? = nil,
        arrivalTerminal: String? = nil,
        airlineName: String? = nil,
        airlineCode: String? = nil,
        flightNumber: String? = nil,
        bookingID: String? = nil,
        boardingTime: Date? = nil,
        boardingGate: Int? = nil,
        isAllDay: Bool = false,
        note: String? = nil,
        location: String? = nil,
        locationLatitude: Double? = nil,
        locationLongitude: Double? = nil,
        isFavorite: Bool = false,
        calendar: CalendarModel,
        recurrence: RecurrenceFrequency? = nil,
        recurrenceInterval: Int = 1
    ) {
        self.id = UUID()
        self.title = title
        self.startDate = startDate
        self.endDate = endDate
        self.fromCity = fromCity
        self.toCity = toCity
        self.departureTerminal = departureTerminal
        self.arrivalTerminal = arrivalTerminal
        self.airlineName = airlineName
        self.airlineCode = airlineCode
        self.flightNumber = flightNumber
        self.bookingID = bookingID
        self.boardingTime = boardingTime
        self.boardingGate = boardingGate
        self.isAllDay = isAllDay
        self.note = note
        self.location = location
        self.locationLatitude = locationLatitude
        self.locationLongitude = locationLongitude
        self.isFavorite = isFavorite
        self.calendar = calendar
        self.attendees = []
        self.recurrenceFrequency = recurrence?.rawValue
        self.recurrenceInterval = recurrenceInterval
    }
}

// MARK: Recurrence

enum RecurrenceFrequency: String, CaseIterable, Identifiable {
    case daily
    case weekly
    case monthly
    case yearly

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .daily: "Daily"
        case .weekly: "Weekly"
        case .monthly: "Monthly"
        case .yearly: "Yearly"
        }
    }

    /// Creates a recurrence rule with an interval.
    func toRecurrenceRule(interval: Int = 1) -> Calendar.RecurrenceRule {
        let frequency: Calendar.RecurrenceRule.Frequency = switch self {
        case .daily: .daily
        case .weekly: .weekly
        case .monthly: .monthly
        case .yearly: .yearly
        }
        return Calendar.RecurrenceRule(calendar: .current, frequency: frequency, interval: interval)
    }

    /// Creates a frequency value from a Calendar.RecurrenceRule.
    static func from(_ rule: Calendar.RecurrenceRule) -> RecurrenceFrequency? {
        switch rule.frequency {
        case .daily: .daily
        case .weekly: .weekly
        case .monthly: .monthly
        case .yearly: .yearly
        default: nil
        }
    }
}

// MARK: App Intents bridge

extension EventModel {

    var entity: EventEntity {
        EventEntity(event: self)
    }
}

// MARK: Date helpers

extension Date {
    static var nextWholeHour: Date {
        let calendar = Calendar.current
        let now = Date()
        let components = calendar.dateComponents([.year, .month, .day, .hour], from: now)
        guard let wholeHour = calendar.date(from: components) else {
            fatalError("Failed to construct a date from the current hour components.")
        }
        return wholeHour.addingTimeInterval(3600)
    }
}
