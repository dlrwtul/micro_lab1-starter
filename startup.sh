#!/bin/bash
#########################################################################
# Script de démarrage pour l'architecture microservices                 #
# Ce script génère tous les fichiers source et démarre l'application    #
# Auteur: Dr. El Hadji Bassirou TOURE                                   #
#########################################################################

# =========== Configuration des couleurs pour l'affichage ================
GREEN='\033[0;32m'    # Succès
YELLOW='\033[1;33m'   # Avertissement
RED='\033[0;31m'      # Erreur
BLUE='\033[0;34m'     # Information
CYAN='\033[0;36m'     # Action en cours
NC='\033[0m'          # Réinitialisation de la couleur

# ====================== Fonctions utilitaires ==========================

# Fonction pour afficher un message avec une couleur
print_message() {
    echo -e "${2}${1}${NC}"
}

# Fonction pour vérifier si une commande existe
check_command() {
    if ! command -v $1 &> /dev/null; then
        print_message "❌ $1 n'est pas installé. Veuillez l'installer avant de continuer." "$RED"
        exit 1
    fi
}

# Fonction pour créer un répertoire s'il n'existe pas
ensure_directory() {
    if [ ! -d "$1" ]; then
        mkdir -p "$1"
        print_message "📁 Création du répertoire $1" "$CYAN"
    fi
}

# Fonction pour créer un fichier avec son contenu
create_file() {
    local directory=$(dirname "$1")
    ensure_directory "$directory"
    
    if [ ! -f "$1" ]; then
        print_message "📝 Création du fichier $(basename "$1")" "$CYAN"
        cat > "$1" << EOF
$2
EOF
    fi
}

# ===================== Vérification des prérequis ======================
check_prerequisites() {
    print_message "🔍 Vérification des prérequis..." "$BLUE"
    
    # Vérifier si Docker est installé
    check_command docker
    check_command docker-compose
    
    # Vérifier si Java est installé (pour user-service)
    check_command java
    
    # Vérifier si Node.js est installé (pour task-service et frontend)
    check_command node
    
    # Vérifier si Python est installé (pour notification-service)
    check_command python3
    
    print_message "✅ Tous les prérequis sont installés." "$GREEN"
}

# =================== Nettoyage des builds précédents ==================
clean_previous_builds() {
    print_message "🧹 Nettoyage des builds précédents..." "$BLUE"
    
    # Arrêter et supprimer les conteneurs existants
    docker-compose down -v 2>/dev/null
    
    # Supprimer les images des services
    docker rmi -f microservices-user-service:latest microservices-task-service:latest microservices-notification-service:latest microservices-frontend:latest 2>/dev/null
    
    # Supprimer les volumes potentiellement orphelins
    docker volume prune -f 2>/dev/null
    
    print_message "✅ Nettoyage terminé." "$GREEN"
}

# =================== Configuration des services =======================

# ======== SERVICE UTILISATEURS (Java/Spring Boot) ==========
setup_user_service() {
    print_message "🔧 Configuration du service utilisateur (Java/Spring Boot)..." "$BLUE"
    
    # Créer et accéder au répertoire du service
    local base_dir="./microservices/user-service"
    ensure_directory "$base_dir"
    cd "$base_dir"
    
    # Création du fichier build.gradle
    create_file "build.gradle" 'plugins {
    id "org.springframework.boot" version "3.1.5"
    id "io.spring.dependency-management" version "1.1.3"
    id "java"
}

group = "com.fst.dmi"
version = "0.0.1-SNAPSHOT"
sourceCompatibility = "17"

repositories {
    mavenCentral()
}

dependencies {
    implementation "org.springframework.boot:spring-boot-starter-data-jpa"
    implementation "org.springframework.boot:spring-boot-starter-web"
    implementation "org.springframework.boot:spring-boot-starter-security"
    implementation "com.h2database:h2"
    implementation "org.springframework.boot:spring-boot-starter-validation"
    testImplementation "org.springframework.boot:spring-boot-starter-test"
    testImplementation "org.springframework.security:spring-security-test"
}

test {
    useJUnitPlatform()
}'
    
    # Création de la structure des répertoires
    ensure_directory "src/main/java/com/fst/dmi/userservice/controller"
    ensure_directory "src/main/java/com/fst/dmi/userservice/model"
    ensure_directory "src/main/java/com/fst/dmi/userservice/repository"
    ensure_directory "src/main/java/com/fst/dmi/userservice/service"
    ensure_directory "src/main/java/com/fst/dmi/userservice/config"
    ensure_directory "src/main/resources"
    
    # Création du fichier application.properties
    create_file "src/main/resources/application.properties" '# Configuration du serveur
server.port=8081

# Configuration de l'application
spring.application.name=user-service

# Configuration de la base de données H2
spring.datasource.url=jdbc:h2:file:./data/userdb
spring.datasource.driverClassName=org.h2.Driver
spring.datasource.username=sa
spring.datasource.password=password
spring.jpa.database-platform=org.hibernate.dialect.H2Dialect
spring.h2.console.enabled=true
spring.h2.console.path=/h2-console
spring.h2.console.settings.web-allow-others=true

# Configuration JPA/Hibernate
spring.jpa.hibernate.ddl-auto=update
spring.jpa.show-sql=true

# Configuration CORS
spring.web.cors.allowed-origins=*
spring.web.cors.allowed-methods=GET,POST,PUT,DELETE,OPTIONS
spring.web.cors.allowed-headers=*
spring.web.cors.max-age=3600'
    
    # Création de la classe principale
    create_file "src/main/java/com/fst/dmi/userservice/UserServiceApplication.java" 'package com.fst.dmi.userservice;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
public class UserServiceApplication {

    public static void main(String[] args) {
        SpringApplication.run(UserServiceApplication.class, args);
    }
}'
    
    # Création du modèle User
    create_file "src/main/java/com/fst/dmi/userservice/model/User.java" 'package com.fst.dmi.userservice.model;

import jakarta.persistence.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "users")
public class User {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, unique = true)
    private String username;

    @Column(nullable = false, unique = true)
    private String email;

    @Column(nullable = false)
    private String password;

    @Column(nullable = false)
    private LocalDateTime createdAt;

    // Getters et Setters
    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public String getUsername() {
        return username;
    }

    public void setUsername(String username) {
        this.username = username;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getPassword() {
        return password;
    }

    public void setPassword(String password) {
        this.password = password;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }

    // Constructeurs
    public User() {
        this.createdAt = LocalDateTime.now();
    }

    public User(String username, String email, String password) {
        this.username = username;
        this.email = email;
        this.password = password;
        this.createdAt = LocalDateTime.now();
    }

    @Override
    public String toString() {
        return "User{" +
                "id=" + id +
                ", username='" + username + '\'' +
                ", email='" + email + '\'' +
                ", createdAt=" + createdAt +
                '}';
    }
}'
    
    # Création du repository
    create_file "src/main/java/com/fst/dmi/userservice/repository/UserRepository.java" 'package com.fst.dmi.userservice.repository;

import com.fst.dmi.userservice.model.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface UserRepository extends JpaRepository<User, Long> {
    User findByUsername(String username);
    User findByEmail(String email);
    boolean existsByUsername(String username);
    boolean existsByEmail(String email);
}'
    
    # Création de la configuration de sécurité
    create_file "src/main/java/com/fst/dmi/userservice/config/SecurityConfig.java" 'package com.fst.dmi.userservice.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.web.cors.CorsConfiguration;
import org.springframework.web.cors.CorsConfigurationSource;
import org.springframework.web.cors.UrlBasedCorsConfigurationSource;

import java.util.Arrays;

@Configuration
@EnableWebSecurity
public class SecurityConfig {

    @Bean
    public SecurityFilterChain securityFilterChain(HttpSecurity http) throws Exception {
        http
            .csrf().disable()
            .cors().and()
            .authorizeHttpRequests(authorize -> authorize
                .anyRequest().permitAll()
            );
        
        return http.build();
    }

    @Bean
    public PasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder();
    }

    @Bean
    public CorsConfigurationSource corsConfigurationSource() {
        CorsConfiguration configuration = new CorsConfiguration();
        configuration.setAllowedOrigins(Arrays.asList("*"));
        configuration.setAllowedMethods(Arrays.asList("GET", "POST", "PUT", "DELETE", "OPTIONS"));
        configuration.setAllowedHeaders(Arrays.asList("authorization", "content-type", "x-auth-token"));
        configuration.setExposedHeaders(Arrays.asList("x-auth-token"));
        UrlBasedCorsConfigurationSource source = new UrlBasedCorsConfigurationSource();
        source.registerCorsConfiguration("/**", configuration);
        return source;
    }
}'
    
    # Création du service
    create_file "src/main/java/com/fst/dmi/userservice/service/UserService.java" 'package com.fst.dmi.userservice.service;

import com.fst.dmi.userservice.model.User;
import com.fst.dmi.userservice.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;

@Service
public class UserService {

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;

    @Autowired
    public UserService(UserRepository userRepository, PasswordEncoder passwordEncoder) {
        this.userRepository = userRepository;
        this.passwordEncoder = passwordEncoder;
    }

    public User createUser(User user) {
        // Check if username already exists
        if (userRepository.existsByUsername(user.getUsername())) {
            throw new RuntimeException("Username already exists");
        }
        if (userRepository.existsByEmail(user.getEmail())) {
            throw new RuntimeException("Email already exists");
        }

        // Encode password
        user.setPassword(passwordEncoder.encode(user.getPassword()));

        // Save user
        return userRepository.save(user);
    }

    public boolean authenticateUser(String username, String password) {
        User user = userRepository.findByUsername(username);
        if (user == null) {
            return false;
        }

        return passwordEncoder.matches(password, user.getPassword());
    }

    public User findUserByUsername(String username) {
        return userRepository.findByUsername(username);
    }

    public Optional<User> findUserById(Long id) {
        return userRepository.findById(id);
    }

    public List<User> findAllUsers() {
        return userRepository.findAll();
    }

    public User updateUser(Long id, User userDetails) {
        Optional<User> userOpt = userRepository.findById(id);
        
        if (userOpt.isPresent()) {
            User user = userOpt.get();
            
            if (userDetails.getUsername() != null && !userDetails.getUsername().equals(user.getUsername())) {
                if (userRepository.existsByUsername(userDetails.getUsername())) {
                    throw new RuntimeException("Username already exists");
                }
                user.setUsername(userDetails.getUsername());
            }
            
            if (userDetails.getEmail() != null && !userDetails.getEmail().equals(user.getEmail())) {
                if (userRepository.existsByEmail(userDetails.getEmail())) {
                    throw new RuntimeException("Email already exists");
                }
                user.setEmail(userDetails.getEmail());
            }
            
            if (userDetails.getPassword() != null && !userDetails.getPassword().isEmpty()) {
                user.setPassword(passwordEncoder.encode(userDetails.getPassword()));
            }
            
            return userRepository.save(user);
        } else {
            throw new RuntimeException("User not found with id: " + id);
        }
    }

    public void deleteUser(Long id) {
        if (!userRepository.existsById(id)) {
            throw new RuntimeException("User not found with id: " + id);
        }
        userRepository.deleteById(id);
    }
}'
    
    # Création du contrôleur
    create_file "src/main/java/com/fst/dmi/userservice/controller/UserController.java" 'package com.fst.dmi.userservice.controller;

import com.fst.dmi.userservice.model.User;
import com.fst.dmi.userservice.service.UserService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;
import java.util.Optional;

@RestController
@RequestMapping("/api/users")
public class UserController {

    private final UserService userService;

    @Autowired
    public UserController(UserService userService) {
        this.userService = userService;
    }

    @PostMapping
    public ResponseEntity<?> createUser(@RequestBody User user) {
        try {
            User createdUser = userService.createUser(user);
            return new ResponseEntity<>(createdUser, HttpStatus.CREATED);
        } catch (Exception e) {
            return new ResponseEntity<>(Map.of("error", e.getMessage()), HttpStatus.BAD_REQUEST);
        }
    }

    @PostMapping("/auth")
    public ResponseEntity<?> authenticateUser(@RequestBody Map<String, String> credentials) {
        String username = credentials.get("username");
        String password = credentials.get("password");

        if (username == null || password == null) {
            return new ResponseEntity<>(Map.of("error", "Username and password required"), HttpStatus.BAD_REQUEST);
        }

        boolean authenticated = userService.authenticateUser(username, password);
        if (authenticated) {
            User user = userService.findUserByUsername(username);
            return new ResponseEntity<>(user, HttpStatus.OK);
        } else {
            return new ResponseEntity<>(Map.of("error", "Authentication failed"), HttpStatus.UNAUTHORIZED);
        }
    }

    @GetMapping
    public ResponseEntity<List<User>> getAllUsers() {
        List<User> users = userService.findAllUsers();
        return new ResponseEntity<>(users, HttpStatus.OK);
    }

    @GetMapping("/{id}")
    public ResponseEntity<?> getUserById(@PathVariable Long id) {
        Optional<User> user = userService.findUserById(id);
        if (user.isPresent()) {
            return new ResponseEntity<>(user.get(), HttpStatus.OK);
        } else {
            return new ResponseEntity<>(Map.of("error", "User not found"), HttpStatus.NOT_FOUND);
        }
    }

    @PutMapping("/{id}")
    public ResponseEntity<?> updateUser(@PathVariable Long id, @RequestBody User userDetails) {
        try {
            User updatedUser = userService.updateUser(id, userDetails);
            return new ResponseEntity<>(updatedUser, HttpStatus.OK);
        } catch (Exception e) {
            return new ResponseEntity<>(Map.of("error", e.getMessage()), HttpStatus.BAD_REQUEST);
        }
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<?> deleteUser(@PathVariable Long id) {
        try {
            userService.deleteUser(id);
            return new ResponseEntity<>(Map.of("message", "User deleted successfully"), HttpStatus.OK);
        } catch (Exception e) {
            return new ResponseEntity<>(Map.of("error", e.getMessage()), HttpStatus.NOT_FOUND);
        }
    }
}'
    
    # Configuration Gradle Wrapper
    ensure_directory "gradle/wrapper"
    
    # Téléchargement du gradle-wrapper.jar si nécessaire
    if [ ! -f "gradle/wrapper/gradle-wrapper.jar" ]; then
        print_message "⬇️ Téléchargement de gradle-wrapper.jar..." "$YELLOW"
        curl -s -o gradle/wrapper/gradle-wrapper.jar https://repo.maven.apache.org/maven2/org/gradle/gradle-wrapper/7.6/gradle-wrapper-7.6.jar
    fi
    
    # Création du fichier gradle-wrapper.properties
    create_file "gradle/wrapper/gradle-wrapper.properties" 'distributionBase=GRADLE_USER_HOME
distributionPath=wrapper/dists
distributionUrl=https\://services.gradle.org/distributions/gradle-7.6-bin.zip
zipStoreBase=GRADLE_USER_HOME
zipStorePath=wrapper/dists'
    
    # Création du script gradlew
    create_file "gradlew" '#!/bin/sh
exec java -Xmx64m -Xms64m -classpath "$0.jar" org.gradle.wrapper.GradleWrapperMain "$@"'
    
    # Rendre gradlew exécutable
    chmod +x gradlew
    
    # Création du Dockerfile
    create_file "Dockerfile" 'FROM gradle:7.6-jdk17-alpine as build

WORKDIR /app

COPY . .

RUN gradle build -x test --no-daemon

FROM openjdk:17-jdk-slim

WORKDIR /app

COPY --from=build /app/build/libs/*.jar app.jar

# Créer le dossier de données s'il n'existe pas
RUN mkdir -p /app/data

EXPOSE 8081

CMD ["java", "-jar", "app.jar"]'
    
    # Revenir au répertoire principal
    cd ../..
    
    print_message "✅ Configuration du service utilisateur terminée." "$GREEN"
}

# ======== SERVICE TÂCHES (Node.js/Express) ==========
setup_task_service() {
    print_message "🔧 Configuration du service de tâches (Node.js/Express)..." "$BLUE"
    
    # Créer et accéder au répertoire du service
    local base_dir="./microservices/task-service"
    ensure_directory "$base_dir"
    cd "$base_dir"
    
    # Création du fichier package.json
    create_file "package.json" '{
  "name": "task-service",
  "version": "1.0.0",
  "description": "Microservice de gestion des tâches",
  "main": "src/app.js",
  "scripts": {
    "start": "node src/app.js",
    "dev": "nodemon src/app.js",
    "test": "echo \\"Error: no test specified\\" && exit 1"
  },
  "author": "Dr. El Hadji Bassirou TOURE",
  "license": "ISC",
  "dependencies": {
    "axios": "^1.6.2",
    "cors": "^2.8.5",
    "dotenv": "^16.3.1",
    "express": "^4.18.2",
    "morgan": "^1.10.0",
    "sequelize": "^6.35.1",
    "sqlite3": "^5.1.6"
  },
  "devDependencies": {
    "nodemon": "^3.0.1"
  }
}'
    
    # Création de la structure des répertoires
    ensure_directory "src/config"
    ensure_directory "src/controllers"
    ensure_directory "src/models"
    ensure_directory "src/routes"
    ensure_directory "src/services"
    ensure_directory "data"
    
    # Création du fichier de configuration de la BDD
    create_file "src/config/database.js" 'const { Sequelize } = require("sequelize");
const path = require("path");

// Configure la base de données SQLite
const sequelize = new Sequelize({
  dialect: "sqlite",
  storage: path.join(__dirname, "../../data/tasks.sqlite"),
  logging: false,
});

// Fonction pour tester la connexion à la base de données
const testConnection = async () => {
  try {
    await sequelize.authenticate();
    console.log("Connection to database established successfully.");
    return true;
  } catch (error) {
    console.error("Unable to connect to the database:", error);
    return false;
  }
};

module.exports = sequelize;
module.exports.testConnection = testConnection;'
    
    # Création du modèle de tâche
    create_file "src/models/Task.js" 'const { DataTypes } = require("sequelize");
const sequelize = require("../config/database");

const Task = sequelize.define(
  "Task",
  {
    id: {
      type: DataTypes.INTEGER,
      primaryKey: true,
      autoIncrement: true,
    },
    title: {
      type: DataTypes.STRING,
      allowNull: false,
    },
    description: {
      type: DataTypes.TEXT,
      allowNull: true,
    },
    dueDate: {
      type: DataTypes.DATE,
      allowNull: true,
    },
    completed: {
      type: DataTypes.BOOLEAN,
      defaultValue: false,
    },
    userId: {
      type: DataTypes.INTEGER,
      allowNull: false,
    },
  },
  {
    timestamps: true,
  }
);

module.exports = Task;'
    
    # Création du service utilisateur
    create_file "src/services/userService.js" 'const axios = require("axios");

// User service URL (use localhost in development)
const USER_SERVICE_URL =
  process.env.NODE_ENV === "production"
    ? "http://user-service:8081"
    : "http://localhost:8081";

const checkUserExists = async (userId) => {
  try {
    const response = await axios.get(`${USER_SERVICE_URL}/api/users/${userId}`);
    return response.status === 200;
  } catch (error) {
    console.error("Error checking user existence:", error.message);
    return false;
  }
};

module.exports = {
  checkUserExists,
};'
    
    # Création du contrôleur de tâches
    create_file "src/controllers/taskController.js" 'const Task = require("../models/Task");
const userService = require("../services/userService");

const createTask = async (req, res) => {
  try {
    const { title, description, dueDate, userId } = req.body;

    // Check if the user exists
    const userExists = await userService.checkUserExists(userId);
    if (!userExists) {
      return res.status(404).json({ error: "User not found" });
    }

    // Create the task
    const task = await Task.create({
      title,
      description,
      dueDate,
      userId,
    });

    res.status(201).json(task);
  } catch (error) {
    console.error("Error creating task:", error);
    res.status(500).json({ error: "Error creating task" });
  }
};

const getTasksByUserId = async (req, res) => {
  try {
    const { userId } = req.params;

    // Check if the user exists
    const userExists = await userService.checkUserExists(userId);
    if (!userExists) {
      return res.status(404).json({ error: "User not found" });
    }

    const tasks = await Task.findAll({ where: { userId } });

    res.status(200).json(tasks);
  } catch (error) {
    console.error("Error retrieving user tasks:", error);
    res.status(500).json({ error: "Error retrieving user tasks" });
  }
};

const getAllTasks = async (req, res) => {
  try {
    const tasks = await Task.findAll();
    res.status(200).json(tasks);
  } catch (error) {
    console.error("Error retrieving all tasks:", error);
    res.status(500).json({ error: "Error retrieving all tasks" });
  }
};

const getTaskById = async (req, res) => {
  try {
    const { id } = req.params;
    const task = await Task.findByPk(id);
    
    if (!task) {
      return res.status(404).json({ error: "Task not found" });
    }
    
    res.status(200).json(task);
  } catch (error) {
    console.error("Error retrieving task:", error);
    res.status(500).json({ error: "Error retrieving task" });
  }
};

const updateTask = async (req, res) => {
  try {
    const { id } = req.params;
    const { title, description, dueDate, completed } = req.body;
    
    const task = await Task.findByPk(id);
    
    if (!task) {
      return res.status(404).json({ error: "Task not found" });
    }
    
    if (title) task.title = title;
    if (description !== undefined) task.description = description;
    if (dueDate) task.dueDate = dueDate;
    if (completed !== undefined) task.completed = completed;
    
    await task.save();
    
    res.status(200).json(task);
  } catch (error) {
    console.error("Error updating task:", error);
    res.status(500).json({ error: "Error updating task" });
  }
};

const deleteTask = async (req, res) => {
  try {
    const { id } = req.params;
    
    const task = await Task.findByPk(id);
    
    if (!task) {
      return res.status(404).json({ error: "Task not found" });
    }
    
    await task.destroy();
    
    res.status(200).json({ message: "Task deleted successfully" });
  } catch (error) {
    console.error("Error deleting task:", error);
    res.status(500).json({ error: "Error deleting task" });
  }
};

module.exports = {
  createTask,
  getTasksByUserId,
  getAllTasks,
  getTaskById,
  updateTask,
  deleteTask,
};'
    
    # Création des routes
    create_file "src/routes/taskRoutes.js" 'const express = require("express");
const taskController = require("../controllers/taskController");

const router = express.Router();

// Routes pour les tâches
router.post("/tasks", taskController.createTask);
router.get("/tasks", taskController.getAllTasks);
router.get("/tasks/:id", taskController.getTaskById);
router.put("/tasks/:id", taskController.updateTask);
router.delete("/tasks/:id", taskController.deleteTask);

// Routes pour les tâches d'un utilisateur spécifique
router.get("/users/:userId/tasks", taskController.getTasksByUserId);

module.exports = router;'
    
    # Création du fichier d'application principal
    create_file "src/app.js" 'const express = require("express");
const cors = require("cors");
const morgan = require("morgan");
const sequelize = require("./config/database");
const taskRoutes = require("./routes/taskRoutes");

// Initialisation de l\'app Express
const app = express();
const PORT = process.env.PORT || 8082;

// Middleware
app.use(cors());
app.use(express.json());
app.use(morgan("dev"));

// Routes
app.use("/api", taskRoutes);

// Route de test
app.get("/health", (req, res) => {
  res.status(200).json({ status: "OK", message: "Task service is running" });
});

// Synchronisation de la base de données et démarrage du serveur
const startServer = async () => {
  try {
    await sequelize.sync({ alter: true });
    console.log("Database synchronized successfully");
    
    app.listen(PORT, () => {
      console.log(`Task service running on port ${PORT}`);
    });
  } catch (error) {
    console.error("Failed to start server:", error);
  }
};

startServer();'
    
    # Création du fichier .env
    create_file ".env" 'PORT=8082
NODE_ENV=development'
    
    # Création du Dockerfile
    create_file "Dockerfile" 'FROM node:18-alpine

WORKDIR /app

COPY package*.json ./

RUN npm install

COPY . .

# Créer le dossier de données s\'il n\'existe pas
RUN mkdir -p /app/data

EXPOSE 8082

CMD ["npm", "start"]'
    
    # Revenir au répertoire principal
    cd ../..
    
    print_message "✅ Configuration du service de tâches terminée." "$GREEN"
}

# ======== SERVICE NOTIFICATIONS (Python/Flask) ==========
setup_notification_service() {
    print_message "🔧 Configuration du service de notifications (Python/Flask)..." "$BLUE"
    
    # Créer et accéder au répertoire du service
    local base_dir="./microservices/notification-service"
    ensure_directory "$base_dir"
    cd "$base_dir"
    
    # Création de la structure des répertoires
    ensure_directory "models"
    ensure_directory "services"
    ensure_directory "routes"
    ensure_directory "data"
    
    # Création du fichier requirements.txt
    create_file "requirements.txt" 'Flask==2.3.3
Flask-Cors==4.0.0
Flask-SQLAlchemy==3.1.1
requests==2.31.0
python-dotenv==1.0.0
gunicorn==21.2.0'
    
    # Création du fichier app.py
    create_file "app.py" 'import os
from flask import Flask
from flask_cors import CORS
from flask_sqlalchemy import SQLAlchemy
import logging

# Configuration du logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Initialisation de l\'application Flask
app = Flask(__name__)
CORS(app)

# Configuration de la base de données
app.config[\'SQLALCHEMY_DATABASE_URI\'] = \'sqlite:///data/notifications.db\'
app.config[\'SQLALCHEMY_TRACK_MODIFICATIONS\'] = False

# Initialisation de SQLAlchemy
db = SQLAlchemy(app)

# Import des modèles (après l\'initialisation de db)
from models.notification import Notification

# Import des routes
from routes.notification_routes import notification_bp

# Enregistrement des blueprints
app.register_blueprint(notification_bp, url_prefix=\'/api/notifications\')

@app.route(\'/health\')
def health_check():
    return {\'status\': \'OK\', \'message\': \'Notification service is running\'}, 200

if __name__ == \'__main__\':
    # Création des tables si elles n\'existent pas
    with app.app_context():
        logger.info("Creating database tables...")
        db.create_all()
        logger.info("Database tables created.")
    
    # Démarrage du serveur
    port = int(os.environ.get(\'PORT\', 8083))
    app.run(host=\'0.0.0.0\', port=port, debug=os.environ.get(\'FLASK_ENV\') == \'development\')'
    
    # Création du modèle notification
    create_file "models/notification.py" 'from datetime import datetime
from app import db

class Notification(db.Model):
    __tablename__ = \'notifications\'

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

    def to_dict(self):
        return {
            \'id\': self.id,
            \'user_id\': self.user_id,
            \'task_id\': self.task_id,
            \'message\': self.message,
            \'created_at\': self.created_at.isoformat() if self.created_at else None,
            \'read\': self.read
        }'
    
    # Création du service de tâches
    create_file "services/task_service.py" 'import requests
import os
from datetime import datetime, timedelta

# Task service URL
TASK_SERVICE_URL = \'http://task-service:8082\' if os.environ.get(\'FLASK_ENV\') == \'production\' else \'http://localhost:8082\'

def get_task(task_id):
    """
    Get a task by ID from the task service
    """
    try:
        response = requests.get(f\'{TASK_SERVICE_URL}/api/tasks/{task_id}\')
        if response.status_code == 200:
            return response.json()
        return None
    except Exception as e:
        print(f"Error retrieving task: {e}")
        return None

def get_tasks_due_soon(days=1):
    """
    Get tasks due soon
    """
    try:
        # Get all tasks
        response = requests.get(f\'{TASK_SERVICE_URL}/api/tasks\')
        if response.status_code != 200:
            return []

        tasks = response.json()
        now = datetime.utcnow()
        due_date_limit = now + timedelta(days=days)

        # Filter tasks due soon and not completed
        due_soon_tasks = []
        for task in tasks:
            if not task.get(\'completed\'):
                due_date_str = task.get(\'dueDate\')
                if due_date_str:
                    due_date = datetime.fromisoformat(due_date_str.replace(\'Z\', \'+00:00\'))
                    if now <= due_date <= due_date_limit:
                        due_soon_tasks.append(task)

        return due_soon_tasks
    except Exception as e:
        print(f"Error retrieving tasks due soon: {e}")
        return []'
    
    # Création du service utilisateur
    create_file "services/user_service.py" 'import requests
import os

# User service URL
USER_SERVICE_URL = \'http://user-service:8081\' if os.environ.get(\'FLASK_ENV\') == \'production\' else \'http://localhost:8081\'

def get_user(user_id):
    """
    Get a user by ID from the user service
    """
    try:
        response = requests.get(f\'{USER_SERVICE_URL}/api/users/{user_id}\')
        if response.status_code == 200:
            return response.json()
        return None
    except Exception as e:
        print(f"Error retrieving user: {e}")
        return None'
    
    # Création du service de notification
    create_file "services/notification_service.py" 'from models.notification import Notification
from services import user_service, task_service
from app import db

def check_due_tasks():
    """
    Check tasks due soon and create notifications
    """
    try:
        # Get tasks due soon
        due_soon_tasks = task_service.get_tasks_due_soon()

        created_notifications = []

        for task in due_soon_tasks:
            user_id = task.get(\'userId\')
            task_id = task.get(\'id\')

            # Check if notification already exists
            existing = Notification.query.filter_by(task_id=task_id, read=False).first()
            if existing:
                continue

            # Create notification message
            message = f"Task \'{task.get(\"title\")}\' is due soon!"

            # Create notification
            notification = Notification(user_id=user_id, task_id=task_id, message=message)
            db.session.add(notification)
            db.session.commit()
            
            created_notifications.append(notification.to_dict())

        return created_notifications
    except Exception as e:
        db.session.rollback()
        print(f"Error checking due tasks: {e}")
        return []

def get_notifications_by_user(user_id):
    """
    Get all notifications for a user
    """
    try:
        notifications = Notification.query.filter_by(user_id=user_id).order_by(Notification.created_at.desc()).all()
        return [notification.to_dict() for notification in notifications]
    except Exception as e:
        print(f"Error retrieving notifications: {e}")
        return []

def mark_notification_as_read(notification_id):
    """
    Mark a notification as read
    """
    try:
        notification = Notification.query.get(notification_id)
        if not notification:
            return False
            
        notification.read = True
        db.session.commit()
        return True
    except Exception as e:
        db.session.rollback()
        print(f"Error marking notification as read: {e}")
        return False'
    
    # Création des routes pour les notifications
    create_file "routes/notification_routes.py" 'from flask import Blueprint, jsonify, request
from services import notification_service, user_service

notification_bp = Blueprint(\'notifications\', __name__)

@notification_bp.route(\'/check-due-tasks\', methods=[\'POST\'])
def check_due_tasks():
    """
    Check for tasks due soon and create notifications
    """
    notifications = notification_service.check_due_tasks()
    return jsonify(notifications), 200

@notification_bp.route(\'/user/<int:user_id>\', methods=[\'GET\'])
def get_user_notifications(user_id):
    """
    Get all notifications for a user
    """
    # Check if user exists
    user = user_service.get_user(user_id)
    if not user:
        return jsonify({\'error\': \'User not found\'}), 404
        
    notifications = notification_service.get_notifications_by_user(user_id)
    return jsonify(notifications), 200

@notification_bp.route(\'/<int:notification_id>/read\', methods=[\'PUT\'])
def mark_notification_read(notification_id):
    """
    Mark a notification as read
    """
    success = notification_service.mark_notification_as_read(notification_id)
    if success:
        return jsonify({\'message\': \'Notification marked as read\'}), 200
    else:
        return jsonify({\'error\': \'Notification not found or could not be updated\'}), 404'
    
    # Création du fichier .env
    create_file ".env" 'FLASK_APP=app.py
FLASK_ENV=development
PORT=8083'
    
    # Création du Dockerfile
    create_file "Dockerfile" 'FROM python:3.9-slim

WORKDIR /app

COPY requirements.txt .

RUN pip install --no-cache-dir -r requirements.txt

COPY . .

# Créer le dossier de données s\'il n\'existe pas
RUN mkdir -p /app/data

EXPOSE 8083

ENV FLASK_ENV=production

CMD ["python", "app.py"]'
    
    # Création du .gitignore
    create_file ".gitignore" '# Environnement virtuel
venv/
env/
__pycache__/

# Base de données
*.db
data/

# Fichiers environnement
.env

# Logs
*.log

# Fichiers système
.DS_Store'
    
    # Revenir au répertoire principal
    cd ../..
    
    print_message "✅ Configuration du service de notifications terminée." "$GREEN"
}

# ======== CONFIGURATION DE DOCKER COMPOSE ==========
setup_docker_compose() {
    print_message "🔧 Configuration de Docker Compose..." "$BLUE"
    
    # Vérifier si docker-compose.yml existe, sinon le créer
    create_file "docker-compose.yml" 'version: "3"

services:
  user-service:
    build: ./microservices/user-service
    container_name: microservices-user-service
    ports:
      - "8081:8081"
    volumes:
      - ./microservices/user-service/data:/app/data
    networks:
      - microservices-network
    restart: always
    environment:
      - SPRING_PROFILES_ACTIVE=prod

  task-service:
    build: ./microservices/task-service
    container_name: microservices-task-service
    ports:
      - "8082:8082"
    volumes:
      - ./microservices/task-service/data:/app/data
    networks:
      - microservices-network
    depends_on:
      - user-service
    restart: always
    environment:
      - NODE_ENV=production

  notification-service:
    build: ./microservices/notification-service
    container_name: microservices-notification-service
    ports:
      - "8083:8083"
    volumes:
      - ./microservices/notification-service/data:/app/data
    networks:
      - microservices-network
    depends_on:
      - user-service
      - task-service
    restart: always
    environment:
      - FLASK_ENV=production

  frontend:
    build: ./microservices/frontend
    container_name: microservices-frontend
    ports:
      - "3000:3000"
    networks:
      - microservices-network
    depends_on:
      - user-service
      - task-service
      - notification-service
    restart: always

networks:
  microservices-network:
    driver: bridge'
    
    print_message "✅ Configuration de Docker Compose terminée." "$GREEN"
}

# =========== Fonction pour démarrer les services =================
start_services() {
    print_message "🚀 Démarrage des services..." "$BLUE"
    
    # Construire et démarrer les conteneurs
    docker-compose up --build -d
    
    # Vérifier si tous les conteneurs sont en cours d'exécution
    sleep 5  # Attendre que les conteneurs démarrent
    
    if [ $(docker-compose ps -q | wc -l) -ge 3 ]; then
        print_message "✅ Les services principaux ont été démarrés avec succès!" "$GREEN"
        print_message "📊 Tableau de bord des services:" "$BLUE"
        print_message "- Service Utilisateurs: http://localhost:8081" "$YELLOW"
        print_message "- Service Tâches: http://localhost:8082" "$YELLOW"
        print_message "- Service Notifications: http://localhost:8083" "$YELLOW"
        print_message "- Frontend: http://localhost:3000 (Interface principale)" "$YELLOW"
    else
        print_message "⚠️ Certains services n'ont pas démarré correctement. Vérifiez les logs avec 'docker-compose logs'" "$RED"
    fi
}

# ====================== Fonction d'aide =========================
show_help() {
    echo "Usage: $0 [options]"
    echo ""
    echo "Options:"
    echo "  -h, --help                Affiche cette aide"
    echo "  -c, --clean               Nettoie les builds précédents"
    echo "  -s, --setup               Configure uniquement les services sans les démarrer"
    echo "  -r, --run                 Démarre les services sans reconfiguration"
    echo "  --logs                    Affiche les logs des services en cours d'exécution"
    echo "  --stop                    Arrête tous les services"
    echo ""
    echo "Sans option, le script va configurer et démarrer tous les services."
}

# ====================== Traitement des arguments =================
case "$1" in
    -h|--help)
        show_help
        exit 0
        ;;
    -c|--clean)
        clean_previous_builds
        exit 0
        ;;
    -s|--setup)
        check_prerequisites
        setup_user_service
        setup_task_service
        setup_notification_service
        setup_docker_compose
        print_message "🎉 Configuration terminée! Utilisez '$0' pour démarrer les services." "$GREEN"
        exit 0
        ;;
    -r|--run)
        check_prerequisites
        start_services
        exit 0
        ;;
    --logs)
        docker-compose logs -f
        exit 0
        ;;
    --stop)
        docker-compose down
        print_message "⏹️ Tous les services ont été arrêtés." "$GREEN"
        exit 0
        ;;
    "")
        # Aucune option, exécuter le processus complet
        ;;
    *)
        print_message "❌ Option invalide: $1" "$RED"
        show_help
        exit 1
        ;;
esac

# ====================== Processus principal =====================
print_message "🚀 Démarrage du processus de configuration et déploiement..." "$BLUE"

# Vérifier les prérequis
check_prerequisites

# Nettoyer les builds précédents
clean_previous_builds

# Configurer les services
setup_user_service
setup_task_service
setup_notification_service
setup_docker_compose

# Démarrer les services
start_services

print_message "🎉 Installation et démarrage terminés!" "$GREEN"
print_message "Utilisez '$0 --logs' pour voir les logs des services en temps réel." "$BLUE"
print_message "Utilisez '$0 --stop' pour arrêter tous les services." "$BLUE"