#!/usr/bin/env python3
"""
Скрипт для инициализации базы данных и загрузки данных из JSON файлов
"""

import os
import sys
import json
from app import app, db, Spell, Feat

def load_spells():
    """Загрузить заклинания из JSON файла"""
    try:
        # Путь к файлу spells.json
        spells_file = os.path.join(os.path.dirname(__file__), '..', 'dnd_app', 'spells.json')
        
        if not os.path.exists(spells_file):
            print(f"❌ Файл {spells_file} не найден")
            return False
        
        with open(spells_file, 'r', encoding='utf-8') as f:
            spells_data = json.load(f)
        
        print(f"📖 Загружено {len(spells_data)} заклинаний из JSON файла")
        
        added_count = 0
        for spell_data in spells_data:
            # Проверяем, существует ли уже заклинание
            existing = Spell.query.filter_by(name=spell_data['name']).first()
            if not existing:
                spell = Spell(
                    name=spell_data['name'],
                    level=spell_data['level'],
                    school=spell_data['school'],
                    classes=json.dumps(spell_data['classes']),
                    action_type=spell_data.get('actionType'),
                    concentration=spell_data.get('concentration', False),
                    ritual=spell_data.get('ritual', False),
                    casting_time=spell_data.get('castingTime'),
                    range_distance=spell_data.get('range'),
                    components=json.dumps(spell_data.get('components')) if spell_data.get('components') else None,
                    duration=spell_data.get('duration'),
                    description=spell_data['description'],
                    material=spell_data.get('material'),
                    cantrip_upgrade=spell_data.get('cantripUpgrade')
                )
                db.session.add(spell)
                added_count += 1
        
        db.session.commit()
        print(f"✅ Добавлено {added_count} новых заклинаний в базу данных")
        return True
        
    except Exception as e:
        print(f"❌ Ошибка при загрузке заклинаний: {e}")
        return False

def load_feats():
    """Загрузить умения из JSON файла"""
    try:
        # Путь к файлу feats.json
        feats_file = os.path.join(os.path.dirname(__file__), '..', 'dnd_app', 'feats.json')
        
        if not os.path.exists(feats_file):
            print(f"❌ Файл {feats_file} не найден")
            return False
        
        with open(feats_file, 'r', encoding='utf-8') as f:
            feats_data = json.load(f)
        
        print(f"📖 Загружено {len(feats_data)} категорий умений из JSON файла")
        
        added_count = 0
        for category, feats_list in feats_data.items():
            for feat_data in feats_list:
                # Проверяем, существует ли уже умение
                existing = Feat.query.filter_by(name=feat_data['название']).first()
                if not existing:
                    feat = Feat(
                        name=feat_data['название'],
                        description=feat_data['описание'],
                        category=category
                    )
                    db.session.add(feat)
                    added_count += 1
        
        db.session.commit()
        print(f"✅ Добавлено {added_count} новых умений в базу данных")
        return True
        
    except Exception as e:
        print(f"❌ Ошибка при загрузке умений: {e}")
        return False

def main():
    """Основная функция инициализации"""
    print("🚀 Инициализация базы данных D&D приложения...")
    
    with app.app_context():
        # Создаем таблицы
        print("📋 Создание таблиц базы данных...")
        db.create_all()
        print("✅ Таблицы созданы")
        
        # Загружаем данные
        print("\n📚 Загрузка данных из JSON файлов...")
        
        spells_success = load_spells()
        feats_success = load_feats()
        
        if spells_success and feats_success:
            print("\n🎉 Инициализация завершена успешно!")
            
            # Показываем статистику
            spell_count = Spell.query.count()
            feat_count = Feat.query.count()
            print(f"📊 Статистика базы данных:")
            print(f"   - Заклинаний: {spell_count}")
            print(f"   - Умений: {feat_count}")
        else:
            print("\n⚠️ Инициализация завершена с ошибками")
            sys.exit(1)

if __name__ == '__main__':
    main()
