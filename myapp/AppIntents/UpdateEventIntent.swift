//
//  UpdateEventIntent.swift
//  myapp
//
//  Created by Harsh Chauhan on 06/08/26.
//


/*
See the LICENSE.txt file for this sample's licensing information.

Abstract:
Implements the calendar domain's update-event schema.
*/
import AppIntents
import GeoToolbox
import SwiftUI

@AppIntent(schema: .calendar.updateEvent)
struct UpdateEventIntent {

    // MARK: Properties

    var event: EventEntity
    var title: String?
    var attendees: [AttendeeEntity]?
    var startDate: Date?
    var endDate: Date?
    var isAllDay: Bool?
    var calendar: CalendarEntity?
    var recurrence: Calendar.RecurrenceRule?
    var note: String?
    var location: EventLocation?
    var span: EventSpan?

    @Dependency
    var calendarManager: CalendarManager

    // MARK: Perform

    @MainActor
    func perform() async throws -> some ReturnsValue<EventEntity> & ShowsSnippetView {
        guard let targetEvent = try calendarManager.fetchEvent(with: event.id) else {
            throw CalendarManager.DataError.eventNotFound
        }

        let targetCalendar = try resolveCalendar()
        let resolvedLocation = resolveLocation()
        let targetAttendees = try resolveAttendees()
        let resolvedRecurrence = resolveRecurrence()
        let resolvedEndDate = resolveEndDate(for: targetEvent)

        try calendarManager.updateEvent(
            targetEvent,
            title: title,
            startDate: startDate,
            endDate: resolvedEndDate,
            isAllDay: isAllDay,
            note: note,
            location: resolvedLocation.string,
            locationLatitude: resolvedLocation.latitude,
            locationLongitude: resolvedLocation.longitude,
            calendar: targetCalendar,
            attendees: targetAttendees,
            recurrence: resolvedRecurrence.frequency,
            recurrenceInterval: resolvedRecurrence.interval,
            donateIntent: false
        )

        return .result(value: targetEvent.entity) {
            EventSnippetView(event: targetEvent.entity)
        }
    }

    // MARK: - Resolution helpers

    @MainActor
    private func resolveCalendar() throws -> CalendarModel? {
        guard let calendar else { return nil }
        return try calendarManager.fetchCalendars().first(where: { $0.id == calendar.id })
    }

    private func resolveLocation() -> (string: String?, latitude: Double??, longitude: Double??) {
        switch $location.valueState {
        case .set(let loc):
            if let loc {
                if case .address(let str) = loc {
                    return (str.capitalized, .some(nil), .some(nil))
                } else if case .place(let place) = loc {
                    let name = place.commonName ?? place.address
                    if let coordinate = place.coordinate {
                        return (name, .some(coordinate.latitude), .some(coordinate.longitude))
                    }
                    return (name, .some(nil), .some(nil))
                }
                return (nil, nil, nil)
            } else {
                return ("", .some(nil), .some(nil))
            }
        case .unset:
            return (nil, nil, nil)
        @unknown default:
            return (nil, nil, nil)
        }
    }

    @MainActor
    private func resolveAttendees() throws -> [AttendeeModel]? {
        guard let attendees else { return nil }
        return try attendees.map { entity in
            if let existing = try calendarManager.fetchAttendee(with: entity.id) {
                return existing
            }
            let contact = try calendarManager.resolveOrCreateContact(
                name: entity.person.resolvedDisplayName,
                email: entity.person.resolvedEmailAddress ?? ""
            )
            return AttendeeModel(contact: contact)
        }
    }
    

    private func resolveRecurrence() -> (frequency: RecurrenceFrequency??, interval: Int?) {
        switch $recurrence.valueState {
        case .set(let rule):
            if let rule {
                return (.some(RecurrenceFrequency.from(rule)), rule.interval)
            }
            return (.some(nil), nil)
        case .unset:
            return (nil, nil)
        @unknown default:
            return (nil, nil)
        }
    }

    private func resolveEndDate(for targetEvent: EventModel) -> Date? {
        if let startDate, endDate == nil {
            let duration = targetEvent.endDate.timeIntervalSince(targetEvent.startDate)
            return startDate.addingTimeInterval(duration)
        }
        return endDate
    }
}

extension IntentPerson {
    var resolvedDisplayName: String {
        switch name {
        case .displayName(let value):
            return value
        case .components(let components):
            return PersonNameComponentsFormatter.localizedString(
                from: components,
                style: .default
            )
        case .unknown:
            // Fall back to email / phone if name is unknown
            return resolvedEmailAddress
                ?? resolvedPhoneNumber
                ?? "Unknown"
        }
    }

    var resolvedEmailAddress: String? {
        if case .emailAddress(let email) = handle?.value {
            return email
        }
        for alias in aliases {
            if case .emailAddress(let email) = alias.value {
                return email
            }
        }
        return nil
    }

    var resolvedPhoneNumber: String? {
        if case .phoneNumber(let phone) = handle?.value {
            return phone
        }
        return nil
    }
}
