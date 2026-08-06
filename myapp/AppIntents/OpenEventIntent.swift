//
//  OpenEventIntent.swift
//  myapp
//
//  Created by Harsh Chauhan on 06/08/26.
//


/*
See the LICENSE.txt file for this sample's licensing information.

Abstract:
Opens a specific event in the app using the system open schema.
*/
import AppIntents

@AppIntent(schema: .system.open)
struct OpenEventIntent {

    static let title: LocalizedStringResource = "Open Event"

    @Parameter(title: "Event")
    var target: EventEntity

    @Dependency
    var calendarManager: CalendarManager

    @MainActor
    func perform() async throws -> some IntentResult {
        NavigationManager.shared.openEvent(target.id)
        return .result()
    }
}
