//
//  ExtensionTest.swift
//  IssueTrackerTests
//
//  Created by Joel Storr on 27.10.23.
//

import XCTest
import CoreData

@testable import IssueTracker

final class ExtensionTest: BaseTestCase {

    func testIssueTitleUnwrap() {
        let title = "Example issue"
        let titleUpdate = "Updated Title"
        let issue = Issue(context: managedObjectContext)
        
        issue.title = title
        XCTAssertEqual(issue.issueTitle, title, "Changing title should also change the issueTitle." )
        
        issue.issueTitle = titleUpdate
        XCTAssertEqual(issue.title, titleUpdate, "Changing issueTitle should also change the title." )
    }

    func testIssueContentUnwrap() {
        let content = "Example content"
        let contentUpdate = "Updated content"
        let issue = Issue(context: managedObjectContext)
        
        issue.content = content
        XCTAssertEqual(issue.issueContent, content, "Changing content should also change the issueContent." )
        
        issue.issueContent = contentUpdate
        XCTAssertEqual(issue.content, contentUpdate, "Changing issueContent should also change the content." )
    }
    
    func testIssueCretionDateUnwrap() {
        // Given
        let issue = Issue(context: managedObjectContext)
        let testDate = Date.now

        // When
        issue.creationDate = testDate
        
        // Then
        XCTAssertEqual(issue.issueCreationDate, testDate, "Changing creationDate should also change the issueCreationDate." )
    }
    
    func testIssueTagsUnwrap() {
        let tag = Tag(context: managedObjectContext)
        let issue = Issue(context: managedObjectContext)
        
        XCTAssertEqual(issue.issueTags.count, 0, "A new issue should have no tags")
        
        issue.addToTags(tag)
        XCTAssertEqual(issue.issueTags.count, 1, "Adding 1 tag to an issue should result in issueTags having a count of 1.")
    }
    
    func testIssueTagList() {
        let tag = Tag(context: managedObjectContext)
        let issue = Issue(context: managedObjectContext)
        
        tag.name = "My Tag"
        issue.addToTags(tag)
        
        XCTAssertEqual(issue.issueTagsList, "My Tag", "Adding 1 tag to an issue should make issueTagsList be My Tag.")
    }
    
    func testIssueSortingIsStable() {
        let issue1 = Issue(context: managedObjectContext)
        issue1.title = "B Issue"
        issue1.creationDate = .now
        
        let issue2 = Issue(context: managedObjectContext)
        issue2.title = "B Issue"
        issue2.creationDate = .now.addingTimeInterval(1)
        
        let issue3 = Issue(context: managedObjectContext)
        issue3.title = "A Issue"
        issue3.creationDate = .now.addingTimeInterval(100)
        
        
        let allIssues = [issue1, issue2, issue3]
        let sorted = allIssues.sorted()
        
        XCTAssertEqual([issue3, issue1, issue2], sorted, "Sorting issue arrays should use name then creation date.")
    }
    
    func testTagIDUnwrap() {
        let tag = Tag(context: managedObjectContext)
        
        tag.id = UUID()
        XCTAssertEqual(tag.tagID, tag.id, "Changling ID should also change tagID.")
    }
    
    func testTagNameUnwrap() {
        let tag = Tag(context: managedObjectContext)
        let name = "Test Name"
        
        tag.name = name
        XCTAssertEqual(tag.tagName, name, "Changling Name should also change tagName.")
    }
    
    func testTagActiveIssue() {
        let tag = Tag(context: managedObjectContext)
        let issue = Issue(context: managedObjectContext)
        
        XCTAssertEqual(tag.tagActiveIssues.count, 0, "A new tag should have 0 active issues.")
        
        tag.addToIssues(issue)
        XCTAssertEqual(tag.tagActiveIssues.count, 1, "A new tag with 1 issue should have 1 active issues.")
        
        issue.completed = true
        XCTAssertEqual(tag.tagActiveIssues.count, 0, "A new  tag with one completed issues should have 0 active issues.")
    }
    
    
    func testTagSortingIsStable() {
        let tag1 = Tag(context: managedObjectContext)
        tag1.name = "B Tag"
        tag1.id = UUID()
        
        let tag2 = Tag(context: managedObjectContext)
        tag2.name = "B Tag"
        tag2.id = UUID(uuidString: "FFFFFFFF-FFFF-4363-8FE1-06E6B2D592A8")
        
        let tag3 = Tag(context: managedObjectContext)
        tag3.name = "A Tag"
        tag3.id = UUID()
        
        let allTags = [tag1, tag2, tag3]
        let sortedTags = allTags.sorted()
        
        XCTAssertEqual([tag3, tag1, tag2], sortedTags, "Sorting Tags should use the name, then the UUID string.")
    }
    
    func testBundleDecodingAwards() {
        let awards = Bundle.main.decode("Awards.json", as: [Award].self)
        XCTAssertFalse(awards.isEmpty, "Awards.json should decode to a  none empty array.")
    }
    
    func testDecondingByString() {
        let bundle = Bundle(for: ExtensionTest.self)
        let data = bundle.decode("DecodableString.json", as: String.self)
        
        XCTAssertEqual(data, "Never ask a starfish for directions.", "The String must match DecodableString.json")
    }
    
    func testDecondingByDictionary() {
        let bundle = Bundle(for: ExtensionTest.self)
        let data = bundle.decode("DecodableDictionary.json", as: [String: Int].self)
        
        XCTAssertEqual(data.count, 3, "There should be 3 items decoded from DecodableString.json")
        XCTAssertEqual(data["One"], 1, "The dictionary should containe 1 for the key One")
    }
}
