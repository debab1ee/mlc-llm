//
//  MLCChatApp.swift
//  MLCChat
//
//  Created by Tianqi Chen on 4/26/23.
//

import SwiftUI
import CoreData

@main
struct MLCChatApp: App {
    // Persistent container for Core Data
    let persistentContainer: NSPersistentCloudKitContainer = {
        let container = NSPersistentCloudKitContainer(name: "ChatHistory")
        container.loadPersistentStores { (description, error) in
            if let error = error {
                fatalError("Unresolved error: \(error)")
            }
        }
        return container
    }()
    
    // Use the managed object context from the container
    var managedObjectContext: NSManagedObjectContext {
        persistentContainer.viewContext
    }
    
    @StateObject private var appState = AppState()
    @Environment(\.scenePhase) private var scenePhase  // To observe app lifecycle changes
    
    init() {
        registerFonts()
        print("Fonts registered!")
        UITableView.appearance().separatorStyle = .none
        UITableView.appearance().tableFooterView = UIView()
    }
    
    var body: some Scene {
        WindowGroup {
            StartView()
                .environmentObject(appState)
                .environment(\.managedObjectContext, managedObjectContext) // Inject the managed object context
                .task {
                    appState.loadAppConfigAndModels()
                }
        }
        .onChange(of: scenePhase) { newPhase in
            if newPhase == .background {
                saveContext()
            }
        }
    }
    
    // Save Core Data context method
    func saveContext() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    func registerFonts() {
        guard let fontURLs = Bundle.main.urls(forResourcesWithExtension: "ttf", subdirectory: nil) else {
            print("No font URLs found")
            return
        }
        
        print("Found font URLs: \(fontURLs)") // Print the found URLs for debugging
        
        for fontURL in fontURLs {
            let success = CTFontManagerRegisterFontsForURL(fontURL as CFURL, .process, nil)
            print("Font registration successful: \(success) for \(fontURL.lastPathComponent)") // Print registration result
        }
    }
}
