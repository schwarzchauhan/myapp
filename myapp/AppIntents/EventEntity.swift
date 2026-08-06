//
//  EventEntity.swift
//  myapp
//
//  Created by Harsh Chauhan on 06/08/26.
//


/*
See the LICENSE.txt file for this sample's licensing information.

Abstract:
Defines the event entity with full property mapping and Spotlight indexing.
*/
import AppIntents
import CoreLocation
import GeoToolbox

@AppEntity(schema: .calendar.event)
struct EventEntity: IndexedEntity, OwnershipProvidingEntity {

    // MARK: Static

    static let defaultQuery = EventEntityQuery()

    // MARK: Properties

    var id: UUID

    /// The calendar that contains this event.
    var calendar: CalendarEntity

    /// The display name of the event.
    var title: String

    /// The date and time the event begins.
    var startDate: Date

    /// The date and time the event ends.
    var endDate: Date

    /// A Boolean value that indicates whether the event spans a full day.
    var isAllDay: Bool

    /// The repetition rule for recurring events.
    var recurrence: Calendar.RecurrenceRule?

    /// Additional text about the event.
    var note: AttributedString?

    /// The travel time before the event begins.
    var travelTime: Duration?

    /// The physical or virtual location of the event.
    var location: EventLocation?

    /// A URL for joining the event remotely.
    var virtualLocation: URL?

    /// The confirmation status of the event.
    var status: EventEntityStatus?

    /// The scheduled alerts for the event.
    var alarms: [EventAlarm]

    /// The people who organized the event.
    var organizers: [IntentPerson]

    /// The people invited to the event.
    var attendees: [AttendeeEntity]

    /// A Boolean value that indicates whether the event is a favorite.
    var isFavorite: Bool

    var ownership: EntityOwnership {
        attendees.isEmpty ? .unknown : .shared
    }

    var displayRepresentation: DisplayRepresentation {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium

        var subtitle: String
        if isAllDay {
            subtitle = "All Day · \(dateFormatter.string(from: startDate))"
        } else {
            let timeFormatter = DateFormatter()
            timeFormatter.timeStyle = .short
            subtitle = "\(dateFormatter.string(from: startDate)) · \(timeFormatter.string(from: startDate)) – \(timeFormatter.string(from: endDate))"
        }

        return DisplayRepresentation(
            title: "\(title)",
            subtitle: "\(subtitle)",
            image: .init(systemName: "sparkles")
        )
    }

    // MARK: Life cycle

    init(event: EventModel) {
        self.id = event.id
        self.isFavorite = event.isFavorite
        self.calendar = event.calendar.entity
        self.title = event.title
        self.startDate = event.startDate
        // The calendar schema requires an end date, while a flight booking may
        // only have a departure time. Represent an unknown end as its start time.
        self.endDate = event.endDate ?? event.startDate
        self.isAllDay = event.isAllDay
        self.recurrence = event.recurrence?.toRecurrenceRule(interval: event.recurrenceInterval)
        self.note = event.note.map { AttributedString($0) }
        self.travelTime = nil
        self.location = {
            if let lat = event.locationLatitude, let lon = event.locationLongitude {
                let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
                return .place(PlaceDescriptor(
                    representations: [.address(event.location ?? ""), .coordinate(coordinate)],
                    commonName: event.location
                ))
            } else if let location = event.location {
                return .address(location)
            }
            return nil
        }()
        self.virtualLocation = nil
        self.status = .confirmed
        self.alarms = []
        self.organizers = []
        self.attendees = event.attendees.map(\.entity)
    }

    // MARK: Query

    @MainActor
    struct EventEntityQuery: EnumerableEntityQuery, EntityStringQuery {
        
        nonisolated init() {
            
        }
        
        @Dependency
        var calendarManager: CalendarManager

        func allEntities() async throws -> [EventEntity] {
            try calendarManager.fetchEvents().map(\.entity)
        }

        func entities(matching string: String) async throws -> [EventEntity] {
            try calendarManager.fetchEvents()
                .filter { $0.title.localizedCaseInsensitiveContains(string) }
                .map(\.entity)
        }

        func entities(for identifiers: [EventEntity.ID]) async throws -> [EventEntity] {
            try calendarManager.fetchEvents(with: identifiers).map(\.entity)
        }

        func suggestedEntities() async throws -> [EventEntity] {
            try calendarManager.fetchUpcomingEvents(limit: 5).map(\.entity)
        }
    }
}

// MARK: Enums

@AppEnum(schema: .calendar.eventStatus)
enum EventEntityStatus: String {
    case confirmed
    case tentative
    case cancelled

    static let caseDisplayRepresentations: [Self: DisplayRepresentation] = [
        .confirmed: "Confirmed",
        .tentative: "Tentative",
        .cancelled: "Cancelled"
    ]
}

@AppEnum(schema: .calendar.eventSpan)
enum EventSpan: String {
    case this
    case future
    case all

    static let caseDisplayRepresentations: [Self: DisplayRepresentation] = [
        .this: "This",
        .future: "Future",
        .all: "All"
    ]
}

// MARK: Union value types

@UnionValue
enum EventLocation {
    case place(PlaceDescriptor)
    case address(String)
}

@UnionValue
enum EventAlarm {
    case duration(Duration)
    case date(Date)
}
