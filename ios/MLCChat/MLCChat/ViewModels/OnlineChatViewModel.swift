//
//  OnlineChatViewModel.swift
//  MLCChat
//
//  Created by Debakshi Bhattacharjee on 12/11/24.
//


import Foundation
import Combine
import CoreData

class OnlineChatViewModel: ObservableObject {
    @Published var messages: [ChatMessage] = [] // Manage chat messages
    @Published var isLoading: Bool = false // Manage loading state
    private var cancellables = Set<AnyCancellable>()
    
    var threadId: String // Track thread ID
    // Initialize with an optional question and a managed object context
    init(initialQuestion: String?) {
         self.threadId = getCurrentTimestampString()
         
         // If an initial question is provided, send the message
         if let question = initialQuestion, !question.isEmpty {
             appendMessage(type: .sending, message: question) // Add initial question
             appendMessage(type: .loading, message: "") // Add loading state for first question
             sendMessage(message: question) { success, apiUrl in
                 if success, let apiUrl = apiUrl {
                     self.getAnswer(urlString: apiUrl) { success, response, _ in
                         if success, let response = response {
                             self.removeLoadingMessage()
                             self.appendMessage(type: .receiving, message: concatenateStrings(from: response))
                         } else {
                             self.removeLoadingMessage()
                             self.appendMessage(type: .receiving, message: ErrorMessage.noAnswerFound)
                         }
                     }
                 } else {
                     self.removeLoadingMessage()
                     self.appendMessage(type: .receiving, message: ErrorMessage.unknownError)
                 }
             }
         }
     }

    // New initializer for loading threadData from history
       init(threadData: [ChatHistory]) {
           self.threadId = threadData.first?.threadId ?? getCurrentTimestampString()
           self.messages = threadData.flatMap { historyItem in
               [
                   ChatMessage(type: .sending, message: historyItem.question ?? ""), // Add the question as a sent message
                   ChatMessage(type: .receiving, message: historyItem.answer ?? "") // Add the answer as a received message
               ]
           }
       }
    // Function to send a message and call completion once done
    func sendMessage(message: String, completion: @escaping (_ success: Bool, _ answerAPI: String?) -> Void) {
        guard !message.isEmpty else { return }
        
        // Simulate API call to send the message
        GlobalAPIManager.performAPIRequest(
            url: URL(string: kBaseUrl)!,
            method: .post,
            parameters: .encodable(MsgInputModel(input: MsgInput(prompt: message))),
            accessToken: true,
            showLoader: false
        ) { (success: Bool, response: ChatModel?, errorMessage: String?) in
//            print("++++++++++++++++++++++++++++++++++++++++")
//            print(response)
//            print("++++++++++++++++++++++++++++++++++++++++")
            if success, let response = response {
                completion(true, response.urls?.get)
            } else {
                print(errorMessage ?? ErrorMessage.messageSendingError)
                completion(false, nil)
            }
        }
    }
    
    // Function to get an answer for the message
   func getAnswer(urlString: String?, completion: @escaping (_ success: Bool, _ message: [String?]?, _ APIUrl: String?) -> Void) {
        guard let urlString = urlString, let url = URL(string: urlString) else { return }
        
        // Function to poll the API until status is "succeeded"
        func pollForAnswer(url: URL, attempt: Int = 0, maxAttempts: Int = 10) {
            GlobalAPIManager.performAPIRequest(
                url: url,
                method: .get,
                parameters: .dictionary([:]),
                accessToken: true,
                showLoader: false
            ) { (success: Bool, response: AnswerModel?, errorMessage: String?) in
                if success, let response = response {
                    if response.status == ResponseStatus.succeeded {
                        // Return the response if processing is complete
                        completion(true, response.output, response.urls?.get)
                    } else if response.status == ResponseStatus.processing && attempt < maxAttempts {
                        // If still processing, wait for a moment and poll again
                        DispatchQueue.global().asyncAfter(deadline: .now() + 2.0) {
                            pollForAnswer(url: url, attempt: attempt + 1, maxAttempts: maxAttempts)
                        }
                    } else {
                        // If status is still not "succeeded" after max attempts or another error occurs
                        print(ErrorMessage.pollingError)
                        completion(false, nil, nil)
                    }
                } else {
                    print(errorMessage ?? ErrorMessage.fetchingAnswerError)
                    completion(false, nil, nil)
                }
            }
        }
        
        // Start polling for the answer
        pollForAnswer(url: url)
    }

    func removeLoadingMessage() {
        messages.removeAll { $0.type == .loading }
    }
    // Helper to append a message to the chat
    func appendMessage(type: MessageType, message: String) {
        let newMessage = ChatMessage(type: type, message: message)
        messages.append(newMessage)
    }
}
