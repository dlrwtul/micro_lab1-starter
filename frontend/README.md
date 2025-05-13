# Frontend Microservices TodoList

Ce frontend React est conçu pour interagir avec l'architecture microservices de l'application TodoList. Il communique avec trois services différents : le service utilisateur (Java/Spring Boot), le service de tâches (Node.js/Express) et le service de notifications (Python/Flask).

## Prérequis

- Node.js 18 ou supérieur
- npm ou yarn
- Les microservices backend doivent être en cours d'exécution

## Installation

1. Clonez le dépôt si ce n'est pas déjà fait
2. Accédez au dossier du frontend
   ```bash
   cd frontend
   ```
3. Installez les dépendances
   ```bash
   npm install
   # ou
   yarn install
   ```

## Démarrage de l'application

### En mode développement

Pour démarrer l'application en mode développement :

```bash
npm start
# ou
yarn start
```

L'application sera accessible à l'adresse [http://localhost:3000](http://localhost:3000).

### Avec Docker

Le frontend est également configuré pour être lancé avec Docker. Pour l'exécuter via Docker Compose avec le reste des microservices :

```bash
# À la racine du projet
docker-compose up
```

## Fonctionnalités

- **Gestion des utilisateurs** : Inscription, connexion et déconnexion
- **Gestion des tâches** : Création, lecture, modification et suppression de tâches
- **Notifications** : Affichage des notifications pour les tâches à échéance proche

## Architecture

Le frontend communique avec les différents microservices via des appels REST API :

- **Service Utilisateurs** (port 8081) : Gestion des authentifications et profils utilisateurs
- **Service Tâches** (port 8082) : Gestion du CRUD des tâches
- **Service Notifications** (port 8083) : Gestion des notifications pour les tâches à échéance proche

## Structure du projet

```
frontend/
├── public/
│   ├── index.html
│   └── ...
├── src/
│   ├── components/          # Composants React réutilisables
│   ├── pages/               # Pages principales de l'application
│   ├── services/            # Services pour communiquer avec les microservices
│   ├── utils/               # Fonctions utilitaires
│   ├── App.js               # Composant principal
│   ├── index.js             # Point d'entrée
│   └── ...
├── Dockerfile               # Configuration Docker
├── package.json
└── README.md
```

## Configuration

Les URL des microservices sont configurées dans les fichiers de service correspondants :

- `src/services/userService.js` - Pour le service utilisateur
- `src/services/taskService.js` - Pour le service de tâches
- `src/services/notificationService.js` - Pour le service de notifications

Assurez-vous que les URL correspondent à la configuration de votre environnement.

## Développement

Pour contribuer au développement du frontend :

1. Créez une branche pour votre fonctionnalité
   ```bash
   git checkout -b feature/ma-nouvelle-fonctionnalite
   ```
2. Effectuez vos modifications
3. Testez vos modifications en local
4. Soumettez une pull request

## Dépannage

### Problèmes de connexion aux services backend

Si le frontend ne parvient pas à se connecter aux services backend, vérifiez que :

1. Tous les microservices sont en cours d'exécution
2. Les URL des services dans les fichiers de service du frontend sont correctes
3. Les paramètres CORS sont correctement configurés sur tous les services backend

### Problèmes de CORS

Si vous rencontrez des erreurs CORS, assurez-vous que tous les services backend ont configuré CORS pour accepter les requêtes de l'URL du frontend.
