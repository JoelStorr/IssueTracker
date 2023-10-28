//
//  IssueRow.swift
//  IssueTracker
//
//  Created by Joel Storr on 25.10.23.
//

import SwiftUI

struct IssueRow: View {

    @EnvironmentObject var dataController: DataController
    @StateObject var viewModel: ViewModel
    
    init(issue: Issue){
        let viewModel = ViewModel(issue: issue)
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        NavigationLink(value: viewModel.issue) {
            HStack {
                Image(systemName: "exclamationmark.circle")
                    .imageScale(.large)
                    .opacity(viewModel.iconOpacity)
                    .accessibilityIdentifier(
                        viewModel.iconIdentifire
                    )

                VStack(alignment: .leading) {
                    Text(viewModel.issueTitle)
                        .font(.headline)
                        .lineLimit(1)
                    Text(viewModel.issueTagsList)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
                Spacer()

                VStack(alignment: .trailing) {
                    Text(viewModel.creationDate)
                        .font(.subheadline)
                        .accessibilityLabel(viewModel.creationDateAccessibility)

                    if viewModel.completed {
                        Text("CLOSED")
                            .font(.body.smallCaps())
                    }
                }.foregroundStyle(.secondary)
            }
        }
        .accessibilityHint(viewModel.accessibilityHint)
        .accessibilityIdentifier(viewModel.issueTitle)
    }
}
