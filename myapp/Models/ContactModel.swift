//
//  ContactModel.swift
//  myapp
//
//  Created by Harsh Chauhan on 06/08/26.
//


/*
See the LICENSE.txt file for this sample's licensing information.

Abstract:
Defines the SwiftData model for a contact.
*/
import Foundation
import SwiftData

@Model
final class ContactModel {

    // MARK: Properties

    @Attribute(.unique)
    var id: UUID

    var name: String
    var email: String

    @Relationship(deleteRule: .cascade, inverse: \AttendeeModel.contact)
    var attendances: [AttendeeModel]

    // MARK: Life cycle

    init(name: String, email: String) {
        self.id = UUID()
        self.name = name
        self.email = email.lowercased()
        self.attendances = []
    }
}
