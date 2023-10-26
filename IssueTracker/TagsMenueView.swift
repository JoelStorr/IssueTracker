//
//  TagsMenueView.swift
//  IssueTracker
//
//  Created by Joel Storr on 26.10.23.
//

import SwiftUI

struct TagsMenueView: View {
    
    @EnvironmentObject var dataController: DataController
    @ObservedObject var issue: Issue
    
    var body: some View {
        Menu{
            //show selected tags first
            ForEach(issue.issueTags){ tag in
                Button{
                    issue.removeFromTags(tag)
                } label: {
                    Label(tag.tagName, systemImage: "checkmark")
                }
            }
            
            //show unselcted tags
            let otherTags = dataController.missingTags(from: issue)
            
            if otherTags.isEmpty == false {
                Divider()
                
                Section("Add Tags"){
                    ForEach(otherTags){ tag in
                        Button(tag.tagName){
                            issue.addToTags(tag)
                        }
                    }
                }
            }
        } label: {
            Text(issue.issueTagsList)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
                .animation(nil, value: issue.issueTagsList)
        }
    }
}
