from flask_sqlalchemy import SQLAlchemy
from werkzeug.security import generate_password_hash, check_password_hash
from datetime import datetime

db = SQLAlchemy()

class User(db.Model):
    __tablename__ = 'usuarios'
    
    id = db.Column(db.Integer, primary_key=True)
    username = db.Column(db.String(80), unique=True, nullable=False)
    password_hash = db.Column(db.String(128), nullable=False)
    
    # Relationship with slices
    slices = db.relationship('Slice', backref='owner', lazy=True)
    
    def set_password(self, password):
        self.password_hash = generate_password_hash(password)
    
    def check_password(self, password):
        return check_password_hash(self.password_hash, password)
    
    def __repr__(self):
        return f'<User {self.username}>'

class Slice(db.Model):
    __tablename__ = 'slices'
    
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(100), nullable=False)
    description = db.Column(db.String(200))
    status = db.Column(db.String(20), default='STOPPED')
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    
    # Foreign key to User
    user_id = db.Column(db.Integer, db.ForeignKey('usuarios.id'), nullable=False)
    
    def __repr__(self):
        return f'<Slice {self.name}>'