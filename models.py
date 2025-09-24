from flask_sqlalchemy import SQLAlchemy
from werkzeug.security import generate_password_hash, check_password_hash
from datetime import datetime
import json

db = SQLAlchemy()

class Security(db.Model):
    __tablename__ = 'security'
    
    id = db.Column(db.Integer, primary_key=True)
    tipo = db.Column(db.String(45))
    descripcion = db.Column(db.String(45))
    
    def __repr__(self):
        return f'<Security {self.tipo}>'

class Rol(db.Model):
    __tablename__ = 'rol'
    
    id = db.Column(db.Integer, primary_key=True)
    nombre_rol = db.Column(db.String(45), nullable=False)
    
    def __repr__(self):
        return f'<Rol {self.nombre_rol}>'

class User(db.Model):
    __tablename__ = 'usuario'
    
    id = db.Column(db.Integer, primary_key=True)
    nombre = db.Column(db.String(45), unique=True, nullable=False)
    contrasenia = db.Column(db.String(128), nullable=False)
    rol_id = db.Column(db.Integer, db.ForeignKey('rol.id'), nullable=False)
    
    # Relationships
    rol = db.relationship('Rol', backref='usuarios')
    
    def set_password(self, password):
        self.contrasenia = generate_password_hash(password)
    
    def check_password(self, password):
        return check_password_hash(self.contrasenia, password)
    
    def __repr__(self):
        return f'<User {self.nombre}>'

class Slice(db.Model):
    __tablename__ = 'slice'
    
    id = db.Column(db.Integer, primary_key=True)
    estado = db.Column(db.String(45), default='STOPPED')
    topologia = db.Column(db.Text)  # JSON serialized topology
    fecha_creacion = db.Column(db.DateTime, default=datetime.utcnow)
    fecha_upload = db.Column(db.DateTime)
    security_id = db.Column(db.Integer, db.ForeignKey('security.id'), nullable=False)
    
    # Relationships
    security = db.relationship('Security', backref='slices')
    instancias = db.relationship('Instancia', backref='slice', lazy=True, cascade='all, delete-orphan')
    
    # Many-to-many relationship with users
    usuarios = db.relationship('User', secondary='usuario_has_slice', backref='slices')
    
    def get_topology_data(self):
        """Parse topology JSON data"""
        if self.topologia:
            try:
                return json.loads(self.topologia)
            except json.JSONDecodeError:
                return None
        return None
    
    def set_topology_data(self, data):
        """Set topology as JSON string"""
        if data:
            self.topologia = json.dumps(data)
        else:
            self.topologia = None
    
    def __repr__(self):
        return f'<Slice {self.id}>'

class Instancia(db.Model):
    __tablename__ = 'instancia'
    
    id = db.Column(db.Integer, primary_key=True)
    slice_id = db.Column(db.Integer, db.ForeignKey('slice.id'), nullable=False)
    nombre = db.Column(db.String(100), nullable=False)
    estado = db.Column(db.String(45), default='STOPPED')
    cpu = db.Column(db.String(45))
    ram = db.Column(db.String(45))
    storage = db.Column(db.String(45))
    imagen = db.Column(db.String(100))
    
    # Relationships
    interfaces = db.relationship('Interfaz', backref='instancia', lazy=True, cascade='all, delete-orphan')
    
    def __repr__(self):
        return f'<Instancia {self.nombre}>'

class Interfaz(db.Model):
    __tablename__ = 'interfaz'
    
    id = db.Column(db.Integer, primary_key=True)
    nombre_interfaz = db.Column(db.String(45))
    instancia_id = db.Column(db.Integer, db.ForeignKey('instancia.id'), nullable=False)
    
    def __repr__(self):
        return f'<Interfaz {self.nombre_interfaz}>'

# Association table for many-to-many relationship between users and slices
usuario_has_slice = db.Table('usuario_has_slice',
    db.Column('usuario_id', db.Integer, db.ForeignKey('usuario.id'), primary_key=True),
    db.Column('slice_id', db.Integer, db.ForeignKey('slice.id'), primary_key=True)
)