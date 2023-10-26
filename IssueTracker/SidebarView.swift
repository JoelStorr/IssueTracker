//
//  SidebarView.swift
//  IssueTracker
//
//  Created by Joel Storr on 24.10.23.
//

import SwiftUI

struct SidebarView: View {
    
    @EnvironmentObject var dataController: DataController
    let smartFilters: [Filter] = [.all, .recent]
    
    @FetchRequest(sortDescriptors: [SortDescriptor(\.name)]) var tags: FetchedResults<Tag>
    
    
    
    
    
    
    var tagFilters: [Filter] {
        tags.map{ tag in
            Filter(id: tag.tagID, name: tag.tagName, icon: "tag", tag: tag)
        }
    }
    
    var body: some View {
        List(selection: $dataController.selectedFilter){
            Section("Smart Filters"){
                ForEach(smartFilters){ filter in
                    NavigationLink(value: filter) {
                        Label(filter.name, systemImage: filter.icon)
                    }
                }
                
            }
            
            Section("Tags"){
                ForEach(tagFilters){ filter in
                    NavigationLink(value: filter){
                        Label(filter.name, systemImage: filter.icon)
                            .badge(filter.tag?.tagActiveIssue.count ?? 0)
                    }
                }
                .onDelete(perform: delete)
                
            }
        }
        .toolbar{
            Button(action: dataController.newTag) {
                Label("Add tag", systemImage: "plus")
            }
            
            #if DEBUG
            Button{
                dataController.deleteAll()
                dataController.createSampleData()
            } label: {
                Label("ADD SAMPLES", systemImage: "flame")
            }
            #endif
            
        }
    }
    
    func delete(_ offsets: IndexSet){
        for offset in offsets{
            let item = tags[offset]
            dataController.delete(item)
        }
    }
}

#Preview {
    SidebarView()
}
