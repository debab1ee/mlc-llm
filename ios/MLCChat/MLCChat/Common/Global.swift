//
//  Global.swift
//  MLCChat
//
//  Created by Debakshi Bhattacharjee on 12/11/24.
//


import Foundation

func getCurrentTimestampString() -> String {
    // Get the current date
    let currentDate = Date()
    
    // Create a DateFormatter instance
    let dateFormatter = DateFormatter()
    
    // Set the desired date format
    // Example format: "dd-MM-yyyy HH:mm:ss"
    dateFormatter.dateFormat = "dd-MM-yyyy HH:mm:ss"
    
    // Convert the date to a string
    let timestampString = dateFormatter.string(from: currentDate)
    
    return timestampString
}

func concatenateStrings(from array: [String?]) -> String {
    return array.compactMap { $0 }.filter { !$0.isEmpty }.joined(separator: "")
}

func describeTimeDifference(from date: Date) -> String {
    let calendar = Calendar.current
    let now = Date()
    
    // Check if the date is today
    if calendar.isDateInToday(date) {
        return "Today"
    }
    
    // Check if the date was yesterday
    if calendar.isDateInYesterday(date) {
        return "Yesterday"
    }
    
    // Calculate the difference in days
    let components = calendar.dateComponents([.day], from: date, to: now)
    
    if let dayDifference = components.day {
        if dayDifference == 1 {
            return "Last 1 day"
        } else if dayDifference > 1 {
            return "Last \(dayDifference) days"
        }
    }
    
    return "Unknown time difference"
}
