import SwiftUI

struct SettingsView: View {
    @ObservedObject var themeManager: ThemeManager
    
    var body: some View {
        NavigationStack {
            ZStack {
                ThemeManager.adaptiveBackground(for: themeManager.isDarkMode)
                    .ignoresSafeArea()
                
                VStack(spacing: 20) {
                    // Заголовок
                    VStack(spacing: 8) {
                        Image(systemName: "gearshape.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.orange)
                        
                        Text("Настройки")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(ThemeManager.adaptiveTextColor(for: themeManager.isDarkMode))
                    }
                    
                    // Настройки
                    VStack(spacing: 16) {
                        // Переключение темы
                        HStack {
                            Image(systemName: themeManager.isDarkMode ? "moon.fill" : "sun.max.fill")
                                .foregroundColor(.orange)
                                .font(.title2)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Тема приложения")
                                    .font(.headline)
                                    .foregroundColor(ThemeManager.adaptiveTextColor(for: themeManager.isDarkMode))
                                
                                Text(themeManager.isDarkMode ? "Темная тема" : "Светлая тема")
                                    .font(.caption)
                                    .foregroundColor(ThemeManager.adaptiveSecondaryTextColor(for: themeManager.isDarkMode))
                            }
                            
                            Spacer()
                            
                            Toggle("", isOn: $themeManager.isDarkMode)
                                .toggleStyle(SwitchToggleStyle(tint: .orange))
                        }
                        .padding()
                        .background(ThemeManager.adaptiveCardBackground(for: themeManager.isDarkMode))
                        .cornerRadius(12)
                        
                        // Информация о приложении
                        VStack(spacing: 12) {
                            HStack {
                                Image(systemName: "info.circle.fill")
                                    .foregroundColor(.blue)
                                
                                Text("О приложении")
                                    .font(.headline)
                                    .foregroundColor(ThemeManager.adaptiveTextColor(for: themeManager.isDarkMode))
                                
                                Spacer()
                            }
                            
                            VStack(alignment: .leading, spacing: 8) {
                                InfoRow(title: "Версия", value: "1.0.0")
                                InfoRow(title: "Разработчик", value: "ndrsh01")
                                InfoRow(title: "Платформа", value: "iOS 15.0+")
                            }
                        }
                        .padding()
                        .background(ThemeManager.adaptiveCardBackground(for: themeManager.isDarkMode))
                        .cornerRadius(12)
                        
                        // Статистика
                        VStack(spacing: 12) {
                            HStack {
                                Image(systemName: "chart.bar.fill")
                                    .foregroundColor(.green)
                                
                                Text("Статистика")
                                    .font(.headline)
                                    .foregroundColor(ThemeManager.adaptiveTextColor(for: themeManager.isDarkMode))
                                
                                Spacer()
                            }
                            
                            VStack(alignment: .leading, spacing: 8) {
                                InfoRow(title: "Заклинаний", value: "500+")
                                InfoRow(title: "Заметок", value: "Безлимитно")
                                InfoRow(title: "Персонажей", value: "10+")
                            }
                        }
                        .padding()
                        .background(ThemeManager.adaptiveCardBackground(for: themeManager.isDarkMode))
                        .cornerRadius(12)
                    }
                    .padding(.horizontal)
                    
                    Spacer()
                }
                .padding(.top, 30)
            }
            .navigationTitle("Настройки")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

struct InfoRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.body)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text(value)
                .font(.body)
                .fontWeight(.medium)
        }
    }
}
