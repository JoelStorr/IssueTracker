//
//  IssueTrackerTests.swift
//  IssueTrackerTests
//
//  Created by Joel Storr on 27.10.23.
//

import CoreData
import XCTest
@testable import IssueTracker

class BaseTestCase: XCTestCase {
    var dataController: DataController!
    var managedObjectContext: NSManagedObjectContext!

    override func setUpWithError() throws {
        dataController = DataController(inMemory: true)
        managedObjectContext = dataController.container.viewContext
    }
}
