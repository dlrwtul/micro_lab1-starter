from flask import Blueprint, jsonify, request
from services import notification_service

notification_bp = Blueprint('notifications', __name__)

@notification_bp.route('/user/<int:user_id>', methods=['GET'])
def get_user_notifications(user_id):
    """
    Get all notifications for a user
    """
    notifications = notification_service.get_notifications_for_user(user_id)
    return jsonify(notifications)

@notification_bp.route('', methods=['POST'])
def create_notification():
    """
    Create a new notification
    """
    data = request.json
    user_id = data.get('user_id')
    task_id = data.get('task_id')
    message = data.get('message')

    if not user_id or not task_id or not message:
        return jsonify({'error': 'All fields are required'}), 400

    notification = notification_service.create_notification(user_id, task_id, message)

    if not notification:
        return jsonify({'error': 'Error creating notification'}), 500

    return jsonify(notification), 201

@notification_bp.route('/<int:notification_id>/read', methods=['PUT'])
def mark_notification_as_read(notification_id):
    """
    Mark a notification as read
    """
    notification = notification_service.mark_as_read(notification_id)

    if not notification:
        return jsonify({'error': 'Notification not found'}), 404

    return jsonify(notification)

@notification_bp.route('/check-due-tasks', methods=['POST'])
def check_due_tasks():
    """
    Check tasks due soon and create notifications
    """
    notifications = notification_service.check_due_tasks()
    return jsonify(notifications), 201
