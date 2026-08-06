//
//  CalendarManager.swift
//  myapp
//
//  Created by Harsh Chauhan on 06/08/26.
//


/*
See the LICENSE.txt file for this sample's licensing information.

Abstract:
Manages CRUD operations for calendars, events, contacts, and attendees.
*/
import AppIntents
import CoreLocation
import CoreSpotlight
import GeoToolbox
import SwiftData

@MainActor @Observable  
final class CalendarManager {

    // MARK: Static

    static let shared = CalendarManager()

    // MARK: Properties

    let modelContainer: ModelContainer
    var modelContext: ModelContext
    nonisolated(unsafe) let searchableIndex: CSSearchableIndex

    // MARK: Life cycle

    init() {
        guard let container = try? ModelContainer(
            for: CalendarModel.self, EventModel.self, AttendeeModel.self, ContactModel.self
        ) else {
            fatalError("Failed to create the model container.")
        }
        self.modelContainer = container
        self.modelContext = container.mainContext
        self.searchableIndex = CSSearchableIndex(name: "com.myapp.index")
//        try? seedDataIfNeeded()
    }

    // MARK: Calendar operations

    /// Returns all calendars in alphabetical order.
    func fetchCalendars() throws -> [CalendarModel] {
        let descriptor = FetchDescriptor<CalendarModel>(
            sortBy: [SortDescriptor(\.title)]
        )
        return try modelContext.fetch(descriptor)
    }

    /// Returns calendars that match the identifiers.
    func fetchCalendars(with ids: [UUID]) throws -> [CalendarModel] {
        let descriptor = FetchDescriptor<CalendarModel>(
            predicate: #Predicate { ids.contains($0.id) }
        )
        return try modelContext.fetch(descriptor)
    }

    /// Creates a calendar and indexes it in Spotlight.
    func createCalendar(title: String, color: String) throws -> CalendarModel {
        let calendar = CalendarModel(title: title, color: color)
        modelContext.insert(calendar)
        try modelContext.save()

        // Index the calendar in Spotlight.
        Task {
            try? await searchableIndex.indexAppEntities([calendar.entity])
        }

        return calendar
    }

    /// Updates a calendar's title and color, then re-indexes it in Spotlight.
    func updateCalendar(_ calendar: CalendarModel, title: String, color: String) throws {
        calendar.title = title
        calendar.color = color
        try modelContext.save()

        // Update the calendar in Spotlight.
        Task {
            try? await searchableIndex.indexAppEntities([calendar.entity])
        }
    }

    /// Deletes a calendar and removes it from Spotlight.
    func deleteCalendar(_ calendar: CalendarModel) throws {
        modelContext.delete(calendar)
        try modelContext.save()

        // Remove the calendar from Spotlight.
        Task {
            try? await searchableIndex.deleteAppEntities(
                identifiedBy: [calendar.entity.id],
                ofType: CalendarEntity.self
            )
        }
    }

    // MARK: Event operations

    /// Returns events in chronological order, optionally filtering by calendar.
    func fetchEvents(for calendar: CalendarModel? = nil) throws -> [EventModel] {
        var descriptor = FetchDescriptor<EventModel>(
            sortBy: [SortDescriptor(\.startDate)]
        )
        if let calendar {
            let calendarID = calendar.id
            descriptor.predicate = #Predicate { $0.calendar.id == calendarID }
        }
        return try modelContext.fetch(descriptor)
    }

    /// Returns upcoming events starting from now.
    func fetchUpcomingEvents(limit: Int = 10) throws -> [EventModel] {
        let now = Date()
        var descriptor = FetchDescriptor<EventModel>(
            predicate: #Predicate { $0.startDate >= now },
            sortBy: [SortDescriptor(\.startDate)]
        )
        descriptor.fetchLimit = limit
        return try modelContext.fetch(descriptor)
    }

    /// Finds and returns a single event by its identifier.
    func fetchEvent(with id: UUID) throws -> EventModel? {
        let descriptor = FetchDescriptor<EventModel>(
            predicate: #Predicate { $0.id == id }
        )
        return try modelContext.fetch(descriptor).first
    }

    /// Returns events that match the identifiers.
    func fetchEvents(with ids: [UUID]) throws -> [EventModel] {
        let descriptor = FetchDescriptor<EventModel>(
            predicate: #Predicate { ids.contains($0.id) }
        )
        return try modelContext.fetch(descriptor)
    }

    /// Creates an event, indexes it in Spotlight, and donates the intent to the system.
    func createEvent(
        title: String,
        startDate: Date,
        endDate: Date,
        isAllDay: Bool = false,
        note: String? = nil,
        location: String? = nil,
        locationLatitude: Double? = nil,
        locationLongitude: Double? = nil,
        isFavorite: Bool = false,
        calendar: CalendarModel,
        recurrence: RecurrenceFrequency? = nil,
        recurrenceInterval: Int = 1,
        donateIntent: Bool = true
    ) throws -> EventModel {
        let event = EventModel(
            title: title,
            startDate: startDate,
            endDate: endDate,
            isAllDay: isAllDay,
            note: note,
            location: location,
            locationLatitude: locationLatitude,
            locationLongitude: locationLongitude,
            isFavorite: isFavorite,
            calendar: calendar,
            recurrence: recurrence,
            recurrenceInterval: recurrenceInterval
        )
        modelContext.insert(event)
        try modelContext.save()

        // Index the event in Spotlight.
        Task {
            try? await searchableIndex.indexAppEntities([event.entity])
        }

        // Donate the intent so Siri can learn from UI actions.
        if donateIntent {
            let intent = CreateEventIntent()
            intent.title = event.title
            intent.startDate = event.startDate
            intent.endDate = event.endDate
            intent.isAllDay = event.isAllDay
            intent.calendar = event.calendar.entity
            intent.attendees = event.attendees.map(\.entity)
            if let recurrence = event.recurrence {
                intent.recurrence = recurrence.toRecurrenceRule(interval: event.recurrenceInterval)
            }
            if let note = event.note {
                intent.note = AttributedString(note)
            }
            if let lat = event.locationLatitude, let lon = event.locationLongitude {
                let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
                intent.location = .place(PlaceDescriptor(
                    representations: [.address(event.location ?? ""), .coordinate(coordinate)],
                    commonName: event.location
                ))
            } else if let location = event.location {
                intent.location = .address(location)
            }
            Task {
                try? await IntentDonationManager.shared.donate(intent: intent)
            }
        }

        return event
    }

    /// Updates an event's properties, re-indexes it in Spotlight, and donates the intent.
    func updateEvent(
        _ event: EventModel,
        title: String? = nil,
        startDate: Date? = nil,
        endDate: Date? = nil,
        isAllDay: Bool? = nil,
        note: String? = nil,
        location: String? = nil,
        locationLatitude: Double?? = nil,
        locationLongitude: Double?? = nil,
        calendar: CalendarModel? = nil,
        attendees: [AttendeeModel]? = nil,
        recurrence: RecurrenceFrequency?? = nil,
        recurrenceInterval: Int? = nil,
        isFavorite: Bool? = nil,
        donateIntent: Bool = true
    ) throws {
        applyEventUpdates(
            event,
            title: title, startDate: startDate, endDate: endDate,
            isAllDay: isAllDay, note: note, location: location,
            locationLatitude: locationLatitude, locationLongitude: locationLongitude,
            calendar: calendar, recurrence: recurrence,
            recurrenceInterval: recurrenceInterval, isFavorite: isFavorite
        )

        if let attendees {
            reconcileAttendees(for: event, with: attendees)
        }

        try modelContext.save()

        Task {
            try? await searchableIndex.indexAppEntities([event.entity])
        }

        if donateIntent {
            donateUpdateIntent(for: event)
        }
    }

    /// Deletes an event, removes it from Spotlight, and donates the intent.
    func deleteEvent(_ event: EventModel, donateIntent: Bool = true) throws {
        modelContext.delete(event)
        try modelContext.save()

        // Remove the event from Spotlight.
        Task {
            try? await searchableIndex.deleteAppEntities(
                identifiedBy: [event.entity.id],
                ofType: EventEntity.self
            )
        }

        if donateIntent {
            let intent = DeleteEventIntent()
            intent.entity = event.entity
            Task {
                try? await IntentDonationManager.shared.donate(intent: intent)
            }
        }
    }

    /// Toggles an event's favorite status.
    func toggleFavorite(for event: EventModel) throws {
        event.isFavorite.toggle()
        try modelContext.save()
    }

}


extension CalendarManager {
    // MARK: Errors

    enum DataError: Error {
        case eventNotFound
        case calendarNotFound
    }
    
    /// Applies applicable parameter values to an event.
    func applyEventUpdates(
        _ event: EventModel,
        title: String?, startDate: Date?, endDate: Date?,
        isAllDay: Bool?, note: String?, location: String?,
        locationLatitude: Double??, locationLongitude: Double??,
        calendar: CalendarModel?, recurrence: RecurrenceFrequency??,
        recurrenceInterval: Int?, isFavorite: Bool?
    ) {
        event.title = title ?? event.title
        event.startDate = startDate ?? event.startDate
        event.endDate = endDate ?? event.endDate
        event.isAllDay = isAllDay ?? event.isAllDay
        event.locationLatitude = locationLatitude ?? event.locationLatitude
        event.locationLongitude = locationLongitude ?? event.locationLongitude
        event.calendar = calendar ?? event.calendar
        event.recurrence = recurrence ?? event.recurrence
        event.recurrenceInterval = recurrenceInterval ?? event.recurrenceInterval
        event.isFavorite = isFavorite ?? event.isFavorite

        if let note {
            event.note = note.isEmpty ? nil : note
        }

        if let location {
            event.location = location.isEmpty ? nil : location
        }

    }
    
    func reconcileAttendees(for event: EventModel, with attendees: [AttendeeModel]) {
        for existing in event.attendees where !attendees.contains(where: { $0.id == existing.id }) {
            modelContext.delete(existing)
        }
        for attendee in attendees where !event.attendees.contains(where: { $0.id == attendee.id }) {
            attendee.event = event
            modelContext.insert(attendee)
        }
        event.attendees = attendees
    }
    
    
    /// Returns attendees, optionally filtering by event.
    func fetchAttendees(for event: EventModel? = nil) throws -> [AttendeeModel] {
        if let event {
            return event.attendees
        }
        let descriptor = FetchDescriptor<AttendeeModel>()
        return try modelContext.fetch(descriptor)
    }

    /// Finds and returns a single attendee by its identifier.
    func fetchAttendee(with id: UUID) throws -> AttendeeModel? {
        let descriptor = FetchDescriptor<AttendeeModel>(
            predicate: #Predicate { $0.id == id }
        )
        return try modelContext.fetch(descriptor).first
    }
    
    /// Returns an existing contact with the email, or creates a new one.
    func resolveOrCreateContact(name: String, email: String) throws -> ContactModel {
        if let existing = try fetchContact(byEmail: email) {
            return existing
        }
        let contact = ContactModel(name: name, email: email)
        modelContext.insert(contact)
        try modelContext.save()
        return contact
    }
    
    /// Finds and returns a single contact by its identifier.
    func fetchContact(with id: UUID) throws -> ContactModel? {
        let descriptor = FetchDescriptor<ContactModel>(
            predicate: #Predicate { $0.id == id }
        )
        return try modelContext.fetch(descriptor).first
    }

    /// Finds and returns a contact by email address.
    func fetchContact(byEmail email: String) throws -> ContactModel? {
        let lowercased = email.lowercased()
        let descriptor = FetchDescriptor<ContactModel>(
            predicate: #Predicate { $0.email == lowercased }
        )
        return try modelContext.fetch(descriptor).first
    }
    
    /// Donates an update intent that mirrors the event's current state.
    func donateUpdateIntent(for event: EventModel) {
        let intent = UpdateEventIntent()
        intent.event = event.entity
        intent.title = event.title
        intent.startDate = event.startDate
        intent.endDate = event.endDate
        intent.isAllDay = event.isAllDay
        intent.calendar = event.calendar.entity
        intent.attendees = event.attendees.map(\.entity)
        intent.note = event.note
        if let recurrence = event.recurrence {
            intent.recurrence = recurrence.toRecurrenceRule(interval: event.recurrenceInterval)
        }
        if let lat = event.locationLatitude, let lon = event.locationLongitude {
            let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
            intent.location = .place(PlaceDescriptor(
                representations: [.address(event.location ?? ""), .coordinate(coordinate)],
                commonName: event.location
            ))
        } else if let location = event.location {
            intent.location = .address(location)
        }
        Task {
            try? await IntentDonationManager.shared.donate(intent: intent)
        }
    }
}
