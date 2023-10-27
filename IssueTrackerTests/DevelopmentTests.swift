//
//  DevelopmentTests.swift
//  IssueTrackerTests
//
//  Created by Joel Storr on 27.10.23.
//

import XCTest
import CoreData
@testable import IssueTracker

final class DevelopmentTests: BaseTestCase {

    func testSampleDataCretionWorks() {
        dataController.createSampleData()
        XCTAssertEqual(dataController.count(for: Tag.fetchRequest()), 5, "There should be 5 sample tags.")
        XCTAssertEqual(dataController.count(for: Issue.fetchRequest()), 50, "There should be 50 sample issues.")
    }

    func testDeleteAllClearsEverything() {
        dataController.createSampleData()
        dataController.deleteAll()
        XCTAssertEqual(dataController.count(for: Tag.fetchRequest()), 0, "There should be 0 sample tags.")
        XCTAssertEqual(dataController.count(for: Issue.fetchRequest()), 0, "There should be 0 sample issues.")
    }
    
    func testexampleTagsHasNoIssues() {
        let tag = Tag.example
        XCTAssertEqual(tag.issues?.count, 0, "The example Tag should have 0 issues.")
    }
    
    func testexampleIssueHasNoIssues() {
        let issue = Issue.example
        XCTAssertEqual(issue.priority, 2, "The example issue should have a priority of 2 / high.")
    }
}
