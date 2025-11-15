//
//  ContentView.swift
//  MessagingCoreExample
//
//  Updated with F1 RaceFan Agent Styling
//

import SwiftUI
import SMIClientCore

class ObserveableConversationEntries: ObservableObject {
    @Published var conversationEntries: [ConversationEntry] = []
}

struct ContentView: View {
    @State private var isChatFeedHidden = true
    @State private var messageInputText: String
    @State private var businessHoursMessage: String?
    @State private var shouldHideBusinessHoursBanner: Bool = true
    @State private var isWithinBusinessHours: Bool = false
    @ObservedObject var observeableConversationData: ObserveableConversationEntries
    var viewModel: MessagingViewModel

    init(isChatFeedHidden: Bool = true, messageInputText: String = "") {
        self.isChatFeedHidden = isChatFeedHidden
        self.messageInputText = messageInputText
        let observableEntries = ObserveableConversationEntries()
        self.observeableConversationData = observableEntries
        self.viewModel = MessagingViewModel(observeableConversationData: observableEntries)
    }

    var body: some View {
        if !isChatFeedHidden {
            ChatFeed
        } else {
            ChatMenu
        }
    }

    // MARK: - Chat Menu (Landing Screen)
    
    private var ChatMenu: some View {
        VStack(spacing: 0) {
            // F1 Red Header
            VStack {
                // Text("🏎️ RaceFan Agent")
                //     .font(.title)
                //     .fontWeight(.bold)
                //     .foregroundColor(F1Theme.textWhite)
                // Text("Powered by Agentforce")
                //     .font(.subheadline)
                //     .foregroundColor(F1Theme.textWhite.opacity(0.9))
                Image("Salesforce_Agentforce")
                    .resizable()
                    .frame(width: 100, height: 100)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
            .background(F1Theme.f1Red)
            
            Spacer()
            
            // Main Content
            VStack(spacing: 16) {
                Text("Messaging for In-App Core SDK")
                    .font(.headline)
                    .foregroundColor(F1Theme.textWhite)
                
                Text("F1 Las Vegas Grand Prix 2025")
                    .font(.subheadline)
                    .foregroundColor(F1Theme.placeholderGray)
            }
            
            Spacer()
            
            // Action Buttons
            VStack(spacing: 12) {
                Button("Speak with an Agent") {
                    isChatFeedHidden.toggle()
                    viewModel.fetchAndUpdateConversation()
                }
                .buttonStyle(F1PrimaryButton())
                
                Button("Reset Conversation ID") {
                    viewModel.resetChat()
                }
                .buttonStyle(F1SecondaryButton())
                
                Button("Retrieve Transcript") {
                    viewModel.retrieveTranscript()
                }
                .buttonStyle(F1SecondaryButton())
            }
            .padding(.horizontal, 24)
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(F1Theme.chatBlack)
    }

    // MARK: - Chat Feed (Main Chat Interface)
    
    private var ChatFeed: some View {
        VStack(spacing: 0) {
            // F1 Red Navigation Header
            HStack {
                Button(action: {
                    isChatFeedHidden.toggle()
                }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(F1Theme.textWhite)
                        .font(.title3)
                }

                Image("F1_2025")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 25)
                
                VStack(alignment: .leading, spacing: 2) {
                    // Text("RaceFan Agent")
                    //     .font(.headline)
                    //     .foregroundColor(F1Theme.textWhite)
                    // Text("Powered by Agentforce")
                    //     .font(.caption)
                    //     .foregroundColor(F1Theme.textWhite.opacity(0.9))
                    Image("Salesforce_Agentforce")
                        .resizable()
                        .frame(width: 100, height: 100)
                }
                
                Spacer()
                
                // Optional: Add menu button
                Button(action: {
                    // Menu action
                }) {
                    Image(systemName: "ellipsis")
                        .foregroundColor(F1Theme.textWhite)
                        .font(.title3)
                }
            }
            .padding()
            .background(F1Theme.f1Red)
            
            // Business Hours Banner
            VStack {
                Text(businessHoursMessage ?? "Not within business hours")
                    .font(.caption)
                    .foregroundColor(F1Theme.textWhite)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 8)
                    .background(isWithinBusinessHours ? F1Theme.successGreen : F1Theme.errorRed)
            }
            .isHidden(shouldHideBusinessHoursBanner, remove: shouldHideBusinessHoursBanner)
            
            // Chat Messages
            ChatFeedList
                .background(F1Theme.chatLightBackground)
                .onAppear {
                    viewModel.checkIfWithinBusinessHours(completion: { (isWithinBusinessHours, isBusinessHoursConfigured) in
                        self.shouldHideBusinessHoursBanner = !isBusinessHoursConfigured
                        self.isWithinBusinessHours = isWithinBusinessHours
                        businessHoursMessage = isWithinBusinessHours ? "You are within business hours" : "You are not within business hours"
                    })
                }
            
            // Message Input Area
            HStack(spacing: 12) {
                TextField("Type a message...", text: $messageInputText)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(F1Theme.inputBackground)
                    .foregroundColor(F1Theme.textWhite)
                    .cornerRadius(24)
                    .overlay(
                        RoundedRectangle(cornerRadius: 24)
                            .stroke(F1Theme.borderGray, lineWidth: 1)
                    )
                
                Button(action: {
                    viewModel.sendTextMessage(message: messageInputText.description)
                    messageInputText = ""
                }) {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.system(size: 32))
                        .foregroundColor(messageInputText.isEmpty ? F1Theme.borderGray : F1Theme.salesforceBlue)
                }
                .disabled(messageInputText.isEmpty)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color.white)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(F1Theme.chatBlack)
    }

    // MARK: - Chat Feed List
    
    private var ChatFeedList: some View {
        ScrollView {
            LazyVStack(spacing: 8) {
                ForEach(observeableConversationData.conversationEntries, id: \.identifier) { message in
                    // Handle each messaging type
                    switch message.format {
                    case .attachments:
                        AttachmentPlaceholder()
                    case .imageMessage:
                        ImageMessagePlaceholder()
                    case .listPicker:
                        ListPickerPlaceholder()
                    case .quickReplies:
                        QuickRepliesPlaceholder()
                    case .richLink:
                        RichLinkPlaceholder()
                    case .selections:
                        SelectionsPlaceholder()
                    case .unspecified:
                        switch message.type {
                        case .participantChanged:
                            SystemMessage(text: "Participant changed")
                        case .typingIndicator:
                            TypingIndicator()
                        case .routingResult:
                            SystemMessage(text: "Routing result")
                        default:
                            SystemMessage(text: "System message")
                        }
                    case .webView:
                        WebViewPlaceholder()
                    case .textMessage:
                        if let textMessage = message.payload as? TextMessage {
                            TextMessageCell(text: textMessage.text, role: message.sender.role)
                        }
                    default:
                        SystemMessage(text: "Unhandled message type")
                    }
                }
            }
            .padding(.vertical, 8)
        }
        .background(F1Theme.chatLightBackground)
    }

    // MARK: - Text Message Cell
    
    private struct TextMessageCell: View {
        @State var text: String
        @State var role: ParticipantRole

        var body: some View {
            HStack(alignment: .top, spacing: 8) {
                if role == .agent || role == .chatbot {
                    // Agent Avatar
                    Circle()
                        .fill(F1Theme.salesforceBlue)
                        .frame(width: 36, height: 36)
                        .overlay(
                            Image("Salesforce_Logo")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 24, height: 24)
                        )
                    
                    // Agent Message Bubble
                    VStack(alignment: .leading, spacing: 4) {
                        Text(text)
                            .foregroundColor(F1Theme.textWhite)
                            .fixedSize(horizontal: false, vertical: true)
                        
                        // Text("Powered by Agentforce")
                        //     .font(.caption2)
                        //     .foregroundColor(F1Theme.placeholderGray)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(F1Theme.agentDarkBlue)
                    .cornerRadius(18, corners: [.topRight, .bottomLeft, .bottomRight])
                    .frame(maxWidth: 280, alignment: .leading)
                    
                    Spacer()
                } else if role == .user {
                    Spacer()
                    
                    // User Message Bubble (dark gray like in web screenshot)
                    Text(text)
                        .foregroundColor(F1Theme.textWhite)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(F1Theme.userDarkGray)
                        .cornerRadius(18, corners: [.topLeft, .bottomLeft, .bottomRight])
                        .frame(maxWidth: 280, alignment: .trailing)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    // User Avatar (optional)
                    Circle()
                        .fill(F1Theme.borderGray)
                        .frame(width: 36, height: 36)
                        .overlay(
                            Image(systemName: "person.fill")
                                .foregroundColor(F1Theme.textWhite)
                                .font(.system(size: 18))
                        )
                } else {
                    // System messages
                    Text(text)
                        .font(.caption)
                        .foregroundColor(F1Theme.placeholderGray)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.vertical, 4)
                }
            }
            .padding(.horizontal, 12)
        }
    }
    
    // MARK: - Placeholder Views for Unimplemented Message Types
    
    private struct AttachmentPlaceholder: View {
        var body: some View {
            HStack {
                Circle()
                    .fill(F1Theme.salesforceBlue)
                    .frame(width: 36, height: 36)
                    .overlay(
                        Image(systemName: "cloud.fill")
                            .foregroundColor(F1Theme.textWhite)
                    )
                
                Text("📎 Attachment")
                    .foregroundColor(F1Theme.textWhite)
                    .padding()
                    .background(F1Theme.agentDarkBlue)
                    .cornerRadius(18, corners: [.topRight, .bottomLeft, .bottomRight])
                
                Spacer()
            }
            .padding(.horizontal, 12)
        }
    }
    
    private struct ImageMessagePlaceholder: View {
        var body: some View {
            HStack {
                Circle()
                    .fill(F1Theme.salesforceBlue)
                    .frame(width: 36, height: 36)
                    .overlay(
                        Image(systemName: "cloud.fill")
                            .foregroundColor(F1Theme.textWhite)
                    )
                
                VStack {
                    Rectangle()
                        .fill(F1Theme.borderGray)
                        .frame(width: 200, height: 150)
                        .cornerRadius(12)
                        .overlay(
                            Image(systemName: "photo")
                                .foregroundColor(F1Theme.textWhite)
                                .font(.system(size: 40))
                        )
                }
                .padding()
                .background(F1Theme.agentDarkBlue)
                .cornerRadius(18, corners: [.topRight, .bottomLeft, .bottomRight])
                
                Spacer()
            }
            .padding(.horizontal, 12)
        }
    }
    
    private struct ListPickerPlaceholder: View {
        var body: some View {
            Text("List Picker - Not implemented")
                .foregroundColor(F1Theme.placeholderGray)
                .font(.caption)
        }
    }
    
    private struct QuickRepliesPlaceholder: View {
        var body: some View {
            Text("Quick Replies - Not implemented")
                .foregroundColor(F1Theme.placeholderGray)
                .font(.caption)
        }
    }
    
    private struct RichLinkPlaceholder: View {
        var body: some View {
            Text("Rich Link - Not implemented")
                .foregroundColor(F1Theme.placeholderGray)
                .font(.caption)
        }
    }
    
    private struct SelectionsPlaceholder: View {
        var body: some View {
            Text("Selections - Not implemented")
                .foregroundColor(F1Theme.placeholderGray)
                .font(.caption)
        }
    }
    
    private struct WebViewPlaceholder: View {
        var body: some View {
            Text("WebView - Not implemented")
                .foregroundColor(F1Theme.placeholderGray)
                .font(.caption)
        }
    }
    
    private struct SystemMessage: View {
        let text: String
        
        var body: some View {
            Text(text)
                .font(.caption)
                .foregroundColor(F1Theme.placeholderGray)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.vertical, 4)
        }
    }
    
    private struct TypingIndicator: View {
        var body: some View {
            HStack {
                Circle()
                    .fill(F1Theme.salesforceBlue)
                    .frame(width: 36, height: 36)
                    .overlay(
                        Image(systemName: "cloud.fill")
                            .foregroundColor(F1Theme.textWhite)
                    )
                
                HStack(spacing: 4) {
                    ForEach(0..<3) { _ in
                        Circle()
                            .fill(F1Theme.placeholderGray)
                            .frame(width: 8, height: 8)
                    }
                }
                .padding()
                .background(F1Theme.agentDarkBlue)
                .cornerRadius(18, corners: [.topRight, .bottomLeft, .bottomRight])
                
                Spacer()
            }
            .padding(.horizontal, 12)
        }
    }
}

// MARK: - Custom Corner Radius

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

// MARK: - Preview

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .preferredColorScheme(.dark)
    }
}

extension View {
    @ViewBuilder func isHidden(_ hidden: Bool, remove: Bool = false) -> some View {
        if hidden {
            if !remove {
                self.hidden()
            }
        } else {
            self
        }
    }
}
