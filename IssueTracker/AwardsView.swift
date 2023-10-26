//
//  AwardsView.swift
//  IssueTracker
//
//  Created by Joel Storr on 26.10.23.
//

import SwiftUI

struct AwardsView: View {
    
    var columns: [GridItem] {
        [GridItem(.adaptive(minimum: 100, maximum: 100))]
    }
    
    var body: some View {
        NavigationStack{
            ScrollView{
                LazyVGrid(columns: columns) {
                    ForEach(Award.allAwards){ award in
                        Button{
                            
                        } label: {
                            Image(systemName: award.image)
                                .resizable()
                                .scaledToFit()
                                .padding()
                                .frame(width: 100,height: 100)
                                .foregroundStyle(.secondary.opacity(0.5))
                        }
                    }
                }
            }
            .navigationTitle("Awards")
        }
    }
}

#Preview {
    AwardsView()
}
