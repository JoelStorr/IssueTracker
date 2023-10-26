//
//  NoIssueView.swift
//  IssueTracker
//
//  Created by Joel Storr on 25.10.23.
//

import SwiftUI

struct NoIssueView: View {

    @EnvironmentObject var dataController: DataController

    var body: some View {
        Text("No issue selected")
            .font(.title)
            .foregroundStyle(.secondary)

        Button("New Issue") {
            dataController.newIssue()
        }
    }
}

#Preview {
    NoIssueView()
}
