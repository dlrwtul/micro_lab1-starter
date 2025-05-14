from flask import Flask
from flask_sqlalchemy import SQLAlchemy
from flask_cors import CORS
import os

# Initialize app
app = Flask(__name__)
CORS(app)

# Database configuration
app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///notifications.db'
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False

# Initialize database
db = SQLAlchemy(app)

# Import routes after db initialization to avoid circular imports
from routes.notification_routes import notification_bp

# Register blueprints
app.register_blueprint(notification_bp, url_prefix='/api/notifications')

# Test route
@app.route('/')
def index():
    return 'Notification service is running'

if __name__ == '__main__':
    # Create tables
    with app.app_context():
        db.create_all()

    # Start server
    port = int(os.environ.get('PORT', 8083))
    app.run(host='0.0.0.0', port=port, debug=True)
