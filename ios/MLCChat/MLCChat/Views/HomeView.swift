//
//  HomeView.swift
//  MLCChat
//
//  Created by Debakshi Bhattacharjee on 12/11/24.
//


import SwiftUI

struct HomeView: View {
    @Environment(\.dismiss) var dismiss // For handling back navigation
    @State private var textFieldText: String = "" // State variable for the text field
    @State private var navigateToThread = false
    @FocusState private var inputIsFocused
    
    let categoryData: [String] = [
        "What is the capital city of Japan?",
        "Who wrote the play 'Romeo and Juliet'?",
        "What is the largest planet in our solar system?",
        "What is the chemical symbol for water?",
        "Who was the first person to walk on the Moon?",
        "What is the smallest country in the world?",
        "What is the main ingredient in guacamole?",
        "What year did the Titanic sink?",
        "Who painted the Mona Lisa?",
        "What is the longest river in the world?",
        "Who developed the theory of relativity?",
        "Which element has the atomic number 1?",
        "What is the hardest natural substance on Earth?",
        "Which country is known as the Land of the Rising Sun?",
        "What is the largest ocean on Earth?",
        "Who is known as the 'Father of Computers'?",
        "What is the square root of 144?",
        "Which planet is known as the Red Planet?",
        "What is the tallest mountain in the world?",
        "Who invented the telephone?"
    ]
    
    // Grid layout for 3 rows
    let gridItems = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]
    
    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                VStack {
                    // Top bar with avatar, title, and share button
                    HStack {
                        // Profile image as a back button
                        Button(action: {
                            dismiss() // Navigate back to the previous view
                        }) {
                            Image(.icProfile)
                                .resizable()
                                .frame(width: 30, height: 30)
                                .padding(.leading)
                        }

                        Spacer()

                        Text("solo")
                            .font(.custom("SpaceGrotesk-Regular", size: 24))
                            .foregroundColor(.white)

                        Spacer()

                        Button(action: {
                            // Handle share action
                        }) {
                            Image(.icShare)
                                .resizable()
                                .frame(width: 25, height: 25)
                                .padding(.trailing)
                        }
                    }
                    .padding(.top, 20)
                    .background(Color.black)

                    // Reduced space between logo and scroll view
                    Spacer().frame(height: 100)

                    // Logo - height is 0.131 times the height of the view
                    Image(.logo)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: geometry.size.height * 0.131)

                    Spacer().frame(height: 30) // Adjusted space between logo and scroll view

                    // Horizontal ScrollView with a 3-row grid of tag-like labels
                    ScrollView(.horizontal, showsIndicators: false) {
                        LazyHGrid(rows: gridItems, spacing: 0) { // Reduced row spacing
                            ForEach(categoryData, id: \.self) { tag in
                                Text(tag)
                                    .font(.custom("SpaceGrotesk-Regular", size: 16)) // Custom font and size
                                    .padding(.vertical, 8)
                                    .padding(.horizontal, 10)
                                    .background(Color(._292927))
                                    .foregroundColor(.white)
                                    .clipShape(RoundedRectangle(cornerRadius: 8)) // Rounded rectangle shape
                                    .onTapGesture {
                                        textFieldText = tag // Set textFieldText to the tapped tag
                                    }
                            }
                        }
                        .padding(.vertical, 10)
                    }

                    Spacer()

                    HStack {
//                        Spacer().frame(width: 16)
                        // HStack containing the TextField and send button
                        HStack {
                            TextField("", text: $textFieldText, prompt: Text("Ask Anything...").foregroundColor(.white)
                                .font(.custom("SpaceGrotesk-Regular", size: 16))) // Binding to state variable
                                .font(.custom("SpaceGrotesk-Regular", size: 16))
                                .foregroundColor(.white)
                                .padding(.leading, 10)
                                .focused($inputIsFocused)

                            Button(action: {
                                if !textFieldText.isEmpty {
                                    inputIsFocused = false
                                    navigateToThread = true
                                }
                            }) {
                                Image(.icSend)
                                    .resizable()
                                    .frame(width: 32, height: 32)
                                    .padding(.trailing, 10) // Adjusted right padding
                            }
                        }
                        .padding(.horizontal, 10) // Added horizontal padding to the HStack
                        .padding(.vertical, 10) // Consistent vertical padding
                        .background(Color(._333331))
                        .clipShape(.capsule)
                        .padding(.bottom, 10)
                        Spacer().frame(width: 16)
                    }

                }
                .background(Color.black.edgesIgnoringSafeArea(.all)) // Black background for the whole view
                .toolbar(.hidden, for: .navigationBar) // Hide the navigation bar
                .navigationDestination(isPresented: $navigateToThread) {
                    ThreadView(initialQuestion: textFieldText) // Pass the textFieldText as a question to ThreadView
                }
            }
        }
    }
}
