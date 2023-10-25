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
        //Handles sorting UI for the underlying search results
        .toolbar{
            Menu{
                Button(dataController.filterEnabled ? "Turn Filter Off" : "Turn Filter On"){
                    dataController.filterEnabled.toggle()
                }
                Divider()
                Menu("Sort By"){
                    Picker("Sort By", selection: $dataController.sortType){
                        Text("Date Created").tag(SortType.dateCreated)
                        Text("Date Modified").tag(SortType.dateModified)
                    }
                    
                    Divider()
                    
                    Picker("Sort order", selection: $dataController.sortNewestFirst){
                        Text("Newest to Oldest").tag(true)
                        Text("Oldest to Newest").tag(false)
                    }
                }
                
                Picker("Status", selection: $dataController.filterStatus){
                    Text("All").tag(Status.all)
                    Text("Open").tag(Status.open)
                    Text("Closed").tag(Status.closed)
                }
                
                Picker("Priority", selection: $dataController.filterPriority){
                    Text("All").tag(-1)
                    Text("Low").tag(0)
                    Text("Medium").tag(1)
                    Text("High").tag(2)
                }
                
            } label: {
                Label("Filter", systemImage: "line.3.horizontal.decrease.circle")
            }
            
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
