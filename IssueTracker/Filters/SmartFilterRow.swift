//
//  SmartFilterRow.swift
//  IssueTracker
//
//  Created by Joel Storr on 26.10.23.
//

import SwiftUI

struct SmartFilterRow: View {

    var filter: Filter

    var body: some View {
        NavigationLink(value: filter) {
            Label(LocalizedStringKey(filter.name), systemImage: filter.icon)
        }
    }
}
