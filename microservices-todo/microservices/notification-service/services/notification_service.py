from models.notification import Notification
from services import user_service, task_service
from app import db

def create_notification(user_id, task_id, message):
    """
    Create a new notification
    """
    try:
        # Check if user and task exist
        user = user_service.get_user(user_id)
        task = task_service.get_task(task_id)

        if not user or not task:
            return None

        # Create notification
        notification = Notification(user_id=user_id, task_id=task_id, message=message)
        db.session.add(notification)
        db.session.commit()

        return notification.to_dict()
    except Exception as e:
        db.session.rollback()
        print(f"Error creating notification: {e}")
        return None

def get_notifications_for_user(user_id):
    """
    Get all notifications for a user
    """
    try:
        notifications = Notification.query.filter_by(user_id=user_id).order_by(Notification.created_at.desc()).all()
        return [notification.to_dict() for notification in notifications]
    except Exception as e:
        print(f"Error retrieving notifications: {e}")
        return []

def mark_as_read(notification_id):
    """
    Mark a notification as read
    """
    try:
        notification = Notification.query.get(notification_id)
        if not notification:
            return None

        notification.read = True
        db.session.commit()

        return notification.to_dict()
    except Exception as e:
        db.session.rollback()
        print(f"Error marking notification as read: {e}")
        return None

# TODO-MS12: Implémentez la fonction check_due_tasks
# Cette fonction doit :
# 1. Récupérer les tâches à échéance proche via task_service.get_tasks_due_soon()
# 2. Pour chaque tâche, vérifier s'il existe déjà une notification non lue
# 3. S'il n'y a pas de notification, en créer une nouvelle
# 4. Retourner la liste des notifications créées
def check_due_tasks():
    """
    Check tasks due soon and create notifications
    """
    # À implémenter
    pass
