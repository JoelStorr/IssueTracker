//
//  IssueRowViewModel.swift
//  IssueTracker
//
//  Created by Joel Storr on 28.10.23.
//

import Foundation

extension IssueRow {
    
    @dynamicMemberLookup
    
    class ViewModel: ObservableObject {
        let issue: Issue
        
        init(issue: Issue) {
            self.issue = issue
        }
        
        var iconOpacity: Double {
            issue.priority == 2 ? 1 : 0
        }
        
        var iconIdentifire: String {
            issue.priority == 2
            ? "\(issue.issueTitle) High Priority"
            : ""
        }
        
        var accessibilityHint: String {
            issue.priority == 2 ? "High priority" : ""
        }
        
        var creationDate: String {
            issue.issueCreationDate.formatted(date: .numeric, time: .omitted)
        }
        
        var creationDateAccessibility: String {
            issue.issueCreationDate.formatted(date: .abbreviated, time: .omitted)
        }
        
        //Allows us to access values of the Issue directly on the viewModel
        subscript<Value>(dynamicMember keyPath: KeyPath<Issue, Value>) -> Value {
            issue[keyPath: keyPath]
        }
        
    }
}
