#!/usr/bin/env python3
from app import app, initialize_database
from models import db, User, Rol, Security

def create_test_data():
    """Create test data for the application"""
    with app.app_context():
        # Create tables
        db.create_all()
        
        # Create roles
        admin_rol = Rol(nombre_rol='administrador')
        user_rol = Rol(nombre_rol='usuariofinal')
        db.session.add(admin_rol)
        db.session.add(user_rol)
        db.session.commit()
        
        # Create security policy
        security = Security(tipo='basic', descripcion='Basic security policy')
        db.session.add(security)
        db.session.commit()
        
        # Create test user
        admin_user = User(
            nombre='admin',
            contrasenia='admin123',  # Using contrasenia field
            rol_idrol=admin_rol.idrol
        )
        db.session.add(admin_user)
        db.session.commit()
        
        print("Test data created successfully!")

if __name__ == '__main__':
    create_test_data()