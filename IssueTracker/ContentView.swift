//
//  ContentView.swift
//  IssueTracker
//
//  Created by Joel Storr on 24.10.23.
//

import SwiftUI

struct ContentView: View {
    
    @EnvironmentObject var dataController: DataController
    
  
    
    var body: some View {
        List(selection: $dataController.selectedIssue){
            ForEach(dataController.issuesForSelectedFilter()) { issue in
                IssueRow(issue: issue)
            }
            .onDelete(perform: delete)
        }
        .navigationTitle("Issues")
        .searchable(
            text: $dataController.filterText,
            tokens: $dataController.filterTokens, // Stores the selected Tags in an array
            suggestedTokens: .constant(dataController.suggestedFilterTokens), //Shows unselected suggested Tags
            prompt: "Filter issue or type # to add tags"
        ){ tag in
            Text(tag.tagName)
        }
        
    }
    
    func delete(_ offsets: IndexSet){
        
        let issues = dataController.issuesForSelectedFilter()
        
        for offset in offsets {
            let item = issues[offset]
            dataController.delete(item)
        }
    }
    
}

#Preview {
    ContentView()
}
