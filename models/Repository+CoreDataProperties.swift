//
//  Repository+CoreDataProperties.swift
//  
//
//  Created by m interrupt on 7/15/20.
//
//

import Foundation
import CoreData

struct DRepository: Hashable {
    let id: UUID
    let url: URL
    let name: String
    let lastCommit: Date
}

extension Repository {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Repository> {
        return NSFetchRequest<Repository>(entityName: "Repository")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var url: URL?
    @NSManaged public var name: String?
    @NSManaged public var lastCommit: Date?
    @NSManaged public var relationship: NSSet?

}

// MARK: Generated accessors for relationship
extension Repository {

    @objc(addRelationshipObject:)
    @NSManaged public func addToRelationship(_ value: Friend)

    @objc(removeRelationshipObject:)
    @NSManaged public func removeFromRelationship(_ value: Friend)

    @objc(addRelationship:)
    @NSManaged public func addToRelationship(_ values: NSSet)

    @objc(removeRelationship:)
    @NSManaged public func removeFromRelationship(_ values: NSSet)

}
