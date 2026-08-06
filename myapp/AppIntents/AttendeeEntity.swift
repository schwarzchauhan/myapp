//
//  AttendeeEntity.swift
//  myapp
//
//  Created by Harsh Chauhan on 06/08/26.
//


/*
See the LICENSE.txt file for this sample's licensing information.

Abstract:
Defines the attendee entity for the calendar domain.
*/
import AppIntents

@AppEntity(schema: .calendar.attendee)
struct AttendeeEntity: TransientAppEntity {

    // MARK: Properties

    /// The attendee's identity and contact information.
    var person: IntentPerson

    /// The attendance response for this attendee.
    var status: ParticipantStatus?

    /// A Boolean value that indicates whether attendance is optional.
    var isAttendanceOptional: Bool

    /// The role of the attendee in the event.
    var type: AttendeeType?

    var displayRepresentation: DisplayRepresentation {
        let imageName: String = switch status {
        case .accepted: "person.fill.checkmark"
        case .declined: "person.fill.xmark"
        case .tentative: "person.fill.questionmark"
        case .none: "person"
        }
        return DisplayRepresentation(
            title: "\(person.name)",
            subtitle: "\(person.handle)",
            image: .init(systemName: imageName)
        )
    }

    // MARK: Life cycle

    init(attendee: AttendeeModel) {
        self.person = IntentPerson(
            identifier: .applicationDefined(attendee.id.uuidString),
            name: .displayName(attendee.name),
            handle: .init(emailAddress: attendee.email)
        )
        self.status = ParticipantStatus(rawValue: attendee.statusValue)
        self.isAttendanceOptional = false
        self.type = .person
    }

    init() { }
}

// MARK: Enums

@AppEnum(schema: .calendar.attendeeStatus)
enum ParticipantStatus: String {
    case accepted
    case declined
    case tentative

    static let caseDisplayRepresentations: [Self: DisplayRepresentation] = [
        .accepted: "Accepted",
        .declined: "Declined",
        .tentative: "Tentative"
    ]
}

@AppEnum(schema: .calendar.attendeeType)
enum AttendeeType: String {
    case person

    static let caseDisplayRepresentations: [Self: DisplayRepresentation] = [
        .person: "Person"
    ]
}
