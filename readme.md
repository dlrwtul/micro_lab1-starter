# TP1 : Transformation d'une application monolithique en microservices

Ce dépôt contient le code de départ pour le TP1 du cours "Architecture Logicielles Modernes" qui porte sur la transformation d'une application monolithique en architecture microservices.

## Objectifs du TP

Dans ce TP, vous allez :

1. Explorer et comprendre une application monolithique existante
2. Identifier les composants autonomes et leurs limites (bounded contexts) dans cette application
3. Implémenter des microservices autonomes en utilisant différents langages et frameworks
4. Mettre en place une communication inter-services via des API REST
5. Gérer les bases de données indépendantes pour chaque service
6. Déployer et orchestrer l'ensemble avec Docker Compose

## Contenu du projet généré

Le script `setup_lab1.sh` génère :

1. **Une application monolithique fonctionnelle** (dans le dossier `monolith`)
2. **La structure des microservices à compléter** (dans le dossier `microservices`)

## Comment démarrer

### Prérequis

- Bash (Linux ou macOS) ou Git Bash sur Windows
- Droits d'exécution sur les fichiers
- Docker et Docker Compose pour l'exécution
- JDK 17+, Node.js 18+, Python 3.9+ pour le développement

### Installation

1. Clonez ce dépôt :

```bash
git clone https://github.com/elbachir67/micro_lab1-starter.git
cd micro_lab1-starter
```

2. Rendez le script d'installation exécutable :

```bash
chmod +x setup_lab1.sh
```

3. Exécutez le script pour générer la structure du projet :

```bash
./setup_lab1.sh
```

4. Le script créera un dossier `microservices-todo` contenant l'application monolithique et la structure des microservices à compléter.

## Structure du projet généré

```
microservices-todo/
|-- monolith/                      # Application monolithique fonctionnelle
|   |-- src/                       # Code source
|   |-- build.gradle               # Configuration Gradle
|   |-- docker-compose.yml         # Configuration Docker pour le monolithe
|   |-- Dockerfile                 # Instructions de conteneurisation
|   |-- gradlew, gradlew.bat       # Scripts Gradle Wrapper
|
|-- microservices/
|   |-- user-service/              # Service Utilisateurs (Java/Spring Boot)
|   |-- task-service/              # Service Tâches (Node.js/Express)
|   |-- notification-service/      # Service Notifications (Python/Flask)
|   |-- frontend/                  # Interface utilisateur (à intégrer)
|
|-- docker-compose.yml             # Orchestration des microservices
```

## Utilisation de l'application monolithique

L'application monolithique est complètement fonctionnelle et peut être exécutée comme référence :

```bash
cd microservices-todo/monolith
./gradlew bootRun
```

Ou avec Docker :

```bash
cd microservices-todo/monolith
docker-compose up --build
```

Vous pouvez accéder à l'application monolithique sur [http://localhost:8080](http://localhost:8080)

## Travail sur les microservices

Pour chaque microservice, vous devez compléter les parties marquées avec des commentaires `TODO-XXX` selon les instructions du TP.

Les microservices et leurs technologies sont :

1. **Service Utilisateurs** (Java/Spring Boot) : Port 8081

   - Gestion des utilisateurs et authentification
   - TODOs: MS1, MS2, MS3, MS4, MS5, MS6

2. **Service Tâches** (Node.js/Express) : Port 8082

   - Gestion des tâches et leur cycle de vie
   - TODOs: MS7, MS8, MS9, COMM1

3. **Service Notifications** (Python/Flask) : Port 8083
   - Envoi des notifications pour les tâches à échéance
   - TODOs: MS10, MS11, MS12, COMM2

## Tests des microservices

Une fois que vous avez complété les TODOs d'un service, vous pouvez le tester individuellement :

### Service Utilisateurs

```bash
cd microservices-todo/microservices/user-service
./gradlew bootRun
```

### Service Tâches

```bash
cd microservices-todo/microservices/task-service
npm install
npm start
```

### Service Notifications

```bash
cd microservices-todo/microservices/notification-service
pip install -r requirements.txt
python app.py
```

## Démarrage du système complet avec Docker Compose

Une fois que tous les TODOs sont complétés, vous pouvez démarrer l'ensemble du système avec Docker Compose :

```bash
cd microservices-todo
docker-compose up --build
```

Vous pourrez alors accéder à chaque service :

- Service Utilisateurs : [http://localhost:8081](http://localhost:8081)
- Service Tâches : [http://localhost:8082](http://localhost:8082)
- Service Notifications : [http://localhost:8083](http://localhost:8083)
- Frontend (si intégré) : [http://localhost:3000](http://localhost:3000)

## Conseils pour réussir le TP

1. Commencez par **explorer l'application monolithique** pour comprendre sa structure et son fonctionnement
2. Comprenez les responsabilités et limites de chaque service avant de commencer l'implémentation
3. Complétez les services dans l'ordre : Utilisateurs → Tâches → Notifications
4. Testez chaque service isolément avant de les intégrer
5. Utilisez Postman ou des outils similaires pour tester les API REST
6. Consultez les documents officiels des technologies utilisées (Spring Boot, Express, Flask) en cas de besoin

## Points d'attention

- La communication entre les services est un aspect crucial : assurez-vous de bien comprendre comment chaque service interagit avec les autres
- Le polyglot programming (utilisation de différentes technologies) est un aspect important du TP : observez comment chaque technologie gère différemment les mêmes concepts
- La gestion des bases de données indépendantes pose des défis spécifiques en termes de cohérence des données

Bon travail !.yml # Configuration Docker pour le monolithe
| |-- Dockerfile
|
|-- microservices/
| |-- user-service/ # Service Utilisateurs (Java/Spring Boot)
| |-- task-service/ # Service Tâches (Node.js/Express)
| |-- notification-service/ # Service Notifications (Python/Flask)
| |-- frontend/ # Interface utilisateur (à intégrer)
|
|-- docker-compose.yml # Orchestration des microservices

````

## Utilisation de l'application monolithique

L'application monolithique est complètement fonctionnelle et peut être exécutée comme référence :

```bash
cd microservices-todo/monolith
./gradlew bootRun
````

Ou avec Docker :

```bash
cd microservices-todo/monolith
docker-compose up --build
```

Vous pouvez accéder à l'application monolithique sur [http://localhost:8080](http://localhost:8080)

## Travail sur les microservices

Pour chaque microservice, vous devez compléter les parties marquées avec des commentaires `TODO-XXX` selon les instructions du TP.

Les microservices et leurs technologies sont :

1. **Service Utilisateurs** (Java/Spring Boot) : Port 8081

   - Gestion des utilisateurs et authentification
   - TODOs: MS1, MS2, MS3, MS4, MS5, MS6

2. **Service Tâches** (Node.js/Express) : Port 8082

   - Gestion des tâches et leur cycle de vie
   - TODOs: MS7, MS8, MS9, COMM1

3. **Service Notifications** (Python/Flask) : Port 8083
   - Envoi des notifications pour les tâches à échéance
   - TODOs: MS10, MS11, MS12, COMM2

## Tests des microservices

Une fois que vous avez complété les TODOs d'un service, vous pouvez le tester individuellement :

### Service Utilisateurs

```bash
cd microservices-todo/microservices/user-service
./gradlew bootRun
```

### Service Tâches

```bash
cd microservices-todo/microservices/task-service
npm install
npm start
```

### Service Notifications

```bash
cd microservices-todo/microservices/notification-service
pip install -r requirements.txt
python app.py
```

## Démarrage du système complet avec Docker Compose

Une fois que tous les TODOs sont complétés, vous pouvez démarrer l'ensemble du système avec Docker Compose :

```bash
cd microservices-todo
docker-compose up --build
```

Vous pourrez alors accéder à chaque service :

- Service Utilisateurs : [http://localhost:8081](http://localhost:8081)
- Service Tâches : [http://localhost:8082](http://localhost:8082)
- Service Notifications : [http://localhost:8083](http://localhost:8083)
- Frontend (si intégré) : [http://localhost:3000](http://localhost:3000)

## Conseils pour réussir le TP

1. Commencez par **explorer l'application monolithique** pour comprendre sa structure et son fonctionnement
2. Comprenez les responsabilités et limites de chaque service avant de commencer l'implémentation
3. Complétez les services dans l'ordre : Utilisateurs → Tâches → Notifications
4. Testez chaque service isolément avant de les intégrer
5. Utilisez Postman ou des outils similaires pour tester les API REST
6. Consultez les documents officiels des technologies utilisées (Spring Boot, Express, Flask) en cas de besoin

## Points d'attention

- La communication entre les services est un aspect crucial : assurez-vous de bien comprendre comment chaque service interagit avec les autres
- Le polyglot programming (utilisation de différentes technologies) est un aspect important du TP : observez comment chaque technologie gère différemment les mêmes concepts
- La gestion des bases de données indépendantes pose des défis spécifiques en termes de cohérence des données

Bon travail !
