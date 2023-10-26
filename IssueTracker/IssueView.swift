//
//  IssueView.swift
//  IssueTracker
//
//  Created by Joel Storr on 25.10.23.
//

import SwiftUI

struct IssueView: View {
    @EnvironmentObject var dataController: DataController
    @ObservedObject var issue: Issue
    
    
    var body: some View {
        Form{
            Section{
                VStack(alignment: .leading){
                    TextField("Title", text: $issue.issueTitle, prompt: Text("Enter the issue title here"))
                        .font(.title)
                    
                    Text("**Modified:** \(issue.issueModificationDate.formatted(date: .long, time: .shortened))")
                        .foregroundStyle(.secondary)
                    
                    Text("**Status**: \(issue.issueStatus)")
                        .foregroundStyle(.secondary)
                }
                //Needs to be Int16 because CoreData only nows Int16 32 64
                Picker("Priority", selection: $issue.priority){
                    Text("Low").tag(Int16(0))
                    Text("Medium").tag(Int16(1))
                    Text("High").tag(Int16(2))
                }
                
               TagsMenueView(issue: issue)
                
            }
            Section{
                VStack(alignment: .leading){
                    Text("Basic Information")
                        .font(.title2)
                        .foregroundStyle(.secondary)
                    
                    TextField("Description", text: $issue.issueContent, prompt: Text("Enhter the issue description here"), axis: .vertical)
                    
                }
            }
        }
        .disabled(issue.isDeleted)
        .onReceive(issue.objectWillChange) { _ in
            dataController.queueSave()
        }
        .onSubmit(dataController.save)
        .toolbar{
            IssueViewToolbar(issue: issue)
        }
    }
}


