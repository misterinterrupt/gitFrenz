//
//  Friend+CoreDataProperties.swift
//  
//
//  Created by m interrupt on 7/15/20.
//
//

import Foundation
import CoreData

struct DFriend: Hashable {
    let id: UUID
    let name: String
    let githubUsername: String
}

extension Friend {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Friend> {
        return NSFetchRequest<Friend>(entityName: "Friend")
    }

    @NSManaged public var name: String?
    @NSManaged public var githubUsername: String?
    @NSManaged public var id: UUID?
    @NSManaged public var relationship: NSSet?

}

// MARK: Generated accessors for relationship
extension Friend {

    @objc(addRelationshipObject:)
    @NSManaged public func addToRelationship(_ value: Repository)

    @objc(removeRelationshipObject:)
    @NSManaged public func removeFromRelationship(_ value: Repository)

    @objc(addRelationship:)
    @NSManaged public func addToRelationship(_ values: NSSet)

    @objc(removeRelationship:)
    @NSManaged public func removeFromRelationship(_ values: NSSet)

}
