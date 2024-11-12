//
//  ThreadView.swift
//  MLCChat
//
//  Created by Debakshi Bhattacharjee on 12/11/24.
//


import SwiftUI
import LoaderUI
import CoreData

struct ThreadView: View {
    @Environment(\.managedObjectContext) private var context
    @Environment(\.dismiss) var dismiss
    @State private var textFieldText: String = ""
    @FocusState private var inputIsFocused
    @State private var isLoading: Bool = false // Track loading state
    @State private var isFirstResponseSaved: Bool
    
    @ObservedObject var chatViewModel: OnlineChatViewModel
    var threadData: [ChatHistory] = [] // Use when loading from history
    
    // Initializer for new question from Home Screen
    init(initialQuestion: String) {
        self.chatViewModel = OnlineChatViewModel(initialQuestion: initialQuestion)
        isFirstResponseSaved = false
    }
    
    // Initializer for loading from history
    init(threadData: [ChatHistory]) {
        self.threadData = threadData
        self.chatViewModel = OnlineChatViewModel(threadData: threadData)
        isFirstResponseSaved = true
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Top bar with dismiss and share buttons
                HStack {
                    Button(action: { dismiss() }) {
                        Image(.icCancel)
                            .resizable()
                            .frame(width: 30, height: 30)
                    }
                    .padding()
                    Spacer()
                    
                    Text("Thread")
                        .font(.custom("SpaceGrotesk-Medium", size: 22))
                        .foregroundColor(.white)
                    Spacer()
                    
                    Button(action: { /* Share action */ }) {
                        Image(.icShare)
                            .resizable()
                            .frame(width: 25, height: 25)
                            .padding(.trailing)
                    }
                }
                .background(Color.black)
                
                Divider().background(Color.white)
                
                ScrollViewReader { scrollViewProxy in
                    ScrollView {
                        VStack(alignment: .leading, spacing: 20) {
                            // Display all messages
                            ForEach(chatViewModel.messages) { message in
                                if message.type == .sending {
                                    QuestionView(question: message.message)
                                        .id(message.id) // Assign unique ID for each message
                                } else if message.type == .receiving {
                                    AnswerView(answer: message.message)
                                        .id(message.id)
                                } else if message.type == .loading {
                                    AnswerLoadingView()
                                        .id(message.id)
                                }
                            }
                        }
                        .padding()
                        .onAppear {
                            // Scroll to the last message when the view appears
                            if let lastMessage = chatViewModel.messages.last {
                                withAnimation {
                                    scrollViewProxy.scrollTo(lastMessage.id, anchor: .bottom)
                                }
                            }
                        }
                        // Add onChange modifier for scrolling when the text field gains focus
                        .onChange(of: inputIsFocused) { focused in
                            if focused {
                                // Scroll to the last message when the text field is focused
                                if let lastMessage = chatViewModel.messages.last {
                                    withAnimation {
                                        scrollViewProxy.scrollTo(lastMessage.id, anchor: .bottom)
                                    }
                                }
                            }
                        }
                    }
                    .frame(maxHeight: .infinity)
                }
                
                // Input field and send button
                HStack {
                    HStack {
                        TextField("", text: $textFieldText, prompt: Text("Ask Follow Up...")
                            .foregroundColor(.white)
                            .font(.custom("SpaceGrotesk-Regular", size: 16)))
                        .font(.custom("SpaceGrotesk-Regular", size: 16))
                        .foregroundColor(.white)
                        .padding(.leading, 10)
                        .focused($inputIsFocused)
                        
                        Button(action: {
                            sendButtonTapped()
                        }) {
                            Image(.icSend)
                                .resizable()
                                .frame(width: 32, height: 32)
                                .padding(.trailing, 10)
                        }
                        .disabled(isLoading) // Disable button when loading
                        .opacity(isLoading ? 0.5 : 1) // Optional: change opacity when disabled
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 10)
                    .background(Color(._333331))
                    .clipShape(Capsule())
                    .padding(.bottom, 10)
                    Spacer().frame(width: 16)
                }
            }
            .background(Color.black.edgesIgnoringSafeArea(.all))
            .toolbar(.hidden, for: .navigationBar)
        }
    }
    private func saveFirstResponseIfNeeded() {
        guard !isFirstResponseSaved else { return } // Ensure only one save operation
        
        // Check if the messages contain the initial question and the first answer
        if let question = chatViewModel.messages.first(where: { $0.type == .sending })?.message,
           let answer = chatViewModel.messages.first(where: { $0.type == .receiving })?.message {
            // Save question and answer to Core Data
            CoreDataManager.addDataToHistory(ques: question, ans: answer, threadId: chatViewModel.threadId, context: context)
            isFirstResponseSaved = true // Mark the first response as saved
        }
    }
    private func sendButtonTapped() {
        if !isFirstResponseSaved {
            saveFirstResponseIfNeeded()
        }
        if !textFieldText.isEmpty {
            inputIsFocused = false
            isLoading = true // Set loading state to true
            chatViewModel.appendMessage(type: .sending, message: textFieldText)
            chatViewModel.appendMessage(type: .loading, message: "")
            chatViewModel.sendMessage(message: textFieldText) { success, apiUrl in
                if success, let apiUrl = apiUrl {
                    chatViewModel.getAnswer(urlString: apiUrl) { success, response, _ in
                        isLoading = false // Reset loading state after getting response
                        if success, let response = response {
                            chatViewModel.removeLoadingMessage()
                            if let question = chatViewModel.messages.last?.message {
                                let answer = concatenateStrings(from: response)
                                CoreDataManager.addDataToHistory(ques: question, ans: answer, threadId: chatViewModel.threadId, context: self.context)
                            }
                            chatViewModel.appendMessage(type: .receiving, message: concatenateStrings(from: response))
                        } else {
                            chatViewModel.appendMessage(type: .receiving, message: ErrorMessage.noAnswerFound)
                            chatViewModel.removeLoadingMessage()
                        }
                    }
                } else {
                    isLoading = false // Reset loading state on error
                    chatViewModel.appendMessage(type: .receiving, message: ErrorMessage.unknownError)
                    chatViewModel.removeLoadingMessage()
                }
            }
            textFieldText = ""
        }
    }
}

struct QuestionView: View {
    var question: String // Accept the question as a parameter
    
    var body: some View {
        Text(question) // Display the passed question
            .font(.custom("SpaceGrotesk-Medium", size: 24))
            .foregroundStyle(Color(.FCFDF_8)) // White text color
            .frame(maxWidth: .infinity, alignment: .leading) // Align text to leading edge
            .textSelection(.enabled)
    }
}

struct AnswerLoadingView: View {
    var body: some View {
        VStack(alignment: .leading) {
            // Answer label and loader
            HStack {
                Image(.icThreeBar) // Your icon for the answer label
                    .resizable()
                    .frame(width: 25, height: 25) // Adjust icon size
                Text("Answer")
                    .font(.custom("SpaceGrotesk-Regular", size: 22))
                    .foregroundColor(.white)
                
            }
            .padding(.bottom, 5)
            
            HStack {
                Spacer().frame(width: 20) // 20px space
                BallPulseSync()
                    .foregroundStyle(Color(._20_C_20_E)) // White color for the loader
                    .frame(width: 40, height: 40) // Explicit size for loader to grow
            }
        }
    }
}

// Answer view for displaying received messages
struct AnswerView: View {
    var answer: String // Accept the answer as a parameter
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Image(.icThreeBar) // Your icon for the answer label
                    .resizable()
                    .frame(width: 25, height: 25)
                Text("Answer")
                    .font(.custom("SpaceGrotesk-Regular", size: 22))
                    .foregroundColor(.white)
            }
            .padding(.bottom, 5)
            
            HStack {
                Text(answer) // Display the answer text
                    .font(.custom("SpaceGrotesk-Regular", size: 16))
                    .foregroundColor(.white)
                    .textSelection(.enabled)
            }
        }
    }
}
