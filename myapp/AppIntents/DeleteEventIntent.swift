//
//  DeleteEventIntent.swift
//  myapp
//
//  Created by Harsh Chauhan on 06/08/26.
//


/*
See the LICENSE.txt file for this sample's licensing information.

Abstract:
Implements the calendar domain's delete-events schema.
*/
import AppIntents

@AppIntent(schema: .calendar.deleteEvent)
struct DeleteEventIntent {

    // MARK: Properties

    var entity: EventEntity
    var span: EventSpan?

    @Dependency
    var calendarManager: CalendarManager

    // MARK: Methods

    @MainActor
    func perform() async throws -> some IntentResult {
        guard let event = try calendarManager.fetchEvent(with: entity.id) else {
            throw CalendarManager.DataError.eventNotFound
        }

        try calendarManager.deleteEvent(event, donateIntent: false)
        return .result()
    }
}
