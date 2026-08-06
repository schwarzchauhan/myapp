//
//  CalendarEntity.swift
//  myapp
//
//  Created by Harsh Chauhan on 06/08/26.
//


/*
See the LICENSE.txt file for this sample's licensing information.

Abstract:
Defines the calendar entity with enumerable and string-based queries.
*/
import AppIntents

@AppEntity(schema: .calendar.calendar)
struct CalendarEntity: IndexedEntity { // to dontate entities using spotlight index 

    // MARK: Static

    static let defaultQuery = CalendarEntityQuery()

    // MARK: Properties

    let id: UUID

    var title: String

    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(
            title: "\(title)",
            image: .init(systemName: "airplane.up.right")
        )
    }

    // MARK: Life cycle

    init(calendar: CalendarModel) {
        self.id = calendar.id
        self.title = calendar.title
    }

    // MARK: Query

    @MainActor
    struct CalendarEntityQuery: EnumerableEntityQuery, EntityStringQuery {
        
        nonisolated init() {
            
        }
        
        @Dependency
        var calendarManager: CalendarManager

        func allEntities() async throws -> [CalendarEntity] {
            try calendarManager.fetchCalendars().map(\.entity)
        }

        func entities(matching string: String) async throws -> [CalendarEntity] {
            try calendarManager.fetchCalendars()
                .filter { $0.title.localizedCaseInsensitiveContains(string) }
                .map(\.entity)
        }

        func entities(for identifiers: [CalendarEntity.ID]) async throws -> [CalendarEntity] {
            try calendarManager.fetchCalendars(with: identifiers).map(\.entity)
        }

        func suggestedEntities() async throws -> [CalendarEntity] {
            try calendarManager.fetchCalendars().map(\.entity)
        }
    }
}
