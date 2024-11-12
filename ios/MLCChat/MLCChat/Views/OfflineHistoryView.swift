//
//  OfflineHistoryView.swift
//  MLCChat
//
//  Created by Debakshi Bhattacharjee on 12/11/24.
//

import SwiftUI
import CoreData

struct OfflineHistoryView: View {
    @Environment(\.managedObjectContext) private var context
    @Environment(\.dismiss) var dismiss
    @ObservedObject var historyViewModel: OfflineHistoryViewModel
    
    // Initializer for HistoryViewModel
    init(context: NSManagedObjectContext) {
        _historyViewModel = ObservedObject(wrappedValue: OfflineHistoryViewModel(context: context))
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                HStack {
                    Button(action: {
                        dismiss()
                    }) {
                        Image("Ic_Back") // Replace with your image name
                            .resizable()
                            .scaledToFit()
                            .frame(width: 30, height: 30) // Adjust size as needed
                    }
                    .padding()
                    
                    Text("History")
                        .font(.custom("SpaceGrotesk-Medium", size: 22))
                        .foregroundColor(.white)
                    Spacer()
                }
                .background(Color.black) // Background color for the header
                
                Divider()
                    .background(Color.white)
                
                if historyViewModel.offlineChatHistory.isEmpty {
                    VStack {
                        Spacer()
                        Text("Start chatting to see your offline history here!")
                            .font(.custom("SpaceGrotesk-Medium", size: 20))
                            .foregroundColor(.gray)
                        Spacer()
                    }
                    .background(Color.black.edgesIgnoringSafeArea(.all))
                } else {
                    // Custom list with black background when there is data
                    List {
                        ForEach(historyViewModel.offlineChatHistory, id: \.self) { sectionItem in
                            Section(header: headerView(for: sectionItem)) {
                                ForEach(sectionItem.groupedItemByThreadOffline.reversed(), id: \.self) { rowItem in
                                    NavigationLink(destination: /* ThreadView(threadData: rowItem)*/ Text("Offline Thread")) {
                                            cellView(for: rowItem)
                                                .background(Color.black) // Keep the cell background black
                                        }
                                        .listRowBackground(Color.clear) // Prevents default row background change
                                        .buttonStyle(PlainButtonStyle()) // Disable default button styling
                                }
                            }
                            .listRowSeparator(.hidden) // Hide separator for each section header
                        }
                    }
                    .listStyle(PlainListStyle()) // Use plain style to prevent default list styling
                    .scrollContentBackground(.hidden) // Hide the default list background
                    .background(Color.black) // Black background for the list
                }
            }
            .preferredColorScheme(.dark)
            .padding(.bottom, 20) // Optional padding at the bottom
            .background(Color.black.edgesIgnoringSafeArea(.all)) // Background color for the entire view
            .toolbar(.hidden, for: .navigationBar) // Hide the navigation bar
        }
    }
    
    // Custom header view for section
    @ViewBuilder
    func headerView(for sectionItem: RequiredFormOfOfflineData) -> some View {
        Text(describeTimeDifference(from: sectionItem.date))
            .font(.custom("SpaceGrotesk-Medium", size: 14))
            .foregroundColor(Color.green) // Green text
            .background(Color.black) // Black background for header
    }
    
    // Custom cell view for each row
    @ViewBuilder
    func cellView(for rowItem: [OfflineHistory]) -> some View {
        VStack(alignment: .leading) {
            if !rowItem.isEmpty {
                Text(rowItem[0].question ?? "")
                    .font(.custom("SpaceGrotesk-Medium", size: 16))
                    .foregroundColor(.white)
            } else {
                Text("No data available")
                    .font(.custom("SpaceGrotesk-Medium", size: 16))
                    .foregroundColor(.white)
            }
        }
        .background(Color.black) // Black background for cells
    }
}
