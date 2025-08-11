from flask import Flask, request, jsonify
from flask_cors import CORS
from flask_sqlalchemy import SQLAlchemy
from datetime import datetime
import json
import os

app = Flask(__name__)
CORS(app)

# Конфигурация базы данных
app.config['SQLALCHEMY_DATABASE_URI'] = os.environ.get('DATABASE_URL', 'sqlite:///dnd_app.db')
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False
db = SQLAlchemy(app)

# Модели базы данных
class Spell(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(200), nullable=False)
    level = db.Column(db.Integer, nullable=False)
    school = db.Column(db.String(100), nullable=False)
    classes = db.Column(db.Text, nullable=False)  # JSON string
    action_type = db.Column(db.String(50))
    concentration = db.Column(db.Boolean, default=False)
    ritual = db.Column(db.Boolean, default=False)
    casting_time = db.Column(db.String(100))
    range_distance = db.Column(db.String(100))
    components = db.Column(db.Text)  # JSON string
    duration = db.Column(db.String(100))
    description = db.Column(db.Text, nullable=False)
    material = db.Column(db.Text)
    cantrip_upgrade = db.Column(db.Text)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    updated_at = db.Column(db.DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)

class Feat(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(200), nullable=False)
    description = db.Column(db.Text, nullable=False)
    category = db.Column(db.String(100), nullable=False)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    updated_at = db.Column(db.DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)

class User(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    username = db.Column(db.String(80), unique=True, nullable=False)
    email = db.Column(db.String(120), unique=True, nullable=False)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)

class UserSpell(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    user_id = db.Column(db.Integer, db.ForeignKey('user.id'), nullable=False)
    spell_id = db.Column(db.Integer, db.ForeignKey('spell.id'), nullable=False)
    is_favorite = db.Column(db.Boolean, default=False)
    notes = db.Column(db.Text)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)

class UserFeat(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    user_id = db.Column(db.Integer, db.ForeignKey('user.id'), nullable=False)
    feat_id = db.Column(db.Integer, db.ForeignKey('feat.id'), nullable=False)
    is_favorite = db.Column(db.Boolean, default=False)
    notes = db.Column(db.Text)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)

# Создание таблиц
with app.app_context():
    db.create_all()

# API маршруты для заклинаний
@app.route('/api/spells', methods=['GET'])
def get_spells():
    """Получить все заклинания с фильтрацией"""
    page = request.args.get('page', 1, type=int)
    per_page = request.args.get('per_page', 50, type=int)
    search = request.args.get('search', '')
    level = request.args.get('level', type=int)
    school = request.args.get('school', '')
    class_name = request.args.get('class', '')
    concentration = request.args.get('concentration', type=bool)
    ritual = request.args.get('ritual', type=bool)
    
    query = Spell.query
    
    if search:
        query = query.filter(Spell.name.ilike(f'%{search}%'))
    if level is not None:
        query = query.filter(Spell.level == level)
    if school:
        query = query.filter(Spell.school == school)
    if class_name:
        query = query.filter(Spell.classes.contains(class_name))
    if concentration is not None:
        query = query.filter(Spell.concentration == concentration)
    if ritual is not None:
        query = query.filter(Spell.ritual == ritual)
    
    spells = query.paginate(page=page, per_page=per_page, error_out=False)
    
    return jsonify({
        'spells': [{
            'id': spell.id,
            'name': spell.name,
            'level': spell.level,
            'school': spell.school,
            'classes': json.loads(spell.classes),
            'actionType': spell.action_type,
            'concentration': spell.concentration,
            'ritual': spell.ritual,
            'castingTime': spell.casting_time,
            'range': spell.range_distance,
            'components': json.loads(spell.components) if spell.components else None,
            'duration': spell.duration,
            'description': spell.description,
            'material': spell.material,
            'cantripUpgrade': spell.cantrip_upgrade
        } for spell in spells.items],
        'total': spells.total,
        'pages': spells.pages,
        'current_page': page
    })

@app.route('/api/spells/<int:spell_id>', methods=['GET'])
def get_spell(spell_id):
    """Получить конкретное заклинание"""
    spell = Spell.query.get_or_404(spell_id)
    return jsonify({
        'id': spell.id,
        'name': spell.name,
        'level': spell.level,
        'school': spell.school,
        'classes': json.loads(spell.classes),
        'actionType': spell.action_type,
        'concentration': spell.concentration,
        'ritual': spell.ritual,
        'castingTime': spell.casting_time,
        'range': spell.range_distance,
        'components': json.loads(spell.components) if spell.components else None,
        'duration': spell.duration,
        'description': spell.description,
        'material': spell.material,
        'cantripUpgrade': spell.cantrip_upgrade
    })

@app.route('/api/spells/filters', methods=['GET'])
def get_spell_filters():
    """Получить доступные фильтры для заклинаний"""
    schools = db.session.query(Spell.school).distinct().all()
    classes = db.session.query(Spell.classes).all()
    
    # Извлекаем все классы из JSON строк
    all_classes = set()
    for class_list in classes:
        if class_list[0]:
            all_classes.update(json.loads(class_list[0]))
    
    return jsonify({
        'schools': [school[0] for school in schools],
        'classes': sorted(list(all_classes)),
        'levels': list(range(10))  # 0-9 уровни
    })

# API маршруты для умений
@app.route('/api/feats', methods=['GET'])
def get_feats():
    """Получить все умения с фильтрацией"""
    page = request.args.get('page', 1, type=int)
    per_page = request.args.get('per_page', 50, type=int)
    search = request.args.get('search', '')
    category = request.args.get('category', '')
    
    query = Feat.query
    
    if search:
        query = query.filter(Feat.name.ilike(f'%{search}%'))
    if category:
        query = query.filter(Feat.category == category)
    
    feats = query.paginate(page=page, per_page=per_page, error_out=False)
    
    return jsonify({
        'feats': [{
            'id': feat.id,
            'name': feat.name,
            'description': feat.description,
            'category': feat.category
        } for feat in feats.items],
        'total': feats.total,
        'pages': feats.pages,
        'current_page': page
    })

@app.route('/api/feats/<int:feat_id>', methods=['GET'])
def get_feat(feat_id):
    """Получить конкретное умение"""
    feat = Feat.query.get_or_404(feat_id)
    return jsonify({
        'id': feat.id,
        'name': feat.name,
        'description': feat.description,
        'category': feat.category
    })

@app.route('/api/feats/filters', methods=['GET'])
def get_feat_filters():
    """Получить доступные фильтры для умений"""
    categories = db.session.query(Feat.category).distinct().all()
    return jsonify({
        'categories': [category[0] for category in categories]
    })

# API маршруты для пользователей
@app.route('/api/users', methods=['POST'])
def create_user():
    """Создать нового пользователя"""
    data = request.get_json()
    
    if not data or not data.get('username') or not data.get('email'):
        return jsonify({'error': 'Username and email are required'}), 400
    
    # Проверяем, существует ли пользователь
    existing_user = User.query.filter_by(username=data['username']).first()
    if existing_user:
        return jsonify({'error': 'Username already exists'}), 409
    
    existing_email = User.query.filter_by(email=data['email']).first()
    if existing_email:
        return jsonify({'error': 'Email already exists'}), 409
    
    user = User(username=data['username'], email=data['email'])
    db.session.add(user)
    db.session.commit()
    
    return jsonify({
        'id': user.id,
        'username': user.username,
        'email': user.email,
        'created_at': user.created_at.isoformat()
    }), 201

@app.route('/api/users/<int:user_id>/spells', methods=['GET'])
def get_user_spells(user_id):
    """Получить заклинания пользователя"""
    user_spells = UserSpell.query.filter_by(user_id=user_id).all()
    
    spells = []
    for user_spell in user_spells:
        spell = Spell.query.get(user_spell.spell_id)
        if spell:
            spells.append({
                'id': spell.id,
                'name': spell.name,
                'level': spell.level,
                'school': spell.school,
                'classes': json.loads(spell.classes),
                'is_favorite': user_spell.is_favorite,
                'notes': user_spell.notes
            })
    
    return jsonify({'spells': spells})

@app.route('/api/users/<int:user_id>/spells/<int:spell_id>', methods=['POST'])
def add_user_spell(user_id, spell_id):
    """Добавить заклинание пользователю"""
    data = request.get_json() or {}
    
    # Проверяем, существует ли уже запись
    existing = UserSpell.query.filter_by(user_id=user_id, spell_id=spell_id).first()
    if existing:
        # Обновляем существующую запись
        existing.is_favorite = data.get('is_favorite', existing.is_favorite)
        existing.notes = data.get('notes', existing.notes)
    else:
        # Создаем новую запись
        user_spell = UserSpell(
            user_id=user_id,
            spell_id=spell_id,
            is_favorite=data.get('is_favorite', False),
            notes=data.get('notes', '')
        )
        db.session.add(user_spell)
    
    db.session.commit()
    return jsonify({'message': 'Spell added to user'})

@app.route('/api/users/<int:user_id>/feats', methods=['GET'])
def get_user_feats(user_id):
    """Получить умения пользователя"""
    user_feats = UserFeat.query.filter_by(user_id=user_id).all()
    
    feats = []
    for user_feat in user_feats:
        feat = Feat.query.get(user_feat.feat_id)
        if feat:
            feats.append({
                'id': feat.id,
                'name': feat.name,
                'description': feat.description,
                'category': feat.category,
                'is_favorite': user_feat.is_favorite,
                'notes': user_feat.notes
            })
    
    return jsonify({'feats': feats})

@app.route('/api/users/<int:user_id>/feats/<int:feat_id>', methods=['POST'])
def add_user_feat(user_id, feat_id):
    """Добавить умение пользователю"""
    data = request.get_json() or {}
    
    # Проверяем, существует ли уже запись
    existing = UserFeat.query.filter_by(user_id=user_id, feat_id=feat_id).first()
    if existing:
        # Обновляем существующую запись
        existing.is_favorite = data.get('is_favorite', existing.is_favorite)
        existing.notes = data.get('notes', existing.notes)
    else:
        # Создаем новую запись
        user_feat = UserFeat(
            user_id=user_id,
            feat_id=feat_id,
            is_favorite=data.get('is_favorite', False),
            notes=data.get('notes', '')
        )
        db.session.add(user_feat)
    
    db.session.commit()
    return jsonify({'message': 'Feat added to user'})

# Маршрут для загрузки данных из JSON файлов
@app.route('/api/load-data', methods=['POST'])
def load_data():
    """Загрузить данные из JSON файлов в базу данных"""
    try:
        # Загружаем заклинания
        with open('../dnd_app/spells.json', 'r', encoding='utf-8') as f:
            spells_data = json.load(f)
        
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
        
        # Загружаем умения
        with open('../dnd_app/feats.json', 'r', encoding='utf-8') as f:
            feats_data = json.load(f)
        
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
        
        db.session.commit()
        return jsonify({'message': 'Data loaded successfully'})
    
    except Exception as e:
        return jsonify({'error': str(e)}), 500

# Маршрут для проверки здоровья сервера
@app.route('/api/health', methods=['GET'])
def health_check():
    """Проверка здоровья сервера"""
    return jsonify({
        'status': 'healthy',
        'timestamp': datetime.utcnow().isoformat(),
        'database': 'connected'
    })

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=int(os.environ.get('PORT', 5000)))
