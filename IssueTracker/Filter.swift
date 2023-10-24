//
//  Filter.swift
//  IssueTracker
//
//  Created by Joel Storr on 24.10.23.
//

import Foundation


struct Filter: Identifiable, Hashable{
    var id: UUID
    var name: String
    var icon: String
    var modificationDate = Date.distantPast
    var tag: Tag?
    
    
    static var all = Filter(id: UUID(), name: "All Issues", icon: "tray")
    static var recent = Filter(id: UUID(), name: "Recent Issues", icon: "clock", modificationDate: .now.addingTimeInterval(86400 * -7))
    
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    //Allows us to compare to filters
    static func ==(lhs: Filter, rhs: Filter) -> Bool{
        lhs.id == rhs.id
    }
}
