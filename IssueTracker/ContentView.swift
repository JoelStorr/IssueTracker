//
//  ContentView.swift
//  IssueTracker
//
//  Created by Joel Storr on 24.10.23.
//

import SwiftUI

struct ContentView: View {
    
    @EnvironmentObject var dataController: DataController
    
    var issues: [Issue] {
        let filter = dataController.selectedFilter ?? .all
        var allIssues: [Issue]
        
        if let tag = filter.tag{
            allIssues = tag.issues?.allObjects as? [Issue] ?? []
        }else{
            let request = Issue.fetchRequest()
            request.predicate = NSPredicate(format: "modificationDate > %@", filter.minModificationDate as NSDate)
            allIssues = (try? dataController.container.viewContext.fetch(request)) ?? []
        }
        
        return allIssues
    }
    
    var body: some View {
        List{
            ForEach(issues) { issue in
                IssueRow(issue: issue)
            }
        }.navigationTitle("Issues")
    }
}

#Preview {
    ContentView()
}
