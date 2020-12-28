//
//  Contact+CoreDataProperties.swift
//  ContactsApp
//
//  Created by Teacher on 21.12.2020.
//
//

import Foundation
import CoreData


extension Contact {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Contact> {
        let fetchRequest = NSFetchRequest<Contact>(entityName: "Contact")
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(keyPath: \Contact.name, ascending: true)
        ]
        return fetchRequest
    }

    @NSManaged public var name: String?
    @NSManaged public var phoneNumber: String?
    @NSManaged public var friends: NSSet?
    @NSManaged public var child: Contact?
    @NSManaged public var parent: Contact?
}

// MARK: Generated accessors for friends
extension Contact {
    @objc(addFriendsObject:)
    @NSManaged public func addToFriends(_ value: Contact)

    @objc(removeFriendsObject:)
    @NSManaged public func removeFromFriends(_ value: Contact)

    @objc(addFriends:)
    @NSManaged public func addToFriends(_ values: NSSet)

    @objc(removeFriends:)
    @NSManaged public func removeFromFriends(_ values: NSSet)
}

extension Contact : Identifiable {
}
