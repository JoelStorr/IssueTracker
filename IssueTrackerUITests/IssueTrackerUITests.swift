//
//  IssueTrackerUITests.swift
//  IssueTrackerUITests
//
//  Created by Joel Storr on 27.10.23.
//

import XCTest

extension XCUIElement {
    func clear() {
        guard let stringValue = self.value as? String else {
            XCTFail("Fail to clear text in XCUIElement")
            return
        }
        
        let deleteString = String( repeating: XCUIKeyboardKey.delete.rawValue, count: stringValue.count)
        typeText(deleteString)
    }
}




final class IssueTrackerUITests: XCTestCase {
    var app: XCUIApplication!

    override func setUpWithError() throws {
        app = XCUIApplication()
        app.launchArguments = ["enable-testing"]
        app.launch()
        
        continueAfterFailure = false
    }

    func testAppStartsWithNavigationBar() throws {
        // UI tests must launch the application that they test.
        XCTAssertTrue(app.navigationBars.element.exists, "Thre should be a navigation bar when the App launches.")
    }
    func testHasBasicButtonsOnLaunch() throws{
        XCTAssertTrue(app.navigationBars.buttons["Filters"].exists, "There should be a Filters button on launch.")
        XCTAssertTrue(app.navigationBars.buttons["Filter"].exists, "There should be a Filter button on launch.")
        XCTAssertTrue(app.navigationBars.buttons["New Issue"].exists, "There should be a New Issue button on launch.")
    }
    
    func testNoIssuesAtStart() throws {
        XCTAssertEqual(app.cells.count, 0, "There should be 0 list rows on launch.")
    }
    
    func testCreatingAndDeletingIssues() throws {
        for tapCount in 1...5 {
            app.buttons["New Issue"].tap()
            app.buttons["Issues"].tap()
            
            XCTAssertEqual(app.cells.count, tapCount, "There should be \(tapCount) rows in the list.")
        }
        
        for tapCount in (0...4).reversed() {
            app.cells.firstMatch.swipeLeft()
            app.buttons["Delete"].tap()
            
            XCTAssertEqual(app.cells.count, tapCount, "There should be \(tapCount) rows in the list.")
            
        }
    }
    
    
    func testEditingIssueTitleUpdatesCorrectly() throws {
        XCTAssertEqual(app.cells.count, 0, "There should bo no rows initially.")
        
        app.buttons["New Issue"].tap()
        
        app.textFields["Enter the issue title here"].tap()
        app.textFields["Enter the issue title here"].clear()
        app.typeText("My New Issue")
        
        
        app.buttons["Issues"].tap()
        XCTAssertTrue(app.buttons["My New Issue"].exists, "A My New Issue cell should now exist.")
    }
    
    
    func testEditingIssuePriorityShowsIcon() {
        app.buttons["New Issue"].tap()
        app.buttons["Priority, Medium"].tap()
        app.buttons["High"].tap()
        app.buttons["Issues"].tap()
        
        
        let identifire = "New issue High Priority"
        XCTAssert(app.images[identifire].exists, "A high priority issue needs an icon next to it")
    }
    
    
    func testAllAwardsShowLockedAlert(){
        app.buttons["Filters"].tap()
        app.buttons["Show awards"].tap()
        
        for award in app.scrollViews.buttons.allElementsBoundByIndex {
            
            // Is the  element on the screen fully inside our window
            if app.windows.element.frame.contains(award.frame) == false {
                //If it's not we want to swipe up.
                app.swipeUp()
            }
            
            award.tap()
            XCTAssertTrue(app.alerts["Locked"].exists, "There should be a locked alert showing for this award")
            app.buttons["OK"].tap()
        }
    }
}
