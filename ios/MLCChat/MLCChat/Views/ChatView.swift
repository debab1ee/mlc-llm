//
//  ChatView.swift
//  MLCChat
//

import SwiftUI
import GameController

struct ChatView: View {
    @EnvironmentObject private var chatState: ChatState
    @Environment(\.scenePhase) var scenePhase
    @Environment(\.managedObjectContext) private var context
    @State private var inputMessage: String = ""
    @FocusState private var inputIsFocused: Bool
    @Environment(\.dismiss) private var dismiss
    @Namespace private var messagesBottomID

    // vision-related properties
    @State private var showActionSheet: Bool = false
    @State private var showImagePicker: Bool = false
    @State private var imageConfirmed: Bool = false
    @State private var imageSourceType: UIImagePickerController.SourceType = .photoLibrary
    @State private var image: UIImage?
    
    //Handle History
//  private var threadId: String = getCurrentTimestampString()
    @State private var lastAnswer: String = ""

    var body: some View {
        VStack {
            navbarView
            modelInfoView
            messagesView
            uploadImageView
            messageInputView
        }
        .navigationBarTitle("solo: \(chatState.displayName)", displayMode: .inline)
        .background(Color.black.edgesIgnoringSafeArea(.all))
        .navigationBarBackButtonHidden()
        .onChange(of: scenePhase) { oldPhase, newPhase in
            if newPhase == .background {
                self.chatState.requestSwitchToBackground()
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    dismiss()
                } label: {
                    Image(.icBack)
                }
                .buttonStyle(.borderless)
                .disabled(!chatState.isInterruptible)
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Reset") {
                    image = nil
                    imageConfirmed = false
                    chatState.requestResetChat()
                }
                .padding()
                .disabled(!chatState.isResettable)
            }
        }
        .toolbar(.hidden, for: .navigationBar)

    }
}

private extension ChatView {
    var modelInfoView: some View {
        Text(chatState.infoText)
            .multilineTextAlignment(.center)
            .opacity(0.5)
            .listRowSeparator(.hidden)
    }

    var messagesView: some View {
        ScrollViewReader { scrollViewProxy in
            ScrollView {
                VStack {
                    let messageCount = chatState.displayMessages.count
                    let hasSystemMessage = messageCount > 0 && chatState.displayMessages[0].role == MessageRole.assistant
                    let startIndex = hasSystemMessage ? 1 : 0

                    // display the system message
                    if hasSystemMessage {
                        MessageView(role: chatState.displayMessages[0].role, message: chatState.displayMessages[0].message, isMarkdownSupported: false)
                    }

                    // display image
                    if let image, imageConfirmed {
                        ImageView(image: image)
                    }

                    // display conversations
                    ForEach(chatState.displayMessages[startIndex...], id: \.id) { message in
                        MessageView(role: message.role, message: message.message)
                    }
                    HStack { EmptyView() }
                        .id(messagesBottomID)
                }
            }
            .onChange(of: chatState.displayMessages) { _ in
                withAnimation {
                    scrollViewProxy.scrollTo(messagesBottomID, anchor: .bottom)
                }
            }
        }
    }

    @ViewBuilder
    var uploadImageView: some View {
        if chatState.legacyUseImage && !imageConfirmed {
            if image == nil {
                Button("Upload picture to chat") {
                    showActionSheet = true
                }
                .actionSheet(isPresented: $showActionSheet) {
                    ActionSheet(title: Text("Choose from"), buttons: [
                        .default(Text("Photo Library")) {
                            showImagePicker = true
                            imageSourceType = .photoLibrary
                        },
                        .default(Text("Camera")) {
                            showImagePicker = true
                            imageSourceType = .camera
                        },
                        .cancel()
                    ])
                }
                .sheet(isPresented: $showImagePicker) {
                    ImagePicker(image: $image,
                                showImagePicker: $showImagePicker,
                                imageSourceType: imageSourceType)
                }
                .disabled(!chatState.isUploadable)
            } else {
                VStack {
                    if let image {
                        Image(uiImage: image)
                            .resizable()
                            .frame(width: 300, height: 300)

                        HStack {
                            Button("Undo") {
                                self.image = nil
                            }
                            .padding()

                            Button("Submit") {
                                imageConfirmed = true
                            }
                            .padding()
                        }
                    }
                }
            }
        }
    }
    
    var messageInputView: some View {
        HStack {
//            Spacer().frame(width: 16)
            HStack {
                TextField("", text: $inputMessage, prompt: Text("Ask Anything...").foregroundColor(.white)
                    .font(.custom("SpaceGrotesk-Regular", size: 16)))
                .font(.custom("SpaceGrotesk-Regular", size: 16))
                .foregroundColor(.white)
                .padding(.leading, 10)
                .focused($inputIsFocused)
                .onSubmit {
                    let isKeyboardConnected = GCKeyboard.coalesced != nil
                    if isKeyboardConnected {
                        send()
                    }
                }
                Button(action: {
                    send()
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
        var navbarView: some View {
            // Top bar with avatar, title, and share button
            HStack {
                // Profile image as a back button
                Button(action: {
                    dismiss() // Navigate back to the previous view
                }) {
                    Image(.icBack)
                        .resizable()
                        .frame(width: 30, height: 30)
                        .padding(.leading)
                }
                .disabled(!chatState.isInterruptible)
                
                Spacer()

                Text("solo")
                    .font(.custom("SpaceGrotesk-Regular", size: 24))
                    .foregroundColor(.white)
                
                Spacer()
                
                Button(action: {
                    image = nil
                    imageConfirmed = false
                    chatState.requestResetChat()
                }) {
                    Image(.icReset)
                        .resizable()
                        .frame(width: 25, height: 25)
                        .padding(.trailing)
                }
                .disabled(!chatState.isResettable)
            }
            .padding(.top, 20)
            .background(Color.black)
        }
    
    func send() {
        inputIsFocused = false
        chatState.requestGenerate(prompt: inputMessage)
//        DispatchQueue.main.async {
//            if let lastMessage = chatState.displayMessages.last?.message, lastMessage != inputMessage, !lastMessage.isEmpty  {
//                lastAnswer = lastMessage
//            }
//
//        }
        inputMessage = ""
    }
}
