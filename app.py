from flask import Flask, render_template, request, redirect, url_for, session, flash, jsonify
from models import db, User, Slice, Rol, Security, Instancia, Interfaz
import os
import json
from datetime import datetime

app = Flask(__name__)
app.config['SECRET_KEY'] = 'your-secret-key-change-in-production'
app.config['SQLALCHEMY_DATABASE_URI'] = 'mysql+pymysql://root:root@localhost:3306/mydb'
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False

# Initialize database
db.init_app(app)

def create_sample_data():
    """Create sample roles, security, users and slices for testing"""
    # Create default roles
    if not Rol.query.first():
        admin_rol = Rol(nombre_rol='admin')
        user_rol = Rol(nombre_rol='user')
        db.session.add_all([admin_rol, user_rol])
        db.session.commit()
    
    # Create default security
    if not Security.query.first():
        basic_security = Security(tipo='basic', descripcion='Basic security policy')
        db.session.add(basic_security)
        db.session.commit()
    
    # Check if test user already exists
    test_user = User.query.filter_by(nombre='admin').first()
    if not test_user:
        # Create test user
        admin_rol = Rol.query.filter_by(nombre_rol='admin').first()
        test_user = User(nombre='admin', rol_idrol=admin_rol.idrol)
        test_user.set_password('admin123')
        db.session.add(test_user)
        db.session.commit()
        
        # Create sample slices
        security = Security.query.first()
        sample_slices = [
            Slice(
                nombre='TEL141_2025-2_20206466',
                estado='RUNNING',
                topologia='{"nodes":[{"id":1,"label":"VM1"},{"id":2,"label":"VM2"}],"edges":[{"from":1,"to":2}]}',
                fecha_creacion=datetime(2025, 8, 18, 6, 27, 0).date(),
                security_idsecurity=security.idsecurity
            ),
            Slice(
                nombre='TEL142_2025-2_20206467', 
                estado='STOPPED', 
                topologia='{"nodes":[{"id":1,"label":"VM1"}],"edges":[]}',
                fecha_creacion=datetime(2025, 8, 19, 14, 15, 30).date(),
                security_idsecurity=security.idsecurity
            )
        ]
        
        for slice_obj in sample_slices:
            db.session.add(slice_obj)
            slice_obj.usuarios.append(test_user)
        
        db.session.commit()
        print("Sample data created successfully!")

def initialize_database():
    """Create database tables and sample data"""
    with app.app_context():
        db.create_all()
        create_sample_data()

@app.route('/')
def index():
    """Redirect to login if not authenticated, otherwise to dashboard"""
    if 'user_id' in session:
        return redirect(url_for('dashboard'))
    return redirect(url_for('login'))

@app.route('/login', methods=['GET', 'POST'])
def login():
    """Login page"""
    if request.method == 'POST':
        username = request.form['username']
        password = request.form['password']
        
        user = User.query.filter_by(nombre=username).first()
        
        if user and user.check_password(password):
            session['user_id'] = user.id
            session['username'] = user.nombre
            flash('Login successful!', 'success')
            return redirect(url_for('dashboard'))
        else:
            flash('Invalid username or password', 'error')
    
    return render_template('login.html')

@app.route('/register', methods=['GET', 'POST'])
def register():
    """User registration page"""
    if request.method == 'POST':
        username = request.form['username']
        password = request.form['password']
        confirm_password = request.form['confirm_password']
        
        # Validation
        if password != confirm_password:
            flash('Passwords do not match', 'error')
            return render_template('register.html')
        
        if User.query.filter_by(nombre=username).first():
            flash('Username already exists', 'error')
            return render_template('register.html')
        
        # Create new user with default user role
        user_rol = Rol.query.filter_by(nombre_rol='user').first()
        if not user_rol:
            # Create user role if it doesn't exist
            user_rol = Rol(nombre_rol='user')
            db.session.add(user_rol)
            db.session.commit()
        
        new_user = User(nombre=username, rol_idrol=user_rol.idrol)
        new_user.set_password(password)
        db.session.add(new_user)
        db.session.commit()
        
        flash('Registration successful! Please log in.', 'success')
        return redirect(url_for('login'))
    
    return render_template('register.html')

@app.route('/logout')
def logout():
    """Logout and clear session"""
    session.clear()
    flash('You have been logged out', 'info')
    return redirect(url_for('login'))

@app.route('/dashboard')
def dashboard():
    """Dashboard page - requires authentication"""
    if 'user_id' not in session:
        flash('Please log in to access the dashboard', 'error')
        return redirect(url_for('login'))
    
    user = User.query.get(session['user_id'])
    user_slices = user.slices
    
    return render_template('dashboard.html', user=user, slices=user_slices)

@app.route('/create_slice', methods=['GET', 'POST'])
def create_slice():
    """Create new slice page"""
    if 'user_id' not in session:
        flash('Please log in to create slices', 'error')
        return redirect(url_for('login'))
    
    if request.method == 'POST':
        # Get form data
        slice_name = request.form.get('slice_name', 'Unnamed Slice')
        num_vms = int(request.form['num_vms'])
        topology_type = request.form['topology_type']
        topology_data = request.form.get('topology_data', '')
        
        # Create security (basic for now)
        security = Security.query.first()
        if not security:
            security = Security(tipo='basic', descripcion='Basic security policy')
            db.session.add(security)
            db.session.commit()
        
        # Create slice
        new_slice = Slice(
            nombre=slice_name,
            estado='STOPPED',
            security_idsecurity=security.idsecurity
        )
        
        # Set topology based on type
        if topology_type == 'custom' and topology_data:
            # Custom topology from Vis.js
            new_slice.topologia = topology_data
        else:
            # Generate predefined topology
            nodes = []
            edges = []
            
            for i in range(1, num_vms + 1):
                nodes.append({
                    'id': i,
                    'label': f'VM{i}',
                    'color': '#28a745'
                })
            
            if topology_type == 'star':
                # Star topology - connect all VMs to VM1
                for i in range(2, num_vms + 1):
                    edges.append({'from': 1, 'to': i})
            elif topology_type == 'tree':
                # Tree topology - hierarchical connections
                for i in range(2, num_vms + 1):
                    parent = (i - 1) // 2
                    if parent == 0:
                        parent = 1
                    edges.append({'from': parent, 'to': i})
            
            topology = {'nodes': nodes, 'edges': edges}
            new_slice.set_topology_data(topology)
        
        db.session.add(new_slice)
        db.session.commit()
        
        # Add user to slice
        user = User.query.get(session['user_id'])
        new_slice.usuarios.append(user)
        
        # Create instances based on form data
        for i in range(1, num_vms + 1):
            vm_name = request.form.get(f'vm_{i}_name', f'VM{i}')
            vm_cpu = request.form.get(f'vm_{i}_cpu', '1')
            vm_ram = request.form.get(f'vm_{i}_ram', '1GB')
            vm_storage = request.form.get(f'vm_{i}_storage', '10GB')
            vm_image = request.form.get(f'vm_{i}_image', 'ubuntu:latest')
            
            instance = Instancia(
                slice_idslice=new_slice.idslice,
                nombre=vm_name,
                cpu=vm_cpu,
                ram=vm_ram,
                storage=vm_storage,
                imagen=vm_image
            )
            db.session.add(instance)
        
        db.session.commit()
        flash('Slice created successfully!', 'success')
        return redirect(url_for('dashboard'))
    
    return render_template('create_slice.html')

@app.route('/slice/<int:slice_id>')
def slice_detail(slice_id):
    """Get slice details as JSON"""
    if 'user_id' not in session:
        return jsonify({'error': 'Not authenticated'}), 401
    
    slice_obj = Slice.query.get_or_404(slice_id)
    user = User.query.get(session['user_id'])
    
    # Check if slice belongs to current user
    if user not in slice_obj.usuarios:
        return jsonify({'error': 'Access denied'}), 403
    
    # Get instances data
    instances = []
    for inst in slice_obj.instancias:
        instances.append({
            'id': inst.id,
            'nombre': inst.nombre,
            'cpu': inst.cpu,
            'ram': inst.ram,
            'storage': inst.storage,
            'imagen': inst.imagen,
            'estado': inst.estado
        })
    
    return jsonify({
        'id': slice_obj.idslice,
        'nombre': slice_obj.nombre,
        'estado': slice_obj.estado,
        'topologia': slice_obj.get_topology_data(),
        'fecha_creacion': slice_obj.fecha_creacion.strftime('%Y-%m-%d'),
        'instances': instances,
        'owner': user.nombre
    })

@app.route('/slice/<int:slice_id>/topology')
def slice_topology(slice_id):
    """View slice topology with Vis.js"""
    if 'user_id' not in session:
        flash('Please log in to view slice topology', 'error')
        return redirect(url_for('login'))
    
    slice_obj = Slice.query.get_or_404(slice_id)
    user = User.query.get(session['user_id'])
    
    # Check if slice belongs to current user
    if user not in slice_obj.usuarios:
        flash('Access denied', 'error')
        return redirect(url_for('dashboard'))
    
    return render_template('slice_topology.html', slice=slice_obj)

if __name__ == '__main__':
    initialize_database()
    app.run(debug=True, host='0.0.0.0', port=5000)