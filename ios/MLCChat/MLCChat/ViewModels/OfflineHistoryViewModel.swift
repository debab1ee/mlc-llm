//
//  OfflineHistoryViewModel.swift
//  MLCChat
//
//  Created by Debakshi Bhattacharjee on 12/11/24.
//


import Foundation
import CoreData

class OfflineHistoryViewModel: ObservableObject {
    @Published var offlineChatHistory: [RequiredFormOfOfflineData] = []
    
    init(context: NSManagedObjectContext) {
        getAllAnswer(context)
    }
    
    func getAllAnswer(_ context: NSManagedObjectContext) {
        self.offlineChatHistory = CoreDataManager.getAllOfflineHistoryData(context: context).reversed()
    }
}
