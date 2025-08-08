import SwiftUI

struct DiceView: View {
    @EnvironmentObject var dataManager: DataManager
    @State private var selectedDice = Dice(sides: 20, count: 1, modifier: 0)
    @State private var rollHistory: [DiceRoll] = []
    @State private var showingCustomDice = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Current Dice Display
                VStack(spacing: 12) {
                    Text("\(selectedDice.count)d\(selectedDice.sides)")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.orange)
                    
                    if selectedDice.modifier != 0 {
                        Text("Модификатор: \(selectedDice.modifier > 0 ? "+" : "")\(selectedDice.modifier)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(16)
                
                // Roll Button
                Button(action: rollDice) {
                    HStack {
                        Image(systemName: "dice.fill")
                            .font(.title2)
                        Text("Бросить кости")
                            .font(.headline)
                    }
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.orange)
                    .cornerRadius(12)
                }
                .padding(.horizontal)
                
                // Quick Dice Selection
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(quickDice, id: \.sides) { dice in
                            QuickDiceButton(dice: dice, isSelected: selectedDice.sides == dice.sides) {
                                selectedDice = dice
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                
                // Roll History
                if !rollHistory.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("История бросков")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        ScrollView {
                            LazyVStack(spacing: 8) {
                                ForEach(rollHistory) { roll in
                                    RollHistoryRow(roll: roll)
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                }
                
                Spacer()
            }
            .navigationTitle("Кости")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingCustomDice = true
                    }) {
                        Image(systemName: "slider.horizontal.3")
                    }
                }
            }
            .sheet(isPresented: $showingCustomDice) {
                CustomDiceView(selectedDice: $selectedDice)
            }
        }
    }
    
    private var quickDice: [Dice] {
        [
            Dice(sides: 4, count: 1, modifier: 0),
            Dice(sides: 6, count: 1, modifier: 0),
            Dice(sides: 8, count: 1, modifier: 0),
            Dice(sides: 10, count: 1, modifier: 0),
            Dice(sides: 12, count: 1, modifier: 0),
            Dice(sides: 20, count: 1, modifier: 0),
            Dice(sides: 100, count: 1, modifier: 0)
        ]
    }
    
    private func rollDice() {
        let result = selectedDice.roll()
        let roll = DiceRoll(
            dice: selectedDice,
            result: result,
            timestamp: Date()
        )
        rollHistory.insert(roll, at: 0)
        
        // Keep only last 20 rolls
        if rollHistory.count > 20 {
            rollHistory = Array(rollHistory.prefix(20))
        }
    }
}

struct QuickDiceButton: View {
    let dice: Dice
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Text("d\(dice.sides)")
                    .font(.headline)
                    .fontWeight(.bold)
                
                Text("\(dice.count)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
            .frame(width: 60, height: 60)
            .background(isSelected ? Color.orange : Color(.systemGray5))
            .foregroundColor(isSelected ? .white : .primary)
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct RollHistoryRow: View {
    let roll: DiceRoll
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("\(roll.dice.count)d\(roll.dice.sides)")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                if roll.dice.modifier != 0 {
                    Text("Модификатор: \(roll.dice.modifier > 0 ? "+" : "")\(roll.dice.modifier)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 2) {
                Text("\(roll.result)")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.orange)
                
                Text(roll.timestamp, style: .time)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}

struct CustomDiceView: View {
    @Binding var selectedDice: Dice
    @Environment(\.dismiss) var dismiss
    
    @State private var count = 1
    @State private var sides = 20
    @State private var modifier = 0
    
    var body: some View {
        NavigationView {
            Form {
                Section("Количество костей") {
                    Stepper("Количество: \(count)", value: $count, in: 1...10)
                }
                
                Section("Стороны кости") {
                    Picker("Стороны", selection: $sides) {
                        ForEach([4, 6, 8, 10, 12, 20, 100], id: \.self) { side in
                            Text("d\(side)").tag(side)
                        }
                    }
                    .pickerStyle(WheelPickerStyle())
                }
                
                Section("Модификатор") {
                    Stepper("Модификатор: \(modifier)", value: $modifier, in: -10...10)
                }
                
                Section("Предварительный просмотр") {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("\(count)d\(sides)")
                            .font(.headline)
                        
                        if modifier != 0 {
                            Text("Модификатор: \(modifier > 0 ? "+" : "")\(modifier)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Text("Диапазон: \(count + modifier) - \(count * sides + modifier)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Настройка костей")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Отмена") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Применить") {
                        selectedDice = Dice(sides: sides, count: count, modifier: modifier)
                        dismiss()
                    }
                }
            }
            .onAppear {
                count = selectedDice.count
                sides = selectedDice.sides
                modifier = selectedDice.modifier
            }
        }
    }
}

struct DiceRoll: Identifiable {
    let id = UUID()
    let dice: Dice
    let result: Int
    let timestamp: Date
}

#Preview {
    DiceView()
        .environmentObject(DataManager())
}
