//
//  ContentView.swift
//  dnd_app
//
//  Created by Alexander Aferenok on 08.08.2025.
//

import SwiftUI

struct SimpleQuotesView: View {
    var body: some View {
        NavigationView {
            VStack {
                Text("🎲 D&D Цитаты")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.orange)
                
                Text("Приключения ждут тех, кто готов их искать.")
                    .font(.title2)
                    .multilineTextAlignment(.center)
                    .padding()
                
                Text("— Древняя мудрость")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
            }
            .navigationTitle("Цитаты")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

struct SimpleCharactersView: View {
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("👥 Персонажи D&D")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.orange)
                
                VStack(spacing: 16) {
                    HStack {
                        Circle()
                            .fill(Color.orange)
                            .frame(width: 60, height: 60)
                            .overlay(
                                Text("Г")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                            )
                        
                        VStack(alignment: .leading) {
                            Text("Гэндальф")
                                .font(.headline)
                            Text("Майя • Волшебник 5 уровня")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        HStack(spacing: 2) {
                            ForEach(1...4, id: \.self) { _ in
                                Image(systemName: "heart.fill")
                                    .foregroundColor(.red)
                                    .font(.caption)
                            }
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                }
                
                Spacer()
            }
            .navigationTitle("Персонажи")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

struct SimpleDiceView: View {
    @State private var diceResult = 0
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                Text("🎲 Кости D&D")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.orange)
                
                VStack {
                    Text("d20")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text("\(diceResult)")
                        .font(.system(size: 60, weight: .bold))
                        .foregroundColor(.orange)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(16)
                }
                
                Button(action: {
                    diceResult = Int.random(in: 1...20)
                }) {
                    HStack {
                        Image(systemName: "dice.fill")
                        Text("Бросить кости")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.orange)
                    .cornerRadius(12)
                }
                
                Spacer()
            }
            .navigationTitle("Кости")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

struct ContentView: View {
    var body: some View {
        TabView {
            SimpleQuotesView()
                .tabItem {
                    Image(systemName: "quote.bubble")
                    Text("Цитаты")
                }
            
            SimpleCharactersView()
                .tabItem {
                    Image(systemName: "person.3")
                    Text("Персонажи")
                }
            
            SimpleDiceView()
                .tabItem {
                    Image(systemName: "dice")
                    Text("Кости")
                }
            
            Text("Заклинания")
                .tabItem {
                    Image(systemName: "sparkles")
                    Text("Заклинания")
                }
            
            Text("Настройки")
                .tabItem {
                    Image(systemName: "gear")
                    Text("Настройки")
                }
        }
        .accentColor(.orange)
    }
}

#Preview {
    ContentView()
}
