from datetime import datetime
from app import db

class Notification(db.Model):
    __tablename__ = 'notifications'

    # TODO-MS10: Complétez la définition du modèle Notification
    # Le modèle doit contenir les champs suivants :
    # - id : identifiant unique (clé primaire)
    # - user_id : identifiant de l'utilisateur concerné (non nullable)
    # - task_id : identifiant de la tâche liée (non nullable)
    # - message : contenu de la notification (non nullable)
    # - created_at : date de création, par défaut datetime.utcnow
    # - read : statut de lecture, par défaut False

    id = db.Column(db.Integer, primary_key=True)
    user_id = db.Column(db.Integer, nullable=False)
    task_id = db.Column(db.Integer, nullable=False)
    message = db.Column(db.Text, nullable=False)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    read = db.Column(db.Boolean, default=False)

    def __init__(self, user_id, task_id, message):
        self.user_id = user_id
        self.task_id = task_id
        self.message = message

    # TODO-MS11: Ajoutez une méthode to_dict qui convertit l'objet Notification en dictionnaire
    # Cette méthode permettra de sérialiser facilement l'objet pour le retourner en JSON
    # N'oubliez pas de convertir created_at en format ISO avec isoformat()
    def to_dict(self):
        return {
            'id': self.id,
            'user_id': self.user_id,
            'task_id': self.task_id,
            'message': self.message,
            'created_at': self.created_at.isoformat() if self.created_at else None,
            'read': self.read
        }