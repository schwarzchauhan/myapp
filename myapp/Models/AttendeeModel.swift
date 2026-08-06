//
//  AttendeeModel.swift
//  myapp
//
//  Created by Harsh Chauhan on 06/08/26.
//


/*
See the LICENSE.txt file for this sample's licensing information.

Abstract:
Defines the SwiftData model for an event attendee.
*/
import Foundation
import SwiftData
import SwiftUI

@Model
final class AttendeeModel {

    // MARK: Properties

    @Attribute(.unique)
    var id: UUID

    var statusValue: String

    @Relationship(deleteRule: .nullify)
    var contact: ContactModel?

    @Relationship(deleteRule: .nullify)
    var event: EventModel?

    @Transient
    var name: String { contact?.name ?? "Unknown" }
    @Transient
    var email: String { contact?.email ?? "" }

    var status: AttendeeStatusValue {
        get { AttendeeStatusValue(rawValue: statusValue) ?? .tentative }
        set { statusValue = newValue.rawValue }
    }

    // MARK: Life cycle

    init(contact: ContactModel, status: AttendeeStatusValue = .tentative) {
        self.id = UUID()
        self.contact = contact
        self.statusValue = status.rawValue
    }
}

enum AttendeeStatusValue: String, CaseIterable {
    case accepted
    case declined
    case tentative

    var color: Color {
        switch self {
        case .accepted: .green
        case .declined: .red
        case .tentative: .orange
        }
    }
}

// MARK: App Intents bridge

extension AttendeeModel {

    var entity: AttendeeEntity {
        AttendeeEntity(attendee: self)
    }
}
