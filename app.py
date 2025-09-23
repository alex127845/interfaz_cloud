from flask import Flask, render_template, request, redirect, url_for, session, flash, jsonify
from models import db, User, Slice
import os
from datetime import datetime

app = Flask(__name__)
app.config['SECRET_KEY'] = 'your-secret-key-change-in-production'
app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///slice_management.db'
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False

# Initialize database
db.init_app(app)

def create_sample_data():
    """Create sample user and slices for testing"""
    # Check if test user already exists
    test_user = User.query.filter_by(username='admin').first()
    if not test_user:
        # Create test user
        test_user = User(username='admin')
        test_user.set_password('admin123')
        db.session.add(test_user)
        
        # Create sample slices
        sample_slices = [
            Slice(
                name='TEL141_2025-2_20206466',
                description='TEL141_2025-2_20206466',
                status='RUNNING',
                created_at=datetime(2025, 8, 18, 6, 27, 0),
                user_id=1
            ),
            Slice(
                name='TEL142_2025-2_20206467',
                description='TEL142_2025-2_20206467',
                status='STOPPED',
                created_at=datetime(2025, 8, 19, 14, 15, 30),
                user_id=1
            ),
            Slice(
                name='TEL143_2025-2_20206468',
                description='TEL143_2025-2_20206468',
                status='RUNNING',
                created_at=datetime(2025, 8, 20, 10, 32, 45),
                user_id=1
            )
        ]
        
        for slice_obj in sample_slices:
            db.session.add(slice_obj)
        
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
        
        user = User.query.filter_by(username=username).first()
        
        if user and user.check_password(password):
            session['user_id'] = user.id
            session['username'] = user.username
            flash('Login successful!', 'success')
            return redirect(url_for('dashboard'))
        else:
            flash('Invalid username or password', 'error')
    
    return render_template('login.html')

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
    user_slices = Slice.query.filter_by(user_id=user.id).all()
    
    return render_template('dashboard.html', user=user, slices=user_slices)

@app.route('/slice/<int:slice_id>')
def slice_detail(slice_id):
    """Get slice details as JSON"""
    if 'user_id' not in session:
        return jsonify({'error': 'Not authenticated'}), 401
    
    slice_obj = Slice.query.get_or_404(slice_id)
    
    # Check if slice belongs to current user
    if slice_obj.user_id != session['user_id']:
        return jsonify({'error': 'Access denied'}), 403
    
    return jsonify({
        'id': slice_obj.id,
        'name': slice_obj.name,
        'description': slice_obj.description,
        'status': slice_obj.status,
        'created_at': slice_obj.created_at.strftime('%Y-%m-%d %H:%M:%S'),
        'owner': slice_obj.owner.username
    })

if __name__ == '__main__':
    initialize_database()
    app.run(debug=True, host='0.0.0.0', port=5000)