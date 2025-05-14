import requests
import os

# User service URL
USER_SERVICE_URL = 'http://user-service:8081' if os.environ.get('FLASK_ENV') == 'production' else 'http://localhost:8081'

def get_user(user_id):
    """
    Get a user by ID from the user service
    """
    try:
        response = requests.get(f'{USER_SERVICE_URL}/api/users/{user_id}')
        if response.status_code == 200:
            return response.json()
        return None
    except Exception as e:
        print(f"Error retrieving user: {e}")
        return None
