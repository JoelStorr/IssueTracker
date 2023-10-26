//
//  SidebarViewToolbar.swift
//  IssueTracker
//
//  Created by Joel Storr on 26.10.23.
//

import SwiftUI

struct SidebarViewToolbar: View {
    
    @EnvironmentObject var dataController : DataController
    @Binding var showingAwards: Bool
    
    var body: some View {
        Button(action: dataController.newTag) {
            Label("Add tag", systemImage: "plus")
        }
        
        Button{
            showingAwards.toggle()
        } label: {
            Label("Show awards", systemImage: "rosette")
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


