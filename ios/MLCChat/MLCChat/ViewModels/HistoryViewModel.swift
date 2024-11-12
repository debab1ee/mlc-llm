//
//  HistoryViewModel.swift
//  MLCChat
//
//  Created by Debakshi Bhattacharjee on 12/11/24.
//



import Foundation
import CoreData

class HistoryViewModel: ObservableObject {
    @Published var chatHistory: [RequiredFormOfData] = []
    
    init(context: NSManagedObjectContext) {
        getAllAnswer(context)
    }
    
    func getAllAnswer(_ context: NSManagedObjectContext) {
        self.chatHistory = CoreDataManager.getAllHistoryData(context: context).reversed()
    }
}
