//
//  PerformaceTest.swift
//  IssueTrackerTests
//
//  Created by Joel Storr on 27.10.23.
//

import XCTest
@testable import IssueTracker

final class PerformaceTest: BaseTestCase {

    func testAwardCalculationPerformance() {
        for _ in 1...100 {
            dataController.createSampleData()
        }

        let awards = Array( repeating: Award.allAwards, count: 25).joined()
        XCTAssertEqual(awards.count, 500, "This checks if the Awards count is constant. Change this if you add awards")

        measure {
            _ = awards.filter(dataController.hasEarned)
        }

    }
}
