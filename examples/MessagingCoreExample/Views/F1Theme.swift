//
//  F1Theme.swift
//  MessagingCoreExample
//
//  F1 RaceFan Agent Theme Colors and Styling
//

import SwiftUI

// MARK: - F1 Theme Colors

struct F1Theme {
    
    // MARK: Primary Brand Colors
    
    /// F1 Red - Used for navigation header
    static let f1Red = Color(red: 224/255, green: 28/255, blue: 36/255)
    
    /// Salesforce Blue - Used for user messages and CTAs
    static let salesforceBlue = Color(red: 0/255, green: 122/255, blue: 204/255)
    
    /// Pure Black - Main chat background
    static let chatBlack = Color.black
    
    /// Dark Blue - Agent message bubbles (matching web interface)
    static let agentDarkBlue = Color(red: 3/255, green: 45/255, blue: 96/255)
    
    /// User Message Dark Gray - User message bubbles (matching web interface)
    static let userDarkGray = Color(red: 58/255, green: 58/255, blue: 58/255)
    
    /// Pure White - Text on colored backgrounds
    static let textWhite = Color.white
    
    /// Light Background - Chat message area background
    static let chatLightBackground = Color(red: 245/255, green: 245/255, blue: 245/255)
    
    // MARK: Secondary Colors
    
    /// Light Gray - Borders and separators
    static let borderGray = Color(red: 100/255, green: 100/255, blue: 100/255)
    
    /// Input Background - Slightly lighter than agent gray
    static let inputBackground = Color(red: 40/255, green: 40/255, blue: 40/255)
    
    /// Placeholder Text - Dim gray for placeholder text
    static let placeholderGray = Color(red: 150/255, green: 150/255, blue: 150/255)
    
    // MARK: Status Colors
    
    /// Success Green - For positive status
    static let successGreen = Color(red: 4/255, green: 132/255, blue: 75/255)
    
    /// Error Red - For error states
    static let errorRed = Color(red: 166/255, green: 26/255, blue: 20/255)
    
    // MARK: Hex Initializers (Alternative)
    
    struct Hex {
        static let f1Red = Color(hex: "E01C24")
        static let salesforceBlue = Color(hex: "007ACC")
        static let agentDarkBlue = Color(hex: "032D60")
        static let userDarkGray = Color(hex: "3A3A3A")
        static let inputBackground = Color(hex: "282828")
        static let chatLightBackground = Color(hex: "F5F5F5")
    }
}

// MARK: - Color Extension for Hex Support

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Message Bubble Styles

struct MessageBubbleStyle {
    
    /// User message bubble styling
    static func userBubble() -> some ViewModifier {
        MessageBubbleModifier(
            backgroundColor: F1Theme.userDarkGray,
            textColor: F1Theme.textWhite,
            alignment: .trailing
        )
    }
    
    /// Agent/Bot message bubble styling
    static func agentBubble() -> some ViewModifier {
        MessageBubbleModifier(
            backgroundColor: F1Theme.agentDarkBlue,
            textColor: F1Theme.textWhite,
            alignment: .leading
        )
    }
}

struct MessageBubbleModifier: ViewModifier {
    let backgroundColor: Color
    let textColor: Color
    let alignment: Alignment
    
    func body(content: Content) -> some View {
        content
            .foregroundColor(textColor)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(backgroundColor)
            .cornerRadius(18)
            .frame(maxWidth: .infinity, alignment: alignment)
            .padding(.horizontal, 12)
            .padding(.vertical, 4)
    }
}

// MARK: - View Extensions for Easy Styling

extension View {
    /// Apply F1 user message bubble style
    func userMessageStyle() -> some View {
        self.modifier(MessageBubbleModifier(
            backgroundColor: F1Theme.userDarkGray,
            textColor: F1Theme.textWhite,
            alignment: .trailing
        ))
    }
    
    /// Apply F1 agent message bubble style
    func agentMessageStyle() -> some View {
        self.modifier(MessageBubbleModifier(
            backgroundColor: F1Theme.agentDarkBlue,
            textColor: F1Theme.textWhite,
            alignment: .leading
        ))
    }
}

// MARK: - Button Styles

struct F1ButtonStyle: ButtonStyle {
    var backgroundColor: Color = F1Theme.salesforceBlue
    var foregroundColor: Color = F1Theme.textWhite
    var isDisabled: Bool = false
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(isDisabled ? F1Theme.borderGray : backgroundColor)
            .foregroundColor(foregroundColor)
            .cornerRadius(8)
            .opacity(configuration.isPressed ? 0.8 : 1.0)
    }
}

struct F1PrimaryButton: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundColor(F1Theme.textWhite)
            .padding(.horizontal, 24)
            .padding(.vertical, 14)
            .background(F1Theme.salesforceBlue)
            .cornerRadius(10)
            .opacity(configuration.isPressed ? 0.7 : 1.0)
    }
}

struct F1SecondaryButton: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundColor(F1Theme.salesforceBlue)
            .padding(.horizontal, 24)
            .padding(.vertical, 14)
            .background(F1Theme.textWhite)
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(F1Theme.salesforceBlue, lineWidth: 2)
            )
            .opacity(configuration.isPressed ? 0.7 : 1.0)
    }
}

// MARK: - Text Field Styles

struct F1TextFieldStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding()
            .background(F1Theme.inputBackground)
            .foregroundColor(F1Theme.textWhite)
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(F1Theme.borderGray, lineWidth: 1)
            )
    }
}

extension View {
    /// Apply F1 text field styling
    func f1TextFieldStyle() -> some View {
        self.modifier(F1TextFieldStyle())
    }
}
