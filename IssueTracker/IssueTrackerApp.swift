//
//  IssueTrackerApp.swift
//  IssueTracker
//
//  Created by Joel Storr on 24.10.23.
//

import SwiftUI

@main
struct IssueTrackerApp: App {
    
    @StateObject var dataController = DataController()
    
    
    var body: some Scene {
        WindowGroup {
            
            NavigationSplitView{
                SidebarView()
            }content: {
                ContentView()
            }detail: {
                DetailView()
            }
            .environment(\.managedObjectContext, dataController.container.viewContext)
            .environmentObject(dataController)
        }
    }
}
