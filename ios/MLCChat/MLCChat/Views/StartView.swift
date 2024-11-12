//
//  DownloadView.swift
//  MLCChat
//
//  Created by Yaxing Cai on 5/11/23.
//

import SwiftUI
import CoreData

struct StartView: View {
    @EnvironmentObject private var appState: AppState
    @Environment(\.managedObjectContext) private var context
    @State private var isRemoving: Bool = false
    @State private var inputModelUrl: String = ""
    @State private var navigateToHome: Bool = false // State to control navigation
    @State private var isOfflineVersion: Bool = false // Toggle for offline version
    @State private var navigateToHelp: Bool = false // State to control navigation to HelpView
    @State private var navigateToHistory: Bool = false

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading) { // Set the alignment of the VStack to leading
                // Centered title text at the top
                HStack {
                    Spacer()
                    Text("Settings")
                        .font(.custom("SpaceGrotesk-Medium", size: 22))
                        .foregroundColor(.white) // White text color for dark mode
                        .padding(.top, 20) // Padding at the top
                    Spacer()
                }
                Divider()
                    .background(Color.white)

                // Toggle for offline version
                Toggle("Offline Version", isOn: $isOfflineVersion)
                    .toggleStyle(SwitchToggleStyle(tint: Color(._20_C_20_E))) // Customize toggle color
                    .font(.custom("SpaceGrotesk-Medium", size: 16))
                    .foregroundColor(.white) // Text color for the toggle
                    .padding(.leading)
                    .padding(.trailing)
                    .padding(.top)
                    .padding(.bottom, 5) // Reduced padding to bring the text closer

                // Descriptive text for Offline Version
                Text("Unleash productivity anytime, anywhere with our Offline Version: seamless, powerful, and always ready.")
                    .font(.custom("SpaceGrotesk-Regular", size: 14))
                    .foregroundStyle(Color(._909090))
                    .padding(.leading)
                    .padding(.trailing)
                    .padding(.top, 5)

                // Conditionally display ModelView or Navigate to Home button
                if isOfflineVersion {
                    // ModelView for the single model
                    if let firstModel = appState.models.first {
                        ModelView(isRemoving: .constant(isRemoving))
                            .environmentObject(firstModel) // Use the first (and only) model from the environment object
                            .environmentObject(appState.chatState)
                            .font(.custom("SpaceGrotesk-Medium", size: 16))
                            .foregroundColor(Color(._20_C_20_E))
                            .padding() // Add padding around the model view
                    } else {
                        Text("No offline models available") // Message if no models exist
                            .font(.custom("SpaceGrotesk-Medium", size: 16))
                            .foregroundColor(.white) // White text color
                            .padding()
                    }
                } else {
                    // Show Navigate to Home button if offline mode is off
                    Button("Go To Chat") {
                        navigateToHome = true // Trigger navigation
                    }
                    .buttonStyle(.borderless)
                    .font(.custom("SpaceGrotesk-Medium", size: 16))
                    .foregroundColor(Color(._20_C_20_E)) // Change button color to the specified green
                    .padding()
                }
                Button("Chat History") {
                    navigateToHistory = true // Trigger navigation to HelpView
                }
                .buttonStyle(.borderless)
                .font(.custom("SpaceGrotesk-Medium", size: 16))
                .foregroundColor(.white)
                .padding(.leading)
                .padding(.trailing)
                .padding(.bottom, 5)
                // Help Section
                Text("Help")
                    .font(.custom("SpaceGrotesk-Medium", size: 14))
                    .foregroundColor(Color(._20_C_20_E)) // Green text
                    .padding(.leading)
                    .padding(.trailing)
                    .padding(.top, 10)

                Button("Help") {
                    navigateToHelp = true // Trigger navigation to HelpView
                }
                .buttonStyle(.borderless)
                .font(.custom("SpaceGrotesk-Medium", size: 16))
                .foregroundColor(.white) // White text color for the button
                .padding(.leading)
                .padding(.trailing)
                .padding(.top, 5)

                // About Section
                Text("About")
                    .font(.custom("SpaceGrotesk-Medium", size: 14))
                    .foregroundColor(Color(._20_C_20_E)) // Green text
                    .padding(.leading)
                    .padding(.trailing)
                    .padding(.top, 10)
                Text("Version")
                    .font(.custom("SpaceGrotesk-Medium", size: 16))
                    .foregroundColor(Color(.white))
                    .padding(.leading)
                    .padding(.trailing)
                    .padding(.top, 5)
                Text("    Llama 3.1, Llama 3.2") // Indented version information
                    .font(.custom("SpaceGrotesk-Regular", size: 14))
                    .foregroundColor(Color(.lightGray))
                    .padding(.leading)
                    .padding(.trailing)
                    .padding(.top, 3)
                Text("Terms of Service")
                    .font(.custom("SpaceGrotesk-Medium", size: 16))
                    .foregroundColor(Color(.white))
                    .padding(.leading)
                    .padding(.trailing)
                    .padding(.top, 5)
                Text("Privacy Policy")
                    .font(.custom("SpaceGrotesk-Medium", size: 16))
                    .foregroundColor(Color(.white))
                    .padding(.leading)
                    .padding(.trailing)
                    .padding(.top, 5)
                
                Spacer()
                // App version and build number centered at the bottom
                HStack {
                    Spacer()
                    Text("Solo \(appVersion) (\(appBuild))")
                        .font(.custom("SpaceGrotesk-Regular", size: 14))
                        .foregroundColor(.gray)
                        .padding(.bottom, 20) // Add padding at the bottom
                    Spacer()
                }
            }
            .background(Color.black.edgesIgnoringSafeArea(.all)) // Black background for dark mode
            .navigationDestination(isPresented: $navigateToHome) {
                HomeView() // Navigate to HomeView when navigateToHome is true
            }
            .navigationDestination(isPresented: $navigateToHelp) {
                HelpView() // Navigate to HelpView when navigateToHelp is true
            }
            .navigationDestination(isPresented: $navigateToHistory) {
                HistoryView(context: context) // Navigate to HistoryView when navigateToHelp is true
            }
            .alert("Error", isPresented: $appState.alertDisplayed) {
                Button("OK") { }
            } message: {
                Text(appState.alertMessage)
            }
        }
    }
    
    // Computed properties to get the app version and build number
    private var appVersion: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "Unknown"
    }
    
    private var appBuild: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "Unknown"
    }
}
