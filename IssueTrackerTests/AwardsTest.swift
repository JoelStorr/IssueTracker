//
//  AwardsTest.swift
//  IssueTrackerTests
//
//  Created by Joel Storr on 27.10.23.
//

import CoreData
import XCTest

@testable import IssueTracker

final class AwardsTest: BaseTestCase {

    let awards = Award.allAwards
    
    func testAwardIDMatchesName(){
        for award in awards {
            XCTAssertEqual(award.id, award.name, "Award ID should alwasy match its name.")
        }
    }
    
    func testNewUserHasNoAwards(){
        for award in awards {
             XCTAssertEqual(dataController.hasEarned(award: award), false, "A new user should not have any awards.")
        }
    }
    
    func testCreatingIssuesUnlocksAwards(){
        let values = [1, 10, 20, 50, 100, 250, 500, 1000]
        
        for (count, value) in values.enumerated() {
            var issues = [Issue]()
            
            for _ in 0..<value {
                let issue = Issue(context: managedObjectContext)
                issues.append(issue)
            }
            
            let matches = awards.filter { award in
                award.criterion == "issues" && dataController.hasEarned(award: award)
            }
            
            XCTAssertEqual(matches.count, count + 1, "Adding \(value) issues should unlock \(count + 1) awards.")
            dataController.deleteAll()
            
        }
    }
}
