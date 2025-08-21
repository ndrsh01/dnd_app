import SwiftUI

struct RichTextEditor: View {
    @Binding var text: String
    let placeholder: String
    @Environment(\.dismiss) private var dismiss
    @State private var editedText: String
    
    init(text: Binding<String>, placeholder: String) {
        self._text = text
        self.placeholder = placeholder
        self._editedText = State(initialValue: text.wrappedValue)
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Toolbar
                HStack {
                    Button("Отмена") {
                        dismiss()
                    }
                    
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
                
                // Text Editor
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
        .navigationBarHidden(true)
    }
}

// Rich Text Field Component
struct RichTextField: View {
    @Binding var text: String
    let placeholder: String
    @State private var showingEditor = false
    
    var body: some View {
        Button(action: {
            showingEditor = true
        }) {
            VStack(alignment: .leading, spacing: 8) {
                Text(text.isEmpty ? placeholder : text)
                    .font(.body)
                    .foregroundColor(text.isEmpty ? .secondary : .primary)
                    .multilineTextAlignment(.leading)
                    .lineLimit(3)
                
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
            RichTextEditor(text: $text, placeholder: placeholder)
        }
    }
}
