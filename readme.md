# Architecture Logicielles Modernes - TP1

Ce projet implémente une application de gestion de tâches (Todo List) basée sur une architecture microservices. L'application est décomposée en trois microservices distincts, chacun développé avec une technologie différente pour illustrer le concept de polyglot programming.

## Architecture des microservices

L'application est composée des éléments suivants :

1. **Service Utilisateurs** (Java/Spring Boot) : Gestion des utilisateurs et authentification
2. **Service Tâches** (Node.js/Express) : Gestion des tâches et leur cycle de vie
3. **Service Notifications** (Python/Flask) : Envoi de notifications pour les tâches à échéance
4. **Frontend** (React) : Interface utilisateur pour interagir avec les services

Chaque service a sa propre base de données et est déployé dans un conteneur Docker distinct.

## Prérequis

Pour exécuter ce projet, vous aurez besoin des éléments suivants :

- **Docker et Docker Compose** (pour l'orchestration des conteneurs)
- **JDK 17+** (pour le service Utilisateurs)
- **Node.js 18+** (pour le service Tâches et le Frontend)
- **Python 3.9+** (pour le service Notifications)
- **Git** (pour la gestion du code source)

## Fonctionnalités du script startup.sh

Le script `startup.sh` automatise l'installation et le démarrage de l'architecture microservices. Il réalise les actions suivantes :

1. **Vérification des prérequis** - S'assure que tous les outils nécessaires sont installés
2. **Nettoyage des builds précédents** - Supprime les conteneurs, images et volumes existants
3. **Génération complète du code source** pour chaque service :
   - **Service Utilisateurs** :
     - Structure de projet Spring Boot
     - Modèles, repositories, services et contrôleurs
     - Configuration de sécurité et base de données
   - **Service Tâches** :
     - Structure de projet Express
     - Modèles, contrôleurs et services
     - Configuration de la base de données SQLite
   - **Service Notifications** :
     - Structure de projet Flask
     - Modèles, routes et services
     - Communication inter-services
   - **Frontend** :
     - Structure de projet React
     - Composants, pages et services
     - Formulaires et interface utilisateur complète
4. **Configuration Docker** pour chaque service
5. **Démarrage orchestré** de tous les services

## Installation et démarrage rapide

1. Clonez le dépôt :

   ```bash
   git clone https://github.com/elbachir67/micro_lab1-starter.git
   cd micro_lab1-starter
   ```

2. Rendez le script de démarrage exécutable :

   ```bash
   chmod +x startup.sh
   ```

3. Exécutez le script de démarrage pour configurer et lancer tous les services :

   ```bash
   ./startup.sh
   ```

4. Accédez à l'application via votre navigateur :
   ```
   http://localhost:3000
   ```

Le script générera et configurera automatiquement tous les fichiers nécessaires pour faire fonctionner l'application complète, y compris tous les fichiers source des différents services.

## Utilisation du script startup.sh

Le script `startup.sh` offre plusieurs options pour vous aider à gérer le cycle de vie des services :

### Options disponibles

- **Sans option** : Configure, génère tous les fichiers source et démarre tous les services

  ```bash
  ./startup.sh
  ```

- **Aide** : Affiche l'aide et les options disponibles

  ```bash
  ./startup.sh -h
  # ou
  ./startup.sh --help
  ```

- **Nettoyage** : Nettoie les builds précédents (arrête et supprime les conteneurs et images)

  ```bash
  ./startup.sh -c
  # ou
  ./startup.sh --clean
  ```

- **Configuration** : Configure et génère tous les fichiers source sans démarrer les services

  ```bash
  ./startup.sh -s
  # ou
  ./startup.sh --setup
  ```

- **Démarrage** : Démarre les services sans reconfiguration

  ```bash
  ./startup.sh -r
  # ou
  ./startup.sh --run
  ```

- **Logs** : Affiche les logs des services en cours d'exécution

  ```bash
  ./startup.sh --logs
  ```

- **Arrêt** : Arrête tous les services
  ```bash
  ./startup.sh --stop
  ```

## Structure du projet générée

Le script générera la structure de projet suivante :

```
microservices-todo/
|-- microservices/
|   |-- user-service/            # Service Utilisateurs (Java/Spring Boot)
|   |   |-- src/
|   |   |   |-- main/
|   |   |       |-- java/
|   |   |           |-- com/fst/dmi/userservice/
|   |   |               |-- controller/
|   |   |               |-- model/
|   |   |               |-- repository/
|   |   |               |-- service/
|   |   |               |-- config/
|   |   |-- build.gradle
|   |   |-- Dockerfile
|   |
|   |-- task-service/            # Service Tâches (Node.js/Express)
|   |   |-- src/
|   |   |   |-- config/
|   |   |   |-- controllers/
|   |   |   |-- models/
|   |   |   |-- routes/
|   |   |   |-- services/
|   |   |   |-- app.js
|   |   |-- package.json
|   |   |-- Dockerfile
|   |
|   |-- notification-service/    # Service Notifications (Python/Flask)
|   |   |-- models/
|   |   |-- services/
|   |   |-- routes/
|   |   |-- app.py
|   |   |-- requirements.txt
|   |   |-- Dockerfile
|   |
|   |-- frontend/                # Interface utilisateur (React)
|       |-- src/
|       |   |-- components/
|       |   |-- pages/
|       |   |-- services/
|       |-- package.json
|       |-- Dockerfile
|
|-- docker-compose.yml           # Orchestration de tous les services
```

## Ports des services

- **Service Utilisateurs** : http://localhost:8081
- **Service Tâches** : http://localhost:8082
- **Service Notifications** : http://localhost:8083
- **Frontend** : http://localhost:3000

## Fonctionnalités de l'application

1. **Gestion des utilisateurs**

   - Inscription de nouveaux utilisateurs
   - Connexion et authentification
   - Gestion des profils utilisateurs

2. **Gestion des tâches**

   - Création, modification et suppression de tâches
   - Marquage des tâches comme terminées
   - Affichage des tâches par utilisateur

3. **Notifications**
   - Génération automatique de notifications pour les tâches à échéance proche
   - Consultation des notifications par utilisateur
   - Marquage des notifications comme lues

## Détails techniques

### Service Utilisateurs (Java/Spring Boot)

- **Langage** : Java 17
- **Framework** : Spring Boot 3.x
- **Base de données** : H2 (base de données embarquée)
- **Port** : 8081
- **API REST** pour la gestion des utilisateurs

### Service Tâches (Node.js/Express)

- **Langage** : JavaScript
- **Runtime** : Node.js 18.x
- **Framework** : Express.js
- **ORM** : Sequelize avec SQLite
- **Port** : 8082
- **API REST** pour la gestion des tâches

### Service Notifications (Python/Flask)

- **Langage** : Python 3.9+
- **Framework** : Flask
- **ORM** : SQLAlchemy avec SQLite
- **Port** : 8083
- **API REST** pour la gestion des notifications

### Frontend (React)

- **Bibliothèque** : React 18
- **Style** : Bootstrap 5
- **Client HTTP** : Axios
- **Routing** : React Router
- **Port** : 3000

## Communication inter-services

Les services communiquent entre eux via des API REST :

1. Le service Tâches communique avec le service Utilisateurs pour vérifier l'existence des utilisateurs
2. Le service Notifications communique avec le service Tâches pour récupérer les tâches à échéance proche
3. Le Frontend communique avec tous les services pour offrir une interface utilisateur unifiée

## Problèmes connus et solutions

### Communication inter-services dans Docker

Si vous rencontrez des problèmes de communication entre les services, assurez-vous que les URLs des services sont correctement configurées dans les fichiers de configuration:

- Dans `task-service/src/services/userService.js`:

  ```javascript
  const USER_SERVICE_URL =
    process.env.NODE_ENV === "production"
      ? "http://user-service:8081"
      : "http://localhost:8081";
  ```

- Dans `notification-service/services/task_service.py`:
  ```python
  TASK_SERVICE_URL = 'http://task-service:8082' if os.environ.get('FLASK_ENV') == 'production' else 'http://localhost:8082'
  ```

### Problèmes de base de données

Si les données ne persistent pas entre les redémarrages:

1. Vérifiez que les volumes sont correctement configurés dans le `docker-compose.yml`
2. Vérifiez les permissions des dossiers de données sur votre système hôte

## Contributions et remerciements

Ce projet a été développé dans le cadre du cours "Architectures Logicielles Modernes" à l'Université Cheikh Anta Diop.

## Licence

Ce projet est sous licence ISC. Voir le fichier LICENSE pour plus de détails.

## Auteur

Dr. El Hadji Bassirou TOURE
Département de Mathématiques et Informatique
Faculté des Sciences et Techniques
Université Cheikh Anta Diop
