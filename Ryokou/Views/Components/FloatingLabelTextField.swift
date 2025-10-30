//
//  FloatingLabelTextField.swift
//  Ryokou
//
//  Created by Thiha Ye Yint Aung on 10/30/25.
//

import SwiftUI

struct FloatingLabelTextField: View {
    let label: String
    var isSecure: Bool = false
    var keyboard: UIKeyboardType = .default
    var submitLabel: SubmitLabel = .done
    var isEnabled: Bool = true
    
    @Binding var text: String
    @FocusState private var focused: Bool
    
    init(_ label: String,
         text: Binding<String>,
         keyboard: UIKeyboardType = .default,
         isEnabled: Bool = true,
         submitLabel: SubmitLabel = .done) {
        self.label = label
        self._text = text
        self.keyboard = keyboard
        self.submitLabel = submitLabel
        self.isEnabled = isEnabled
    }
    
    private let corner: CGFloat = 12
    private let topLift: CGFloat = 18
    
    var body: some View {
        ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: corner)
                .fill(.ultraThinMaterial)
            
            Group {
                if isSecure {
                    SecureField("", text: $text)
                        .focused($focused)
                } else {
                    TextField("", text: $text)
                        .focused($focused)
                }
            }
            .keyboardType(keyboard)
            .submitLabel(submitLabel)
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .padding(.top, 8)
            .disabled(!isEnabled)
            .opacity(isEnabled ? 1 : 0.75)
            
            Text(label)
                .foregroundStyle(.secondary)
                .background(Color.clear)
                .scaleEffect(
                    (focused || !text.isEmpty) ? 0.82 : 1,
                    anchor: .leading
                )
                .offset(y: (focused || !text.isEmpty) ? -topLift : 0)
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
                .allowsHitTesting(false)
        }
        .overlay {
            RoundedRectangle(cornerRadius: corner)
                .stroke(focused ? Color.yellow.opacity(0.5) : Color.secondary.opacity(0.25), lineWidth: focused ? 1.5 : 1)
        }
        .animation(.easeOut(duration: 0.18), value: focused || !text.isEmpty)
    }
}

#Preview {
    @Previewable @State var first = ""
    @Previewable @State var last  = ""
    @Previewable @State var email = ""
    
    VStack(spacing: 16) {
        FloatingLabelTextField("First Name", text: $first)
        FloatingLabelTextField("Last Name",  text: $last)
        FloatingLabelTextField("Email", text: $email, keyboard: .emailAddress, submitLabel: .next)
    }
    .padding()
}
