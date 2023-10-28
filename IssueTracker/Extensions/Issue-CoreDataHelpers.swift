//
//  Issue-CoreDataHelpers.swift
//  IssueTracker
//
//  Created by Joel Storr on 25.10.23.
//

import Foundation

// Removes the Optionality of core data types
extension Issue {
    var issueTitle: String {
        get { title ?? "" }
        set { title = newValue }
    }

    var issueContent: String {
        get { content ?? "" }
        set { content = newValue }
    }

    var issueCreationDate: Date {
        creationDate ?? .now
    }

    var issueModificationDate: Date {
        modificationDate ?? .now
    }

    var issueTags: [Tag] {
        let result = tags?.allObjects as? [Tag] ?? []
        return result.sorted()
    }

    var issueTagsList: String {
        let noTag = NSLocalizedString("No tags", comment: "There user has not created any tags jet")

        guard let tags else {return noTag}

        if tags.count == 0 {
            return noTag
        } else {
            return issueTags.map(\.tagName).formatted()
        }
    }

    var issueStatus: String {
        if completed {
            return NSLocalizedString("Closed", comment: "This issues has been resovled by the user")
        } else {
            return NSLocalizedString("Open", comment: "This issues is currently unresolved")
        }
    }

    static var example: Issue {
        let controller = DataController(inMemory: true)
        let viewContext = controller.container.viewContext

        let issue = Issue(context: viewContext)
        issue.title = "Example Issue"
        issue.content = "This is a example issue"
        issue.priority = 2
        issue.creationDate = .now
        return issue
    }
}

extension Issue: Comparable {
    public static func < (lhs: Issue, rhs: Issue) -> Bool {
        let left = lhs.issueTitle.localizedLowercase
        let right = rhs.issueTitle.localizedLowercase

        if left == right {
            return lhs.issueCreationDate < rhs.issueCreationDate
        } else {
            return left < right
        }
    }
}
