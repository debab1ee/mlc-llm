//
//  CoreDataManager.swift
//  MLCChat
//
//  Created by Debakshi Bhattacharjee on 12/11/24.
//

import Foundation
import CoreData

struct RequiredFormOfData: Hashable {
    let date: Date
    let groupedItemByThread: [[ChatHistory]]
}
struct RequiredFormOfOfflineData: Hashable {
    let date: Date
    let groupedItemByThreadOffline: [[OfflineHistory]]
}
class CoreDataManager {
    
    // Store data in CoreData (context is passed from SwiftUI environment)
    static func addDataToHistory(ques: String, ans: String, threadId: String, context: NSManagedObjectContext) {
        let newEntries = ChatHistory(context: context)
        newEntries.question = ques
        newEntries.answer = ans
        newEntries.date = Date()
        newEntries.threadId = threadId
        
        do {
            try context.save()
            print("Data Added Successfully")
        } catch {
            print("Error Saving data: \(error.localizedDescription)")
        }
    }
    static func addDataToOfflineHistory(ques: String, ans: String, threadId: String, context: NSManagedObjectContext) {
        let newEntries = OfflineHistory(context: context)
        newEntries.question = ques
        newEntries.answer = ans
        newEntries.date = Date()
        newEntries.threadId = threadId
        
        do {
            try context.save()
            print("Offline Data Added Successfully")
        } catch {
            print("Error Saving data: \(error.localizedDescription)")
        }
    }
    // Strips the time from a date, keeping only the year, month, and day
    static func stripTime(from date: Date) -> Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day], from: date)
        return calendar.date(from: components)!
    }
    
    // Grouping function to group ChatHistories by Date (ignoring time)
    static func groupChatHistoriesByDate(chatHistories: [ChatHistory]) -> [[ChatHistory]] {
        var dateToHistories = [Date: [ChatHistory]]()
        
        for chatHistory in chatHistories {
            guard let date = chatHistory.date else { continue }
            let strippedDate = stripTime(from: date)
            
            if dateToHistories[strippedDate] != nil {
                dateToHistories[strippedDate]?.append(chatHistory)
            } else {
                dateToHistories[strippedDate] = [chatHistory]
            }
        }
        
        // Sort keys (dates) to maintain order
        let sortedDates = dateToHistories.keys.sorted()
        let groupedArray = sortedDates.map { dateToHistories[$0]! }
        
        return groupedArray
    }
    // Grouping function to group ChatHistories by Date (ignoring time)
    static func groupOfflineChatHistoriesByDate(chatHistories: [OfflineHistory]) -> [[OfflineHistory]] {
        var dateToHistories = [Date: [OfflineHistory]]()
        
        for chatHistory in chatHistories {
            guard let date = chatHistory.date else { continue }
            let strippedDate = stripTime(from: date)
            
            if dateToHistories[strippedDate] != nil {
                dateToHistories[strippedDate]?.append(chatHistory)
            } else {
                dateToHistories[strippedDate] = [chatHistory]
            }
        }
        
        // Sort keys (dates) to maintain order
        let sortedDates = dateToHistories.keys.sorted()
        let groupedArray = sortedDates.map { dateToHistories[$0]! }
        
        return groupedArray
    }
    // Convert grouped ChatHistories into RequiredFormOfData
    static func convertToRequiredFormOfData(groupedChatHistories: [[ChatHistory]]) -> [RequiredFormOfData] {
        var result: [RequiredFormOfData] = []
        
        for chatHistories in groupedChatHistories {
            guard let date = chatHistories.first?.date else { continue }
            
            // Group by threadId
            let groupedByThread = Dictionary(grouping: chatHistories, by: { $0.threadId })
            
            // Sort each group by date to ensure chronological order within each thread
            let sortedGroupedItemByThread = groupedByThread.map { (threadId, histories) -> [ChatHistory] in
                histories.sorted(by: { $0.date ?? Date() < $1.date ?? Date() })
            }.sorted(by: { $0.first?.date ?? Date() < $1.first?.date ?? Date() })
            
            let requiredData = RequiredFormOfData(date: date, groupedItemByThread: sortedGroupedItemByThread)
            result.append(requiredData)
        }
        
        return result
    }
    static func convertToRequiredFormOfOfflineData(groupedChatHistories: [[OfflineHistory]]) -> [RequiredFormOfOfflineData] {
        var result: [RequiredFormOfOfflineData] = []
        
        for chatHistories in groupedChatHistories {
            guard let date = chatHistories.first?.date else { continue }
            
            // Group by threadId
            let groupedByThread = Dictionary(grouping: chatHistories, by: { $0.threadId })
            
            // Sort each group by date to ensure chronological order within each thread
            let sortedGroupedItemByThread = groupedByThread.map { (threadId, histories) -> [OfflineHistory] in
                histories.sorted(by: { $0.date ?? Date() < $1.date ?? Date() })
            }.sorted(by: { $0.first?.date ?? Date() < $1.first?.date ?? Date() })
            
            let requiredData = RequiredFormOfOfflineData(date: date, groupedItemByThreadOffline: sortedGroupedItemByThread)
            result.append(requiredData)
        }
        
        return result
    }
    // Fetch all ChatHistories, group them, and convert to RequiredFormOfData
    static func getAllHistoryData(context: NSManagedObjectContext) -> [RequiredFormOfData] {
        do {
            let fetchRequest: NSFetchRequest<ChatHistory> = ChatHistory.fetchRequest()
            let sortDescriptor = NSSortDescriptor(key: "date", ascending: false)
            fetchRequest.sortDescriptors = [sortDescriptor]
            
            let allChats = try context.fetch(fetchRequest)
            let groupedBySameDate = groupChatHistoriesByDate(chatHistories: allChats)
            
            let requiredFormOfData = convertToRequiredFormOfData(groupedChatHistories: groupedBySameDate)
            return requiredFormOfData
            
        } catch {
            print("Error fetching data:", error)
            return []
        }
    }
    
    static func getAllOfflineHistoryData(context: NSManagedObjectContext) -> [RequiredFormOfOfflineData] {
        do {
            let fetchRequest: NSFetchRequest<OfflineHistory> = OfflineHistory.fetchRequest()
            let sortDescriptor = NSSortDescriptor(key: "date", ascending: false)
            fetchRequest.sortDescriptors = [sortDescriptor]
            
            let allChats = try context.fetch(fetchRequest)
            let groupedBySameDate = groupOfflineChatHistoriesByDate(chatHistories: allChats)
            
            let requiredFormOfData = convertToRequiredFormOfOfflineData(groupedChatHistories: groupedBySameDate)
            return requiredFormOfData
            
        } catch {
            print("Error fetching data:", error)
            return []
        }
    }
}
