import requests
import os
from datetime import datetime, timedelta

# Task service URL
TASK_SERVICE_URL = 'http://task-service:8082' if os.environ.get('FLASK_ENV') == 'production' else 'http://localhost:8082'

def get_task(task_id):
    """
    Get a task by ID from the task service
    """
    try:
        response = requests.get(f'{TASK_SERVICE_URL}/api/tasks/{task_id}')
        if response.status_code == 200:
            return response.json()
        return None
    except Exception as e:
        print(f"Error retrieving task: {e}")
        return None

# TODO-COMM2: Implémentez la fonction get_tasks_due_soon
# Cette fonction doit :
# 1. Récupérer toutes les tâches via une requête GET au service Tâches
# 2. Filtrer les tâches non complétées dont la date d'échéance est dans les prochains jours
# 3. Retourner la liste des tâches à échéance proche
def get_tasks_due_soon(days=1):
    """
    Get tasks due soon
    """
    # À implémenter
    pass
