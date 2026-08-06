//
//  CalendarModel.swift
//  myapp
//
//  Created by Harsh Chauhan on 06/08/26.
//


/*
See the LICENSE.txt file for this sample's licensing information.

Abstract:
Defines the SwiftData model for a calendar.
*/
import Foundation
import SwiftData

@Model
final class CalendarModel {

    // MARK: Properties

    @Attribute(.unique)
    var id: UUID

    var title: String
    var color: String

    @Relationship(deleteRule: .cascade, inverse: \EventModel.calendar)
    var events: [EventModel]

    // MARK: Life cycle

    init(title: String, color: String) {
        self.id = UUID()
        self.title = title
        self.color = color
        self.events = []
    }
}

// MARK: App Intents bridge

extension CalendarModel {

    var entity: CalendarEntity {
        CalendarEntity(calendar: self)
    }
}
