//
//  Plan+CoreDataProperties.swift
//  
//
//  Created by Andrew Walker on 2017/02/17.
//
//  This file was automatically generated and should not be edited.
//

import Foundation
import CoreData


extension Plan {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Plan> {
        return NSFetchRequest<Plan>(entityName: "Plan");
    }

    @NSManaged public var color: String?
    @NSManaged public var endDate: NSDate?
    @NSManaged public var extraInfo: String?
    @NSManaged public var flexible: Bool
    @NSManaged public var location: String?
    @NSManaged public var name: String?
    @NSManaged public var repeats: String?
    @NSManaged public var startDate: NSDate?

}
