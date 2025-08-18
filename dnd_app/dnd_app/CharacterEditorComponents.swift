import SwiftUI

// MARK: - Section Components for Character Editor

struct BasicInfoSection: View {
    @Binding var character: Character
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 8) {
                ZStack {
                    Circle().fill(Color.orange.opacity(0.2)).frame(width: 28, height: 28)
                    Image(systemName: "person.circle").foregroundColor(.orange).font(.caption)
                }
                Text("Основная информация").font(.headline).fontWeight(.semibold)
            }
            
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 150), spacing: 12)], spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Имя персонажа")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    TextField("Введите имя", text: $character.name)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Имя игрока")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    TextField("Введите имя игрока", text: $character.playerName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Раса")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    TextField("Введите расу", text: $character.race)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Предыстория")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    TextField("Введите предысторию", text: $character.background)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Мировоззрение")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    TextField("Введите мировоззрение", text: $character.alignment)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Опыт")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    TextField("Введите опыт", value: $character.experience, format: .number)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.numberPad)
                }
            }
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(LinearGradient(colors: [Color(.systemBackground), Color(.systemBackground).opacity(0.95)], startPoint: .topLeading, endPoint: .bottomTrailing))
                .stroke(LinearGradient(colors: [.orange.opacity(0.3), .orange.opacity(0.1)], startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 1.5)
                .shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: 6)
        )
    }
}

struct CombatStatsSection: View {
    @Binding var character: Character
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 8) {
                ZStack {
                    Circle().fill(Color.red.opacity(0.2)).frame(width: 28, height: 28)
                    Image(systemName: "shield.fill").foregroundColor(.red).font(.caption)
                }
                Text("Боевые характеристики").font(.headline).fontWeight(.semibold)
            }
            
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 150), spacing: 12)], spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Класс брони (КЗ)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    TextField("КЗ", value: $character.armorClass, format: .number)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.numberPad)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Максимум хитов")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    TextField("Макс. хиты", value: $character.maxHitPoints, format: .number)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.numberPad)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Текущие хиты")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    TextField("Текущие хиты", value: $character.currentHitPoints, format: .number)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.numberPad)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Инициатива")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    TextField("Инициатива", value: $character.initiative, format: .number)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.numberPad)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Скорость")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    TextField("Скорость", value: $character.speed, format: .number)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.numberPad)
                }
            }
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(LinearGradient(colors: [Color(.systemBackground), Color(.systemBackground).opacity(0.95)], startPoint: .topLeading, endPoint: .bottomTrailing))
                .stroke(LinearGradient(colors: [.red.opacity(0.3), .red.opacity(0.1)], startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 1.5)
                .shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: 6)
        )
    }
}

struct AbilityScoresSection: View {
    @Binding var character: Character
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 8) {
                ZStack {
                    Circle().fill(Color.purple.opacity(0.2)).frame(width: 28, height: 28)
                    Image(systemName: "sparkles").foregroundColor(.purple).font(.caption)
                }
                Text("Характеристики").font(.headline).fontWeight(.semibold)
            }
            
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 100), spacing: 12)], spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Сила")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    TextField("10", value: $character.strength, format: .number)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.numberPad)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Ловкость")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    TextField("10", value: $character.dexterity, format: .number)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.numberPad)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Телосложение")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    TextField("10", value: $character.constitution, format: .number)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.numberPad)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Интеллект")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    TextField("10", value: $character.intelligence, format: .number)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.numberPad)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Мудрость")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    TextField("10", value: $character.wisdom, format: .number)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.numberPad)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Харизма")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    TextField("10", value: $character.charisma, format: .number)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.numberPad)
                }
            }
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(LinearGradient(colors: [Color(.systemBackground), Color(.systemBackground).opacity(0.95)], startPoint: .topLeading, endPoint: .bottomTrailing))
                .stroke(LinearGradient(colors: [.purple.opacity(0.3), .purple.opacity(0.1)], startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 1.5)
                .shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: 6)
        )
    }
}

struct SkillsSection: View {
    @Binding var character: Character
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 8) {
                ZStack {
                    Circle().fill(Color.green.opacity(0.2)).frame(width: 28, height: 28)
                    Image(systemName: "brain.head.profile").foregroundColor(.green).font(.caption)
                }
                Text("Навыки").font(.headline).fontWeight(.semibold)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Прочие владения и языки")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                TextField("Введите владения и языки", text: $character.otherProficiencies, axis: .vertical)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .lineLimit(3...6)
            }
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(LinearGradient(colors: [Color(.systemBackground), Color(.systemBackground).opacity(0.95)], startPoint: .topLeading, endPoint: .bottomTrailing))
                .stroke(LinearGradient(colors: [.green.opacity(0.3), .green.opacity(0.1)], startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 1.5)
                .shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: 6)
        )
    }
}

struct PersonalitySection: View {
    @Binding var character: Character
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Черты характера")
                .font(.headline)
                .fontWeight(.semibold)
            
            VStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Черты характера")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    TextField("Опишите черты характера", text: $character.personalityTraits, axis: .vertical)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .lineLimit(2...4)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Идеалы")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    TextField("Опишите идеалы", text: $character.ideals, axis: .vertical)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .lineLimit(2...4)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Привязанности")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    TextField("Опишите привязанности", text: $character.bonds, axis: .vertical)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .lineLimit(2...4)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Слабости")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    TextField("Опишите слабости", text: $character.flaws, axis: .vertical)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .lineLimit(2...4)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }
}

struct EquipmentSection: View {
    @Binding var character: Character
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Снаряжение и способности")
                .font(.headline)
                .fontWeight(.semibold)
            
            VStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Снаряжение")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    TextField("Опишите снаряжение", text: $character.equipment, axis: .vertical)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .lineLimit(3...6)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Умения и способности")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    TextField("Опишите умения и способности", text: $character.featuresAndTraits, axis: .vertical)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .lineLimit(3...6)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }
}

struct AttacksSection: View {
    @Binding var character: Character
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Атаки и заклинания")
                .font(.headline)
                .fontWeight(.semibold)
            
            VStack(spacing: 12) {
                ForEach(character.attacks.indices, id: \.self) { index in
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Название")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            TextField("Название атаки", text: $character.attacks[index].name)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Бонус атаки")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            TextField("+5", text: $character.attacks[index].attackBonus)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Урон/Вид")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            TextField("1d6+3 рубящий", text: $character.attacks[index].damageType)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        }
                    }
                }
                
                Button("Добавить атаку") {
                    character.attacks.append(Attack())
                }
                .foregroundColor(.orange)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }
}
