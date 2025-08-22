import SwiftUI

// MARK: - Enhanced Rich Text Editor
struct EnhancedRichTextEditor: View {
    @Binding var text: String
    let placeholder: String
    @Environment(\.dismiss) private var dismiss
    @State private var editedText: String
    @State private var selectedRange: NSRange = NSRange(location: 0, length: 0)
    @State private var showingFormatToolbar = true
    
    init(text: Binding<String>, placeholder: String) {
        self._text = text
        self.placeholder = placeholder
        self._editedText = State(initialValue: text.wrappedValue)
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Main Toolbar
                HStack {
                    Button("Отмена") {
                        dismiss()
                    }
                    .foregroundColor(.red)
                    
                    Spacer()
                    
                    Text("Редактор")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Spacer()
                    
                    Button("Сохранить") {
                        text = editedText
                        dismiss()
                    }
                    .fontWeight(.semibold)
                    .foregroundColor(.blue)
                }
                .padding()
                .background(Color(.systemGray6))
                
                // Format Toolbar
                if showingFormatToolbar {
                    FormatToolbar(text: $editedText, selectedRange: $selectedRange)
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                        .background(Color(.systemGray5))
                }
                
                // Text Editor
                VStack(spacing: 0) {
                    // Character count
                    HStack {
                        Spacer()
                        Text("\(editedText.count) символов")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.horizontal)
                    }
                    .padding(.vertical, 4)
                    .background(Color(.systemGray6))
                    
                    // Main editor
                    TextEditor(text: $editedText)
                        .font(.body)
                        .padding()
                        .background(Color(.systemBackground))
                        .overlay(
                            Group {
                                if editedText.isEmpty {
                                    VStack {
                                        HStack {
                                            Text(placeholder)
                                                .foregroundColor(.secondary)
                                                .font(.body)
                                            Spacer()
                                        }
                                        Spacer()
                                    }
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 20)
                                }
                            }
                        )
                }
            }
        }
        .navigationBarHidden(true)
    }
}

// MARK: - Format Toolbar
struct FormatToolbar: View {
    @Binding var text: String
    @Binding var selectedRange: NSRange
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                // Bold
                FormatButton(
                    icon: "bold",
                    action: { insertFormat("**", "**") }
                )
                
                // Italic
                FormatButton(
                    icon: "italic",
                    action: { insertFormat("*", "*") }
                )
                
                // Bold Italic
                FormatButton(
                    icon: "textformat.abc.dottedunderline",
                    action: { insertFormat("***", "***") }
                )
                
                // Strikethrough
                FormatButton(
                    icon: "strikethrough",
                    action: { insertFormat("~~", "~~") }
                )
                
                // Highlight
                FormatButton(
                    icon: "highlighter",
                    action: { insertFormat("==", "==") }
                )
                
                Divider()
                    .frame(height: 20)
                
                // List
                FormatButton(
                    icon: "list.bullet",
                    action: { insertAtLineStart("- ") }
                )
                
                // Numbered List
                FormatButton(
                    icon: "list.number",
                    action: { insertAtLineStart("1. ") }
                )
                
                Divider()
                    .frame(height: 20)
                
                // Clear formatting
                FormatButton(
                    icon: "textformat.clear",
                    action: clearFormatting
                )
            }
            .padding(.horizontal)
        }
    }
    
    private func insertFormat(_ prefix: String, _ suffix: String) {
        if selectedRange.length > 0 {
            // Если есть выделенный текст, оборачиваем его
            let start = text.index(text.startIndex, offsetBy: selectedRange.location)
            let end = text.index(start, offsetBy: selectedRange.length)
            let selectedText = String(text[start..<end])
            let replacement = prefix + selectedText + suffix
            text.replaceSubrange(start..<end, with: replacement)
        } else {
            // Если нет выделения, вставляем в текущую позицию
            let insertIndex = text.index(text.startIndex, offsetBy: selectedRange.location)
            text.insert(contentsOf: prefix + suffix, at: insertIndex)
        }
    }
    
    private func insertAtLineStart(_ prefix: String) {
        let lines = text.components(separatedBy: .newlines)
        var newLines: [String] = []
        
        for (index, line) in lines.enumerated() {
            if index == selectedRange.location {
                newLines.append(prefix + line)
            } else {
                newLines.append(line)
            }
        }
        
        text = newLines.joined(separator: "\n")
    }
    
    private func clearFormatting() {
        // Удаляем все markdown форматирование
        text = text.replacingOccurrences(of: "\\*\\*\\*(.*?)\\*\\*\\*", with: "$1", options: .regularExpression)
        text = text.replacingOccurrences(of: "\\*\\*(.*?)\\*\\*", with: "$1", options: .regularExpression)
        text = text.replacingOccurrences(of: "\\*(.*?)\\*", with: "$1", options: .regularExpression)
        text = text.replacingOccurrences(of: "~~(.*?)~~", with: "$1", options: .regularExpression)
        text = text.replacingOccurrences(of: "==(.*?)==", with: "$1", options: .regularExpression)
    }
}

// MARK: - Format Button
struct FormatButton: View {
    let icon: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.primary)
                .frame(width: 32, height: 32)
                .background(
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color(.systemGray6))
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Enhanced Rich Text Field
struct EnhancedRichTextField: View {
    @Binding var text: String
    let placeholder: String
    @State private var showingEditor = false
    
    var body: some View {
        Button(action: {
            showingEditor = true
        }) {
            VStack(alignment: .leading, spacing: 8) {
                if text.isEmpty {
                    Text(placeholder)
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.leading)
                        .lineLimit(3)
                } else {
                    Text(text.parseMarkdown())
                        .font(.body)
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.leading)
                        .lineLimit(3)
                }
                
                HStack {
                    Spacer()
                    Image(systemName: "pencil.circle")
                        .foregroundColor(.blue)
                        .font(.caption)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemGray6))
            )
        }
        .buttonStyle(PlainButtonStyle())
        .sheet(isPresented: $showingEditor) {
            EnhancedRichTextEditor(text: $text, placeholder: placeholder)
        }
    }
}

// MARK: - Inline Rich Text Editor
struct InlineRichTextEditor: View {
    @Binding var text: String
    let placeholder: String
    @State private var isEditing = false
    @State private var editedText: String
    @FocusState private var isFocused: Bool
    
    init(text: Binding<String>, placeholder: String) {
        self._text = text
        self.placeholder = placeholder
        self._editedText = State(initialValue: text.wrappedValue)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if isEditing {
                // Editing mode
                VStack(spacing: 8) {
                    // Format toolbar
                    FormatToolbar(text: $editedText, selectedRange: .constant(NSRange()))
                        .padding(.horizontal)
                        .padding(.vertical, 4)
                        .background(Color(.systemGray5))
                        .cornerRadius(8)
                    
                    // Text editor
                    TextEditor(text: $editedText)
                        .font(.body)
                        .padding(8)
                        .background(Color(.systemBackground))
                        .cornerRadius(8)
                        .frame(minHeight: 100)
                        .focused($isFocused)
                    
                    // Action buttons
                    HStack {
                        Button("Отмена") {
                            editedText = text
                            isEditing = false
                            isFocused = false
                        }
                        .foregroundColor(.red)
                        
                        Spacer()
                        
                        Button("Сохранить") {
                            text = editedText
                            isEditing = false
                            isFocused = false
                        }
                        .foregroundColor(.blue)
                        .fontWeight(.semibold)
                    }
                    .padding(.horizontal)
                }
            } else {
                // Display mode
                Button(action: {
                    editedText = text
                    isEditing = true
                    isFocused = true
                }) {
                    VStack(alignment: .leading, spacing: 8) {
                        if text.isEmpty {
                            Text(placeholder)
                                .font(.body)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.leading)
                                .lineLimit(3)
                        } else {
                            Text(text.parseMarkdown())
                                .font(.body)
                                .foregroundColor(.primary)
                                .multilineTextAlignment(.leading)
                                .lineLimit(3)
                        }
                        
                        HStack {
                            Spacer()
                            Image(systemName: "pencil.circle")
                                .foregroundColor(.blue)
                                .font(.caption)
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(.systemGray6))
                    )
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
    }
}

