import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var dataManager: DataManager
    @State private var showingResetAlert = false
    @State private var showingExportSheet = false
    @State private var showingImportSheet = false
    
    var body: some View {
        NavigationView {
            List {
                Section("Статистика") {
                    StatRow(title: "Персонажей", value: "\(dataManager.characters.count)")
                    StatRow(title: "Заклинаний", value: "\(dataManager.spells.count)")
                    StatRow(title: "Цитат", value: "\(dataManager.quotes.count)")
                    StatRow(title: "Избранных цитат", value: "\(dataManager.quotes.filter { $0.isFavorite }.count)")
                }
                
                Section("Данные") {
                    Button(action: {
                        showingExportSheet = true
                    }) {
                        HStack {
                            Image(systemName: "square.and.arrow.up")
                                .foregroundColor(.blue)
                            Text("Экспорт данных")
                            Spacer()
                        }
                    }
                    
                    Button(action: {
                        showingImportSheet = true
                    }) {
                        HStack {
                            Image(systemName: "square.and.arrow.down")
                                .foregroundColor(.green)
                            Text("Импорт данных")
                            Spacer()
                        }
                    }
                    
                    Button(action: {
                        showingResetAlert = true
                    }) {
                        HStack {
                            Image(systemName: "trash")
                                .foregroundColor(.red)
                            Text("Сбросить все данные")
                            Spacer()
                        }
                    }
                }
                
                Section("О приложении") {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("D&D Companion")
                            .font(.headline)
                        
                        Text("Версия 1.0.0")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text("Приложение для игроков в Dungeons & Dragons")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 4)
                }
                
                Section("Функции") {
                    FeatureRow(
                        icon: "quote.bubble",
                        title: "Цитаты",
                        description: "Рандомные цитаты по категориям с возможностью добавления"
                    )
                    
                    FeatureRow(
                        icon: "person.3",
                        title: "Персонажи",
                        description: "Управление персонажами и их отношениями"
                    )
                    
                    FeatureRow(
                        icon: "dice",
                        title: "Кости",
                        description: "Броски костей с настройкой и историей"
                    )
                    
                    FeatureRow(
                        icon: "sparkles",
                        title: "Заклинания",
                        description: "База заклинаний с поиском и фильтрацией"
                    )
                }
            }
            .navigationTitle("Настройки")
            .navigationBarTitleDisplayMode(.large)
            .alert("Сбросить данные", isPresented: $showingResetAlert) {
                Button("Отмена", role: .cancel) { }
                Button("Сбросить", role: .destructive) {
                    resetAllData()
                }
            } message: {
                Text("Это действие удалит все персонажи, заклинания и цитаты. Это действие нельзя отменить.")
            }
            .sheet(isPresented: $showingExportSheet) {
                ExportView()
            }
            .sheet(isPresented: $showingImportSheet) {
                ImportView()
                    .environmentObject(dataManager)
            }
        }
    }
    
    private func resetAllData() {
        dataManager.characters.removeAll()
        dataManager.spells.removeAll()
        dataManager.quotes.removeAll()
        
        // Reload default data
        dataManager.loadQuotes()
        dataManager.loadSpells()
    }
}

struct StatRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .foregroundColor(.primary)
            Spacer()
            Text(value)
                .fontWeight(.semibold)
                .foregroundColor(.orange)
        }
    }
}

struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.orange)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding(.vertical, 4)
    }
}

struct ExportView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var dataManager: DataManager
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Image(systemName: "square.and.arrow.up")
                    .font(.system(size: 60))
                    .foregroundColor(.blue)
                
                Text("Экспорт данных")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("Экспортируйте все ваши данные в JSON формате для резервного копирования или переноса на другое устройство.")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                VStack(spacing: 12) {
                    ExportButton(title: "Экспортировать персонажей", action: exportCharacters)
                    ExportButton(title: "Экспортировать заклинания", action: exportSpells)
                    ExportButton(title: "Экспортировать цитаты", action: exportQuotes)
                    ExportButton(title: "Экспортировать все данные", action: exportAll)
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("Экспорт")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Закрыть") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func exportCharacters() {
        // Implementation for exporting characters
        print("Exporting characters...")
    }
    
    private func exportSpells() {
        // Implementation for exporting spells
        print("Exporting spells...")
    }
    
    private func exportQuotes() {
        // Implementation for exporting quotes
        print("Exporting quotes...")
    }
    
    private func exportAll() {
        // Implementation for exporting all data
        print("Exporting all data...")
    }
}

struct ImportView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var dataManager: DataManager
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Image(systemName: "square.and.arrow.down")
                    .font(.system(size: 60))
                    .foregroundColor(.green)
                
                Text("Импорт данных")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("Импортируйте данные из JSON файла. Убедитесь, что файл соответствует формату приложения.")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                VStack(spacing: 12) {
                    ImportButton(title: "Импортировать персонажей", action: importCharacters)
                    ImportButton(title: "Импортировать заклинания", action: importSpells)
                    ImportButton(title: "Импортировать цитаты", action: importQuotes)
                    ImportButton(title: "Импортировать все данные", action: importAll)
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("Импорт")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Закрыть") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func importCharacters() {
        // Implementation for importing characters
        print("Importing characters...")
    }
    
    private func importSpells() {
        // Implementation for importing spells
        print("Importing spells...")
    }
    
    private func importQuotes() {
        // Implementation for importing quotes
        print("Importing quotes...")
    }
    
    private func importAll() {
        // Implementation for importing all data
        print("Importing all data...")
    }
}

struct ExportButton: View {
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: "square.and.arrow.up")
                    .foregroundColor(.blue)
                Text(title)
                    .foregroundColor(.primary)
                Spacer()
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(10)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct ImportButton: View {
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: "square.and.arrow.down")
                    .foregroundColor(.green)
                Text(title)
                    .foregroundColor(.primary)
                Spacer()
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(10)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    SettingsView()
        .environmentObject(DataManager())
}
