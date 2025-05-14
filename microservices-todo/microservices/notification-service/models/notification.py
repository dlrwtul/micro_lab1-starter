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

    def __init__(self, user_id, task_id, message):
        self.user_id = user_id
        self.task_id = task_id
        self.message = message

    # TODO-MS11: Ajoutez une méthode to_dict qui convertit l'objet Notification en dictionnaire
    # Cette méthode permettra de sérialiser facilement l'objet pour le retourner en JSON
    # N'oubliez pas de convertir created_at en format ISO avec isoformat()
    def to_dict(self):
        # À implémenter
        pass
