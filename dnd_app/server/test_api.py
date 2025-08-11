#!/usr/bin/env python3
"""
Тестовый скрипт для проверки работы API
"""

import requests
import json
import sys

def test_api(base_url):
    """Тестирование API endpoints"""
    print(f"🧪 Тестирование API: {base_url}")
    print("=" * 50)
    
    # Тест health endpoint
    print("1. Тест health endpoint...")
    try:
        response = requests.get(f"{base_url}/health")
        if response.status_code == 200:
            print("✅ Health endpoint работает")
            print(f"   Ответ: {response.json()}")
        else:
            print(f"❌ Health endpoint вернул статус {response.status_code}")
    except Exception as e:
        print(f"❌ Ошибка health endpoint: {e}")
    
    print()
    
    # Тест получения заклинаний
    print("2. Тест получения заклинаний...")
    try:
        response = requests.get(f"{base_url}/spells?per_page=5")
        if response.status_code == 200:
            data = response.json()
            print(f"✅ Получено {len(data.get('spells', []))} заклинаний")
            print(f"   Всего заклинаний: {data.get('total', 0)}")
            if data.get('spells'):
                print(f"   Первое заклинание: {data['spells'][0]['name']}")
        else:
            print(f"❌ Spells endpoint вернул статус {response.status_code}")
    except Exception as e:
        print(f"❌ Ошибка spells endpoint: {e}")
    
    print()
    
    # Тест получения умений
    print("3. Тест получения умений...")
    try:
        response = requests.get(f"{base_url}/feats?per_page=5")
        if response.status_code == 200:
            data = response.json()
            print(f"✅ Получено {len(data.get('feats', []))} умений")
            print(f"   Всего умений: {data.get('total', 0)}")
            if data.get('feats'):
                print(f"   Первое умение: {data['feats'][0]['name']}")
        else:
            print(f"❌ Feats endpoint вернул статус {response.status_code}")
    except Exception as e:
        print(f"❌ Ошибка feats endpoint: {e}")
    
    print()
    
    # Тест фильтров заклинаний
    print("4. Тест фильтров заклинаний...")
    try:
        response = requests.get(f"{base_url}/spells/filters")
        if response.status_code == 200:
            data = response.json()
            print(f"✅ Получены фильтры")
            print(f"   Школы: {len(data.get('schools', []))}")
            print(f"   Классы: {len(data.get('classes', []))}")
            print(f"   Уровни: {len(data.get('levels', []))}")
        else:
            print(f"❌ Filters endpoint вернул статус {response.status_code}")
    except Exception as e:
        print(f"❌ Ошибка filters endpoint: {e}")
    
    print()
    
    # Тест поиска заклинаний
    print("5. Тест поиска заклинаний...")
    try:
        response = requests.get(f"{base_url}/spells?search=fire&per_page=3")
        if response.status_code == 200:
            data = response.json()
            print(f"✅ Поиск 'fire' вернул {len(data.get('spells', []))} результатов")
            if data.get('spells'):
                for spell in data['spells']:
                    print(f"   - {spell['name']}")
        else:
            print(f"❌ Search вернул статус {response.status_code}")
    except Exception as e:
        print(f"❌ Ошибка поиска: {e}")
    
    print()
    
    # Тест создания пользователя
    print("6. Тест создания пользователя...")
    try:
        user_data = {
            "username": "test_user",
            "email": "test@example.com"
        }
        response = requests.post(f"{base_url}/users", json=user_data)
        if response.status_code == 201:
            data = response.json()
            print(f"✅ Пользователь создан: {data['username']}")
            user_id = data['id']
            
            # Тест добавления заклинания пользователю
            print("7. Тест добавления заклинания пользователю...")
            spell_data = {
                "is_favorite": True,
                "notes": "Тестовое заклинание"
            }
            response = requests.post(f"{base_url}/users/{user_id}/spells/1", json=spell_data)
            if response.status_code == 200:
                print("✅ Заклинание добавлено пользователю")
            else:
                print(f"❌ Добавление заклинания вернуло статус {response.status_code}")
        else:
            print(f"❌ Создание пользователя вернуло статус {response.status_code}")
    except Exception as e:
        print(f"❌ Ошибка создания пользователя: {e}")
    
    print()
    print("=" * 50)
    print("🎉 Тестирование завершено!")

def main():
    """Основная функция"""
    if len(sys.argv) != 2:
        print("Использование: python test_api.py <base_url>")
        print("Пример: python test_api.py https://your-app-name.railway.app/api")
        sys.exit(1)
    
    base_url = sys.argv[1]
    if not base_url.startswith(('http://', 'https://')):
        base_url = f"https://{base_url}"
    
    if not base_url.endswith('/api'):
        base_url = f"{base_url}/api"
    
    test_api(base_url)

if __name__ == '__main__':
    main()
