#!/bin/bash

# Script de génération des codes de départ pour le TP1 - Architecture Logicielles Modernes
# Ce script crée:
# 1. Une application monolithique fonctionnelle (avec Gradle)
# 2. La structure des microservices avec les TODOs à compléter

echo "Création de la structure du projet..."

# Création des répertoires principaux
mkdir -p microservices-todo/{monolith/src/main/java/com/fst/dmi/monolith/{model,repository,service,controller,config},monolith/src/main/resources/{static,templates},microservices/{user-service/{src/main/java/com/fst/dmi/userservice/{model,repository,service,controller,config},src/main/resources},task-service/{config,controllers,models,routes,services},notification-service/{models,services,routes}}}

# ====================================================
# APPLICATION MONOLITHIQUE (FONCTIONNELLE À 100%)
# ====================================================

# Création du fichier build.gradle
cat > microservices-todo/monolith/build.gradle << 'EOF'
plugins {
    id 'org.springframework.boot' version '3.1.5'
    id 'io.spring.dependency-management' version '1.1.3'
    id 'java'
}

group = 'com.fst.dmi'
version = '0.0.1-SNAPSHOT'
sourceCompatibility = '17'

repositories {
    mavenCentral()
}

dependencies {
    implementation 'org.springframework.boot:spring-boot-starter-data-jpa'
    implementation 'org.springframework.boot:spring-boot-starter-thymeleaf'
    implementation 'org.springframework.boot:spring-boot-starter-web'
    implementation 'org.springframework.boot:spring-boot-starter-validation'
    implementation 'org.springframework.boot:spring-boot-starter-security'
    implementation 'org.thymeleaf.extras:thymeleaf-extras-springsecurity6'
    runtimeOnly 'com.h2database:h2'
    developmentOnly 'org.springframework.boot:spring-boot-devtools'
    testImplementation 'org.springframework.boot:spring-boot-starter-test'
}

test {
    useJUnitPlatform()
}
EOF

# Création du fichier application.properties
cat > microservices-todo/monolith/src/main/resources/application.properties << 'EOF'
# Server configuration
server.port=8080

# H2 Database configuration
spring.datasource.url=jdbc:h2:file:./data/tododb
spring.datasource.driverClassName=org.h2.Driver
spring.datasource.username=sa
spring.datasource.password=password
spring.jpa.database-platform=org.hibernate.dialect.H2Dialect

# Enable H2 console (for development)
spring.h2.console.enabled=true
spring.h2.console.path=/h2-console
spring.h2.console.settings.web-allow-others=true

# JPA configuration
spring.jpa.hibernate.ddl-auto=update
spring.jpa.show-sql=true

# Thymeleaf Configuration
spring.thymeleaf.cache=false
EOF

# Création des modèles
cat > microservices-todo/monolith/src/main/java/com/fst/dmi/monolith/model/User.java << 'EOF'
package com.fst.dmi.monolith.model;

import jakarta.persistence.*;
import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

@Entity
@Table(name = "users")
public class User {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @NotBlank
    @Column(nullable = false, unique = true)
    private String username;

    @NotBlank
    @Email
    @Column(nullable = false, unique = true)
    private String email;

    @NotBlank
    @Column(nullable = false)
    private String password;

    @Column(nullable = false)
    private LocalDateTime createdAt;

    @OneToMany(mappedBy = "user", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<Task> tasks = new ArrayList<>();

    // Constructors
    public User() {
        this.createdAt = LocalDateTime.now();
    }

    public User(String username, String email, String password) {
        this.username = username;
        this.email = email;
        this.password = password;
        this.createdAt = LocalDateTime.now();
    }

    // Getters and Setters
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

    public List<Task> getTasks() {
        return tasks;
    }

    public void setTasks(List<Task> tasks) {
        this.tasks = tasks;
    }

    // Helper methods
    public void addTask(Task task) {
        tasks.add(task);
        task.setUser(this);
    }

    public void removeTask(Task task) {
        tasks.remove(task);
        task.setUser(null);
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
}
EOF

cat > microservices-todo/monolith/src/main/java/com/fst/dmi/monolith/model/Task.java << 'EOF'
package com.fst.dmi.monolith.model;

import jakarta.persistence.*;
import jakarta.validation.constraints.NotBlank;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

@Entity
@Table(name = "tasks")
public class Task {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @NotBlank
    @Column(nullable = false)
    private String title;

    @Column(length = 1000)
    private String description;

    @Column(nullable = false)
    private LocalDateTime createdAt;

    @Column
    private LocalDateTime dueDate;

    @Column(nullable = false)
    private boolean completed = false;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    @OneToMany(mappedBy = "task", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<Notification> notifications = new ArrayList<>();

    // Constructors
    public Task() {
        this.createdAt = LocalDateTime.now();
    }

    public Task(String title, String description, LocalDateTime dueDate, User user) {
        this.title = title;
        this.description = description;
        this.dueDate = dueDate;
        this.user = user;
        this.createdAt = LocalDateTime.now();
    }

    // Getters and Setters
    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }

    public LocalDateTime getDueDate() {
        return dueDate;
    }

    public void setDueDate(LocalDateTime dueDate) {
        this.dueDate = dueDate;
    }

    public boolean isCompleted() {
        return completed;
    }

    public void setCompleted(boolean completed) {
        this.completed = completed;
    }

    public User getUser() {
        return user;
    }

    public void setUser(User user) {
        this.user = user;
    }

    public List<Notification> getNotifications() {
        return notifications;
    }

    public void setNotifications(List<Notification> notifications) {
        this.notifications = notifications;
    }

    // Helper methods
    public void addNotification(Notification notification) {
        notifications.add(notification);
        notification.setTask(this);
    }

    public boolean isDueSoon(int days) {
        if (dueDate == null) return false;
        LocalDateTime now = LocalDateTime.now();
        LocalDateTime threshold = now.plusDays(days);
        return !completed && dueDate.isAfter(now) && dueDate.isBefore(threshold);
    }

    @Override
    public String toString() {
        return "Task{" +
                "id=" + id +
                ", title='" + title + '\'' +
                ", dueDate=" + dueDate +
                ", completed=" + completed +
                '}';
    }
}
EOF

cat > microservices-todo/monolith/src/main/java/com/fst/dmi/monolith/model/Notification.java << 'EOF'
package com.fst.dmi.monolith.model;

import jakarta.persistence.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "notifications")
public class Notification {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private String message;

    @Column(nullable = false)
    private LocalDateTime createdAt;

    @Column(nullable = false)
    private boolean read = false;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "task_id", nullable = false)
    private Task task;

    // Constructors
    public Notification() {
        this.createdAt = LocalDateTime.now();
    }

    public Notification(String message, Task task) {
        this.message = message;
        this.task = task;
        this.createdAt = LocalDateTime.now();
    }

    // Getters and Setters
    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public String getMessage() {
        return message;
    }

    public void setMessage(String message) {
        this.message = message;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }

    public boolean isRead() {
        return read;
    }

    public void setRead(boolean read) {
        this.read = read;
    }

    public Task getTask() {
        return task;
    }

    public void setTask(Task task) {
        this.task = task;
    }

    @Override
    public String toString() {
        return "Notification{" +
                "id=" + id +
                ", message='" + message + '\'' +
                ", createdAt=" + createdAt +
                ", read=" + read +
                '}';
    }
}
EOF

# Création des repositories
cat > microservices-todo/monolith/src/main/java/com/fst/dmi/monolith/repository/UserRepository.java << 'EOF'
package com.fst.dmi.monolith.repository;

import com.fst.dmi.monolith.model.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface UserRepository extends JpaRepository<User, Long> {
    User findByUsername(String username);
    User findByEmail(String email);
    boolean existsByUsername(String username);
    boolean existsByEmail(String email);
}
EOF

cat > microservices-todo/monolith/src/main/java/com/fst/dmi/monolith/repository/TaskRepository.java << 'EOF'
package com.fst.dmi.monolith.repository;

import com.fst.dmi.monolith.model.Task;
import com.fst.dmi.monolith.model.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;

@Repository
public interface TaskRepository extends JpaRepository<Task, Long> {
    List<Task> findByUser(User user);
    List<Task> findByUserOrderByDueDateAsc(User user);
    List<Task> findByCompletedFalseAndDueDateBefore(LocalDateTime date);
    List<Task> findByCompletedFalseAndDueDateBetween(LocalDateTime start, LocalDateTime end);
}
EOF

cat > microservices-todo/monolith/src/main/java/com/fst/dmi/monolith/repository/NotificationRepository.java << 'EOF'
package com.fst.dmi.monolith.repository;

import com.fst.dmi.monolith.model.Notification;
import com.fst.dmi.monolith.model.Task;
import com.fst.dmi.monolith.model.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface NotificationRepository extends JpaRepository<Notification, Long> {
    List<Notification> findByTask(Task task);
    
    @Query("SELECT n FROM Notification n WHERE n.task.user = ?1 ORDER BY n.createdAt DESC")
    List<Notification> findByUser(User user);
    
    @Query("SELECT COUNT(n) FROM Notification n WHERE n.task.user = ?1 AND n.read = false")
    long countUnreadByUser(User user);
    
    boolean existsByTaskAndReadFalse(Task task);
}
EOF

# Création des services
cat > microservices-todo/monolith/src/main/java/com/fst/dmi/monolith/service/UserService.java << 'EOF'
package com.fst.dmi.monolith.service;

import com.fst.dmi.monolith.model.User;
import com.fst.dmi.monolith.repository.UserRepository;
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
        if (userRepository.existsByUsername(user.getUsername())) {
            throw new RuntimeException("Username already exists");
        }
        if (userRepository.existsByEmail(user.getEmail())) {
            throw new RuntimeException("Email already exists");
        }
        
        user.setPassword(passwordEncoder.encode(user.getPassword()));
        return userRepository.save(user);
    }

    public Optional<User> findById(Long id) {
        return userRepository.findById(id);
    }

    public User findByUsername(String username) {
        return userRepository.findByUsername(username);
    }

    public List<User> findAll() {
        return userRepository.findAll();
    }

    public User updateUser(User user) {
        return userRepository.save(user);
    }

    public void deleteUser(Long id) {
        userRepository.deleteById(id);
    }

    public boolean authenticateUser(String username, String password) {
        User user = userRepository.findByUsername(username);
        if (user == null) {
            return false;
        }
        return passwordEncoder.matches(password, user.getPassword());
    }
}
EOF

cat > microservices-todo/monolith/src/main/java/com/fst/dmi/monolith/service/TaskService.java << 'EOF'
package com.fst.dmi.monolith.service;

import com.fst.dmi.monolith.model.Task;
import com.fst.dmi.monolith.model.User;
import com.fst.dmi.monolith.repository.TaskRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

@Service
public class TaskService {

    private final TaskRepository taskRepository;
    private final NotificationService notificationService;

    @Autowired
    public TaskService(TaskRepository taskRepository, NotificationService notificationService) {
        this.taskRepository = taskRepository;
        this.notificationService = notificationService;
    }

    public Task createTask(Task task) {
        Task savedTask = taskRepository.save(task);
        
        // Check if task has a due date soon and create notification if needed
        if (savedTask.getDueDate() != null && savedTask.isDueSoon(7)) {
            notificationService.createTaskDueNotification(savedTask);
        }
        
        return savedTask;
    }

    public Optional<Task> findById(Long id) {
        return taskRepository.findById(id);
    }

    public List<Task> findAllByUser(User user) {
        return taskRepository.findByUserOrderByDueDateAsc(user);
    }

    public List<Task> findAll() {
        return taskRepository.findAll();
    }

    public Task updateTask(Task task) {
        return taskRepository.save(task);
    }

    public void deleteTask(Long id) {
        taskRepository.deleteById(id);
    }
    
    public List<Task> findTasksDueSoon(int days) {
        LocalDateTime now = LocalDateTime.now();
        LocalDateTime threshold = now.plusDays(days);
        return taskRepository.findByCompletedFalseAndDueDateBetween(now, threshold);
    }

    public void completeTask(Long id) {
        Optional<Task> taskOpt = taskRepository.findById(id);
        if (taskOpt.isPresent()) {
            Task task = taskOpt.get();
            task.setCompleted(true);
            taskRepository.save(task);
        }
    }
}
EOF

cat > microservices-todo/monolith/src/main/java/com/fst/dmi/monolith/service/NotificationService.java << 'EOF'
package com.fst.dmi.monolith.service;

import com.fst.dmi.monolith.model.Notification;
import com.fst.dmi.monolith.model.Task;
import com.fst.dmi.monolith.model.User;
import com.fst.dmi.monolith.repository.NotificationRepository;
import com.fst.dmi.monolith.repository.TaskRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

@Service
public class NotificationService {

    private final NotificationRepository notificationRepository;
    private final TaskRepository taskRepository;

    @Autowired
    public NotificationService(NotificationRepository notificationRepository, TaskRepository taskRepository) {
        this.notificationRepository = notificationRepository;
        this.taskRepository = taskRepository;
    }

    public Notification createNotification(Notification notification) {
        return notificationRepository.save(notification);
    }

    public Notification createTaskDueNotification(Task task) {
        // Check if there's already an unread notification for this task
        if (notificationRepository.existsByTaskAndReadFalse(task)) {
            return null;
        }
        
        String message = String.format("Task '%s' is due soon (due date: %s)", 
                task.getTitle(), 
                task.getDueDate().toLocalDate().toString());
        
        Notification notification = new Notification(message, task);
        return notificationRepository.save(notification);
    }

    public Optional<Notification> findById(Long id) {
        return notificationRepository.findById(id);
    }

    public List<Notification> findByUser(User user) {
        return notificationRepository.findByUser(user);
    }

    public long countUnreadNotifications(User user) {
        return notificationRepository.countUnreadByUser(user);
    }

    public Notification markAsRead(Long id) {
        Optional<Notification> notificationOpt = notificationRepository.findById(id);
        if (notificationOpt.isPresent()) {
            Notification notification = notificationOpt.get();
            notification.setRead(true);
            return notificationRepository.save(notification);
        }
        return null;
    }

    @Scheduled(cron = "0 0 9 * * ?") // Run at 9:00 AM every day
    public void checkTasksDueToday() {
        // Get tasks due today
        LocalDateTime startOfDay = LocalDateTime.now().toLocalDate().atStartOfDay();
        LocalDateTime endOfDay = startOfDay.plusDays(1).minusNanos(1);
        
        List<Task> tasksDueToday = taskRepository.findByCompletedFalseAndDueDateBetween(startOfDay, endOfDay);
        
        for (Task task : tasksDueToday) {
            if (!notificationRepository.existsByTaskAndReadFalse(task)) {
                String message = String.format("Task '%s' is due today!", task.getTitle());
                Notification notification = new Notification(message, task);
                notificationRepository.save(notification);
            }
        }
    }

    @Scheduled(cron = "0 0 9 * * *") // Run at 9:00 AM every day
    public void checkTasksDueSoon() {
        List<Task> tasksDueSoon = taskRepository.findByCompletedFalseAndDueDateBetween(
                LocalDateTime.now(),
                LocalDateTime.now().plusDays(3)
        );
        
        for (Task task : tasksDueSoon) {
            if (!notificationRepository.existsByTaskAndReadFalse(task)) {
                createTaskDueNotification(task);
            }
        }
    }
}
EOF

# Création des controllers
cat > microservices-todo/monolith/src/main/java/com/fst/dmi/monolith/controller/UserController.java << 'EOF'
package com.fst.dmi.monolith.controller;

import com.fst.dmi.monolith.model.User;
import com.fst.dmi.monolith.service.UserService;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.validation.BindingResult;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

@Controller
public class UserController {

    private final UserService userService;
    private final PasswordEncoder passwordEncoder;

    @Autowired
    public UserController(UserService userService, PasswordEncoder passwordEncoder) {
        this.userService = userService;
        this.passwordEncoder = passwordEncoder;
    }

    @GetMapping("/register")
    public String showRegistrationForm(Model model) {
        model.addAttribute("user", new User());
        return "register";
    }

    @PostMapping("/register")
    public String registerUser(@Valid @ModelAttribute("user") User user, BindingResult bindingResult, Model model, RedirectAttributes redirectAttributes) {
        if (bindingResult.hasErrors()) {
            return "register";
        }

        try {
            userService.createUser(user);
            redirectAttributes.addFlashAttribute("success", "Registration successful! Please login.");
            return "redirect:/login";
        } catch (Exception e) {
            model.addAttribute("error", e.getMessage());
            return "register";
        }
    }

    @GetMapping("/login")
    public String showLoginForm() {
        return "login";
    }

    @GetMapping("/profile")
    public String showProfile(Model model) {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        User user = userService.findByUsername(auth.getName());
        model.addAttribute("user", user);
        return "profile";
    }
}
EOF

cat > microservices-todo/monolith/src/main/java/com/fst/dmi/monolith/controller/TaskController.java << 'EOF'
package com.fst.dmi.monolith.controller;

import com.fst.dmi.monolith.model.Task;
import com.fst.dmi.monolith.model.User;
import com.fst.dmi.monolith.service.TaskService;
import com.fst.dmi.monolith.service.UserService;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.validation.BindingResult;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

@Controller
@RequestMapping("/tasks")
public class TaskController {

    private final TaskService taskService;
    private final UserService userService;

    @Autowired
    public TaskController(TaskService taskService, UserService userService) {
        this.taskService = taskService;
        this.userService = userService;
    }

    @ModelAttribute("currentUser")
    public User getCurrentUser() {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        return userService.findByUsername(auth.getName());
    }

    @GetMapping
    public String listTasks(Model model) {
        User currentUser = getCurrentUser();
        List<Task> tasks = taskService.findAllByUser(currentUser);
        model.addAttribute("tasks", tasks);
        return "task/list";
    }

    @GetMapping("/create")
    public String showCreateForm(Model model) {
        model.addAttribute("task", new Task());
        return "task/create";
    }

    @PostMapping("/create")
    public String createTask(@Valid @ModelAttribute("task") Task task, 
                             BindingResult bindingResult,
                             @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime dueDate,
                             RedirectAttributes redirectAttributes) {
        if (bindingResult.hasErrors()) {
            return "task/create";
        }

        User currentUser = getCurrentUser();
        task.setUser(currentUser);
        task.setDueDate(dueDate);
        
        taskService.createTask(task);
        redirectAttributes.addFlashAttribute("success", "Task created successfully");
        return "redirect:/tasks";
    }

    @GetMapping("/edit/{id}")
    public String showEditForm(@PathVariable Long id, Model model, RedirectAttributes redirectAttributes) {
        Optional<Task> taskOpt = taskService.findById(id);
        
        if (taskOpt.isEmpty()) {
            redirectAttributes.addFlashAttribute("error", "Task not found");
            return "redirect:/tasks";
        }
        
        Task task = taskOpt.get();
        User currentUser = getCurrentUser();
        
        if (!task.getUser().getId().equals(currentUser.getId())) {
            redirectAttributes.addFlashAttribute("error", "You don't have permission to edit this task");
            return "redirect:/tasks";
        }
        
        model.addAttribute("task", task);
        return "task/edit";
    }

    @PostMapping("/edit/{id}")
    public String updateTask(@PathVariable Long id, 
                             @Valid @ModelAttribute("task") Task task,
                             BindingResult bindingResult,
                             @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime dueDate,
                             RedirectAttributes redirectAttributes) {
        if (bindingResult.hasErrors()) {
            return "task/edit";
        }

        Optional<Task> existingTaskOpt = taskService.findById(id);
        
        if (existingTaskOpt.isEmpty()) {
            redirectAttributes.addFlashAttribute("error", "Task not found");
            return "redirect:/tasks";
        }
        
        Task existingTask = existingTaskOpt.get();
        User currentUser = getCurrentUser();
        
        if (!existingTask.getUser().getId().equals(currentUser.getId())) {
            redirectAttributes.addFlashAttribute("error", "You don't have permission to edit this task");
            return "redirect:/tasks";
        }
        
        existingTask.setTitle(task.getTitle());
        existingTask.setDescription(task.getDescription());
        existingTask.setDueDate(dueDate);
        existingTask.setCompleted(task.isCompleted());
        
        taskService.updateTask(existingTask);
        redirectAttributes.addFlashAttribute("success", "Task updated successfully");
        return "redirect:/tasks";
    }

    @PostMapping("/complete/{id}")
    public String completeTask(@PathVariable Long id, RedirectAttributes redirectAttributes) {
        Optional<Task> taskOpt = taskService.findById(id);
        
        if (taskOpt.isEmpty()) {
            redirectAttributes.addFlashAttribute("error", "Task not found");
            return "redirect:/tasks";
        }
        
        Task task = taskOpt.get();
        User currentUser = getCurrentUser();
        
        if (!task.getUser().getId().equals(currentUser.getId())) {
            redirectAttributes.addFlashAttribute("error", "You don't have permission to complete this task");
            return "redirect:/tasks";
        }
        
        task.setCompleted(true);
        taskService.updateTask(task);
        redirectAttributes.addFlashAttribute("success", "Task marked as completed");
        return "redirect:/tasks";
    }

    @PostMapping("/delete/{id}")
    public String deleteTask(@PathVariable Long id, RedirectAttributes redirectAttributes) {
        Optional<Task> taskOpt = taskService.findById(id);
        
        if (taskOpt.isEmpty()) {
            redirectAttributes.addFlashAttribute("error", "Task not found");
            return "redirect:/tasks";
        }
        
        Task task = taskOpt.get();
        User currentUser = getCurrentUser();
        
        if (!task.getUser().getId().equals(currentUser.getId())) {
            redirectAttributes.addFlashAttribute("error", "You don't have permission to delete this task");
            return "redirect:/tasks";
        }
        
        taskService.deleteTask(id);
        redirectAttributes.addFlashAttribute("success", "Task deleted successfully");
        return "redirect:/tasks";
    }
}
EOF

cat > microservices-todo/monolith/src/main/java/com/fst/dmi/monolith/controller/NotificationController.java << 'EOF'
package com.fst.dmi.monolith.controller;

import com.fst.dmi.monolith.model.Notification;
import com.fst.dmi.monolith.model.User;
import com.fst.dmi.monolith.service.NotificationService;
import com.fst.dmi.monolith.service.UserService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import java.util.List;
import java.util.Optional;

@Controller
@RequestMapping("/notifications")
public class NotificationController {

    private final NotificationService notificationService;
    private final UserService userService;

    @Autowired
    public NotificationController(NotificationService notificationService, UserService userService) {
        this.notificationService = notificationService;
        this.userService = userService;
    }

    @ModelAttribute("currentUser")
    public User getCurrentUser() {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        return userService.findByUsername(auth.getName());
    }

    @GetMapping
    public String listNotifications(Model model) {
        User currentUser = getCurrentUser();
        List<Notification> notifications = notificationService.findByUser(currentUser);
        model.addAttribute("notifications", notifications);
        return "notification/list";
    }

    @PostMapping("/mark-read/{id}")
    public String markAsRead(@PathVariable Long id, RedirectAttributes redirectAttributes) {
        Optional<Notification> notificationOpt = notificationService.findById(id);
        
        if (notificationOpt.isEmpty()) {
            redirectAttributes.addFlashAttribute("error", "Notification not found");
            return "redirect:/notifications";
        }
        
        Notification notification = notificationOpt.get();
        User currentUser = getCurrentUser();
        
        if (!notification.getTask().getUser().getId().equals(currentUser.getId())) {
            redirectAttributes.addFlashAttribute("error", "You don't have permission to mark this notification as read");
            return "redirect:/notifications";
        }
        
        notificationService.markAsRead(id);
        redirectAttributes.addFlashAttribute("success", "Notification marked as read");
        return "redirect:/notifications";
    }

    @GetMapping("/count-unread")
    @ResponseBody
    public String getUnreadCount() {
        User currentUser = getCurrentUser();
        long count = notificationService.countUnreadNotifications(currentUser);
        return String.valueOf(count);
    }
}
EOF

cat > microservices-todo/monolith/src/main/java/com/fst/dmi/monolith/controller/HomeController.java << 'EOF'
package com.fst.dmi.monolith.controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;

@Controller
public class HomeController {

    @GetMapping("/")
    public String home() {
        return "redirect:/tasks";
    }
    
    @GetMapping("/index")
    public String index() {
        return "index";
    }
}
EOF

# Configuration de la sécurité
cat > microservices-todo/monolith/src/main/java/com/fst/dmi/monolith/config/SecurityConfig.java << 'EOF'
package com.fst.dmi.monolith.config;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.config.annotation.authentication.builders.AuthenticationManagerBuilder;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.util.matcher.AntPathRequestMatcher;

@Configuration
@EnableWebSecurity
public class SecurityConfig {

    @Autowired
    private UserDetailsService userDetailsService;

    @Bean
    public static PasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder();
    }

    @Bean
    public SecurityFilterChain securityFilterChain(HttpSecurity http) throws Exception {
        http
            .authorizeHttpRequests(authorize -> 
                authorize
                    .requestMatchers("/register/**", "/login/**", "/h2-console/**", "/css/**", "/js/**").permitAll()
                    .anyRequest().authenticated()
            )
            .formLogin(form -> 
                form
                    .loginPage("/login")
                    .loginProcessingUrl("/login")
                    .defaultSuccessUrl("/tasks")
                    .permitAll()
            )
            .logout(logout -> 
                logout
                    .logoutRequestMatcher(new AntPathRequestMatcher("/logout"))
                    .permitAll()
            )
            .headers(headers -> 
                headers.frameOptions().disable()
            )
            .csrf(csrf -> 
                csrf.ignoringRequestMatchers("/h2-console/**")
            );
        
        return http.build();
    }

    @Autowired
    public void configureGlobal(AuthenticationManagerBuilder auth) throws Exception {
        auth
            .userDetailsService(userDetailsService)
            .passwordEncoder(passwordEncoder());
    }
}
EOF

cat > microservices-todo/monolith/src/main/java/com/fst/dmi/monolith/config/CustomUserDetailsService.java << 'EOF'
package com.fst.dmi.monolith.config;

import com.fst.dmi.monolith.model.User;
import com.fst.dmi.monolith.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Service;

import java.util.Collections;

@Service
public class CustomUserDetailsService implements UserDetailsService {

    @Autowired
    private UserRepository userRepository;

    @Override
    public UserDetails loadUserByUsername(String username) throws UsernameNotFoundException {
        User user = userRepository.findByUsername(username);
        if (user == null) {
            throw new UsernameNotFoundException("User not found with username: " + username);
        }
        
        return new org.springframework.security.core.userdetails.User(
            user.getUsername(),
            user.getPassword(),
            Collections.singletonList(new SimpleGrantedAuthority("ROLE_USER"))
        );
    }
}
EOF

# Application principale
cat > microservices-todo/monolith/src/main/java/com/fst/dmi/monolith/MonolithApplication.java << 'EOF'
package com.fst.dmi.monolith;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.scheduling.annotation.EnableScheduling;

@SpringBootApplication
@EnableScheduling
public class MonolithApplication {

    public static void main(String[] args) {
        SpringApplication.run(MonolithApplication.class, args);
    }
}
EOF

# Dockerfile pour le monolithe
cat > microservices-todo/monolith/Dockerfile << 'EOF'
FROM eclipse-temurin:17-jdk-alpine as build
WORKDIR /workspace/app

COPY . .
RUN ./gradlew build -x test

FROM eclipse-temurin:17-jre-alpine
VOLUME /tmp
COPY --from=build /workspace/app/build/libs/*.jar app.jar
ENTRYPOINT ["java","-jar","/app.jar"]
EOF

# Docker Compose pour le monolithe
cat > microservices-todo/monolith/docker-compose.yml << 'EOF'
version: '3'

services:
  monolith:
    build: .
    ports:
      - "8080:8080"
    volumes:
      - ./data:/app/data
    environment:
      - SPRING_PROFILES_ACTIVE=default
EOF

# Templates Thymeleaf basiques
mkdir -p microservices-todo/monolith/src/main/resources/templates/{task,notification}

cat > microservices-todo/monolith/src/main/resources/templates/index.html << 'EOF'
<!DOCTYPE html>
<html xmlns:th="http://www.thymeleaf.org">
<head>
    <meta charset="UTF-8">
    <title>Todo App</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body>
    <div class="container mt-5">
        <div class="row justify-content-center">
            <div class="col-md-8 text-center">
                <h1>Welcome to Todo App</h1>
                <p class="lead">Manage your tasks efficiently</p>
                <div class="mt-4">
                    <a href="/register" class="btn btn-primary me-2">Register</a>
                    <a href="/login" class="btn btn-outline-primary">Login</a>
                </div>
            </div>
        </div>
    </div>
</body>
</html>
EOF

cat > microservices-todo/monolith/src/main/resources/templates/register.html << 'EOF'
<!DOCTYPE html>
<html xmlns:th="http://www.thymeleaf.org">
<head>
    <meta charset="UTF-8">
    <title>Register - Todo App</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body>
    <div class="container mt-5">
        <div class="row justify-content-center">
            <div class="col-md-6">
                <div class="card">
                    <div class="card-header">
                        <h4 class="text-center">Register</h4>
                    </div>
                    <div class="card-body">
                        <div th:if="${error}" class="alert alert-danger" role="alert" th:text="${error}"></div>
                        <form th:action="@{/register}" th:object="${user}" method="post">
                            <div class="mb-3">
                                <label for="username" class="form-label">Username</label>
                                <input type="text" class="form-control" id="username" th:field="*{username}" required>
                                <div class="text-danger" th:if="${#fields.hasErrors('username')}" th:errors="*{username}"></div>
                            </div>
                            <div class="mb-3">
                                <label for="email" class="form-label">Email</label>
                                <input type="email" class="form-control" id="email" th:field="*{email}" required>
                                <div class="text-danger" th:if="${#fields.hasErrors('email')}" th:errors="*{email}"></div>
                            </div>
                            <div class="mb-3">
                                <label for="password" class="form-label">Password</label>
                                <input type="password" class="form-control" id="password" th:field="*{password}" required>
                                <div class="text-danger" th:if="${#fields.hasErrors('password')}" th:errors="*{password}"></div>
                            </div>
                            <div class="d-grid">
                                <button type="submit" class="btn btn-primary">Register</button>
                            </div>
                        </form>
                    </div>
                    <div class="card-footer text-center">
                        <p class="mb-0">Already have an account? <a th:href="@{/login}">Login</a></p>
                    </div>
                </div>
            </div>
        </div>
    </div>
</body>
</html>
EOF

cat > microservices-todo/monolith/src/main/resources/templates/login.html << 'EOF'
<!DOCTYPE html>
<html xmlns:th="http://www.thymeleaf.org">
<head>
    <meta charset="UTF-8">
    <title>Login - Todo App</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body>
    <div class="container mt-5">
        <div class="row justify-content-center">
            <div class="col-md-6">
                <div class="card">
                    <div class="card-header">
                        <h4 class="text-center">Login</h4>
                    </div>
                    <div class="card-body">
                        <div th:if="${param.error}" class="alert alert-danger" role="alert">
                            Invalid username or password.
                        </div>
                        <div th:if="${param.logout}" class="alert alert-success" role="alert">
                            You have been logged out.
                        </div>
                        <div th:if="${success}" class="alert alert-success" role="alert" th:text="${success}"></div>
                        <form th:action="@{/login}" method="post">
                            <div class="mb-3">
                                <label for="username" class="form-label">Username</label>
                                <input type="text" class="form-control" id="username" name="username" required>
                            </div>
                            <div class="mb-3">
                                <label for="password" class="form-label">Password</label>
                                <input type="password" class="form-control" id="password" name="password" required>
                            </div>
                            <div class="d-grid">
                                <button type="submit" class="btn btn-primary">Login</button>
                            </div>
                        </form>
                    </div>
                    <div class="card-footer text-center">
                        <p class="mb-0">Don't have an account? <a th:href="@{/register}">Register</a></p>
                    </div>
                </div>
            </div>
        </div>
    </div>
</body>
</html>
EOF

cat > microservices-todo/monolith/src/main/resources/templates/profile.html << 'EOF'
<!DOCTYPE html>
<html xmlns:th="http://www.thymeleaf.org" xmlns:sec="http://www.thymeleaf.org/extras/spring-security">
<head>
    <meta charset="UTF-8">
    <title>Profile - Todo App</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body>
    <div th:replace="~{fragments/header :: header}"></div>
    
    <div class="container mt-4">
        <div class="row">
            <div class="col-md-8 offset-md-2">
                <div class="card">
                    <div class="card-header">
                        <h4>User Profile</h4>
                    </div>
                    <div class="card-body">
                        <div class="mb-3">
                            <label class="form-label">Username</label>
                            <input type="text" class="form-control" th:value="${user.username}" readonly>
                        </div>
                        <div class="mb-3">
                            <label class="form-label">Email</label>
                            <input type="email" class="form-control" th:value="${user.email}" readonly>
                        </div>
                        <div class="mb-3">
                            <label class="form-label">Member Since</label>
                            <input type="text" class="form-control" th:value="${#temporals.format(user.createdAt, 'dd MMMM yyyy')}" readonly>
                        </div>
                        <div class="mb-3">
                            <label class="form-label">Total Tasks</label>
                            <input type="text" class="form-control" th:value="${user.tasks.size()}" readonly>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</body>
</html>
EOF

# Fragments for header
mkdir -p microservices-todo/monolith/src/main/resources/templates/fragments

cat > microservices-todo/monolith/src/main/resources/templates/fragments/header.html << 'EOF'
<!DOCTYPE html>
<html xmlns:th="http://www.thymeleaf.org" xmlns:sec="http://www.thymeleaf.org/extras/spring-security">
<head>
    <meta charset="UTF-8">
</head>
<body>
    <header th:fragment="header">
        <nav class="navbar navbar-expand-lg navbar-dark bg-dark">
            <div class="container">
                <a class="navbar-brand" th:href="@{/}">Todo App</a>
                <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarNav">
                    <span class="navbar-toggler-icon"></span>
                </button>
                <div class="collapse navbar-collapse" id="navbarNav">
                    <ul class="navbar-nav me-auto">
                        <li class="nav-item">
                            <a class="nav-link" th:href="@{/tasks}">Tasks</a>
                        </li>
                        <li class="nav-item">
                            <a class="nav-link" th:href="@{/notifications}">
                                Notifications
                                <span class="badge bg-danger" id="notificationBadge"></span>
                            </a>
                        </li>
                    </ul>
                    <ul class="navbar-nav">
                        <li class="nav-item dropdown">
                            <a class="nav-link dropdown-toggle" href="#" role="button" data-bs-toggle="dropdown">
                                <span sec:authentication="name"></span>
                            </a>
                            <ul class="dropdown-menu dropdown-menu-end">
                                <li><a class="dropdown-item" th:href="@{/profile}">Profile</a></li>
                                <li><hr class="dropdown-divider"></li>
                                <li>
                                    <form th:action="@{/logout}" method="post" class="dropdown-item p-0">
                                        <button type="submit" class="btn btn-link text-decoration-none w-100 text-start ps-3">Logout</button>
                                    </form>
                                </li>
                            </ul>
                        </li>
                    </ul>
                </div>
            </div>
        </nav>
        
        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
        <script>
            // Get unread notification count
            function updateNotificationCount() {
                fetch('/notifications/count-unread')
                    .then(response => response.text())
                    .then(count => {
                        const badge = document.getElementById('notificationBadge');
                        if (parseInt(count) > 0) {
                            badge.textContent = count;
                            badge.style.display = 'inline';
                        } else {
                            badge.style.display = 'none';
                        }
                    });
            }
            
            // Update count on page load
            updateNotificationCount();
            
            // Update count every minute
            setInterval(updateNotificationCount, 60000);
        </script>
    </header>
</body>
</html>
EOF

# Task Templates
cat > microservices-todo/monolith/src/main/resources/templates/task/list.html << 'EOF'
<!DOCTYPE html>
<html xmlns:th="http://www.thymeleaf.org">
<head>
    <meta charset="UTF-8">
    <title>Tasks - Todo App</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css">
</head>
<body>
    <div th:replace="~{fragments/header :: header}"></div>
    
    <div class="container mt-4">
        <div class="d-flex justify-content-between align-items-center mb-4">
            <h2>My Tasks</h2>
            <a th:href="@{/tasks/create}" class="btn btn-primary">
                <i class="bi bi-plus-lg"></i> New Task
            </a>
        </div>
        
        <div th:if="${success}" class="alert alert-success" role="alert" th:text="${success}"></div>
        <div th:if="${error}" class="alert alert-danger" role="alert" th:text="${error}"></div>
        
        <div class="card">
            <div class="card-body p-0">
                <div th:if="${#lists.isEmpty(tasks)}" class="p-4 text-center">
                    <p class="mb-0">You don't have any tasks yet. <a th:href="@{/tasks/create}">Create your first task</a>.</p>
                </div>
                <table th:if="${not #lists.isEmpty(tasks)}" class="table table-striped table-hover mb-0">
                    <thead>
                        <tr>
                            <th>Title</th>
                            <th>Due Date</th>
                            <th>Status</th>
                            <th>Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        <tr th:each="task : ${tasks}" th:class="${task.completed ? 'table-success' : (task.dueDate != null && task.dueDate.isBefore(T(java.time.LocalDateTime).now()) ? 'table-danger' : '')}">
                            <td th:text="${task.title}"></td>
                            <td th:text="${task.dueDate != null ? #temporals.format(task.dueDate, 'dd/MM/yyyy HH:mm') : 'No due date'}"></td>
                            <td>
                                <span th:if="${task.completed}" class="badge bg-success">Completed</span>
                                <span th:unless="${task.completed}" class="badge bg-primary">To Do</span>
                            </td>
                            <td>
                                <div class="btn-group btn-group-sm" role="group">
                                    <a th:href="@{/tasks/edit/{id}(id=${task.id})}" class="btn btn-outline-primary">
                                        <i class="bi bi-pencil"></i>
                                    </a>
                                    <form th:unless="${task.completed}" th:action="@{/tasks/complete/{id}(id=${task.id})}" method="post" class="d-inline">
                                        <button type="submit" class="btn btn-outline-success">
                                            <i class="bi bi-check-lg"></i>
                                        </button>
                                    </form>
                                    <form th:action="@{/tasks/delete/{id}(id=${task.id})}" method="post" class="d-inline" 
                                         onsubmit="return confirm('Are you sure you want to delete this task?');">
                                        <button type="submit" class="btn btn-outline-danger">
                                            <i class="bi bi-trash"></i>
                                        </button>
                                    </form>
                                </div>
                            </td>
                        </tr>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</body>
</html>
EOF

cat > microservices-todo/monolith/src/main/resources/templates/task/create.html << 'EOF'
<!DOCTYPE html>
<html xmlns:th="http://www.thymeleaf.org">
<head>
    <meta charset="UTF-8">
    <title>Create Task - Todo App</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body>
    <div th:replace="~{fragments/header :: header}"></div>
    
    <div class="container mt-4">
        <div class="row">
            <div class="col-md-8 offset-md-2">
                <div class="card">
                    <div class="card-header">
                        <h4>Create New Task</h4>
                    </div>
                    <div class="card-body">
                        <form th:action="@{/tasks/create}" th:object="${task}" method="post">
                            <div class="mb-3">
                                <label for="title" class="form-label">Title *</label>
                                <input type="text" class="form-control" id="title" th:field="*{title}" required>
                                <div class="text-danger" th:if="${#fields.hasErrors('title')}" th:errors="*{title}"></div>
                            </div>
                            <div class="mb-3">
                                <label for="description" class="form-label">Description</label>
                                <textarea class="form-control" id="description" th:field="*{description}" rows="3"></textarea>
                            </div>
                            <div class="mb-3">
                                <label for="dueDate" class="form-label">Due Date</label>
                                <input type="datetime-local" class="form-control" id="dueDate" name="dueDate">
                            </div>
                            <div class="d-flex justify-content-between">
                                <a th:href="@{/tasks}" class="btn btn-secondary">Cancel</a>
                                <button type="submit" class="btn btn-primary">Create Task</button>
                            </div>
                        </form>
                    </div>
                </div>
            </div>
        </div>
    </div>
</body>
</html>
EOF

cat > microservices-todo/monolith/src/main/resources/templates/task/edit.html << 'EOF'
<!DOCTYPE html>
<html xmlns:th="http://www.thymeleaf.org">
<head>
    <meta charset="UTF-8">
    <title>Edit Task - Todo App</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body>
    <div th:replace="~{fragments/header :: header}"></div>
    
    <div class="container mt-4">
        <div class="row">
            <div class="col-md-8 offset-md-2">
                <div class="card">
                    <div class="card-header">
                        <h4>Edit Task</h4>
                    </div>
                    <div class="card-body">
                        <form th:action="@{/tasks/edit/{id}(id=${task.id})}" th:object="${task}" method="post">
                            <div class="mb-3">
                                <label for="title" class="form-label">Title *</label>
                                <input type="text" class="form-control" id="title" th:field="*{title}" required>
                                <div class="text-danger" th:if="${#fields.hasErrors('title')}" th:errors="*{title}"></div>
                            </div>
                            <div class="mb-3">
                                <label for="description" class="form-label">Description</label>
                                <textarea class="form-control" id="description" th:field="*{description}" rows="3"></textarea>
                            </div>
                            <div class="mb-3">
                                <label for="dueDate" class="form-label">Due Date</label>
                                <input type="datetime-local" class="form-control" id="dueDate" name="dueDate" th:value="${task.dueDate != null ? task.dueDate : ''}">
                            </div>
                            <div class="mb-3 form-check">
                                <input type="checkbox" class="form-check-input" id="completed" th:field="*{completed}">
                                <label class="form-check-label" for="completed">Mark as completed</label>
                            </div>
                            <div class="d-flex justify-content-between">
                                <a th:href="@{/tasks}" class="btn btn-secondary">Cancel</a>
                                <button type="submit" class="btn btn-primary">Save Changes</button>
                            </div>
                        </form>
                    </div>
                </div>
            </div>
        </div>
    </div>
</body>
</html>
EOF

# Notification Templates
cat > microservices-todo/monolith/src/main/resources/templates/notification/list.html << 'EOF'
<!DOCTYPE html>
<html xmlns:th="http://www.thymeleaf.org">
<head>
    <meta charset="UTF-8">
    <title>Notifications - Todo App</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css">
</head>
<body>
    <div th:replace="~{fragments/header :: header}"></div>
    
    <div class="container mt-4">
        <h2>Notifications</h2>
        
        <div th:if="${success}" class="alert alert-success" role="alert" th:text="${success}"></div>
        <div th:if="${error}" class="alert alert-danger" role="alert" th:text="${error}"></div>
        
        <div class="card">
            <div class="card-body p-0">
                <div th:if="${#lists.isEmpty(notifications)}" class="p-4 text-center">
                    <p class="mb-0">You don't have any notifications.</p>
                </div>
                <div th:if="${not #lists.isEmpty(notifications)}" class="list-group list-group-flush">
                    <div th:each="notification : ${notifications}" class="list-group-item" th:classappend="${notification.read ? '' : 'list-group-item-primary'}">
                        <div class="d-flex justify-content-between align-items-center">
                            <div>
                                <p class="mb-1" th:text="${notification.message}"></p>
                                <small class="text-muted" th:text="${#temporals.format(notification.createdAt, 'dd/MM/yyyy HH:mm')}"></small>
                            </div>
                            <div th:if="${!notification.read}">
                                <form th:action="@{/notifications/mark-read/{id}(id=${notification.id})}" method="post">
                                    <button type="submit" class="btn btn-sm btn-outline-success">
                                        <i class="bi bi-check-lg"></i> Mark as read
                                    </button>
                                </form>
                            </div>
                            <span th:if="${notification.read}" class="badge bg-secondary">Read</span>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</body>
</html>
EOF

# ====================================================
# SERVICES MICROSERVICES (AVEC TODOs)
# ====================================================

# ====================================================
# Service Utilisateurs (Java/Spring Boot)
# ====================================================

# Création du fichier build.gradle
cat > microservices-todo/microservices/user-service/build.gradle << 'EOF'
plugins {
    id 'org.springframework.boot' version '3.2.0'
    id 'io.spring.dependency-management' version '1.1.4'
    id 'java'
}

group = 'com.fst.dmi'
version = '0.0.1-SNAPSHOT'
sourceCompatibility = '17'

repositories {
    mavenCentral()
}

dependencies {
    implementation 'org.springframework.boot:spring-boot-starter-data-jpa'
    implementation 'org.springframework.boot:spring-boot-starter-web'
    implementation 'org.springframework.boot:spring-boot-starter-security'
    implementation 'org.springframework.boot:spring-boot-starter-validation'
    runtimeOnly 'com.h2database:h2'
    testImplementation 'org.springframework.boot:spring-boot-starter-test'
}

test {
    useJUnitPlatform()
}
EOF

# Création du fichier application.properties
cat > microservices-todo/microservices/user-service/src/main/resources/application.properties << 'EOF'
# Server configuration
server.port=8081

# H2 Database configuration
spring.datasource.url=jdbc:h2:file:./data/userdb
spring.datasource.driverClassName=org.h2.Driver
spring.datasource.username=sa
spring.datasource.password=password
spring.jpa.database-platform=org.hibernate.dialect.H2Dialect

# Enable H2 console (for development)
spring.h2.console.enabled=true
spring.h2.console.path=/h2-console
spring.h2.console.settings.web-allow-others=true

# JPA configuration
spring.jpa.hibernate.ddl-auto=update
spring.jpa.show-sql=true

# CORS configuration
spring.mvc.cors.allowed-origins=*
spring.mvc.cors.allowed-methods=GET,POST,PUT,DELETE
spring.mvc.cors.allowed-headers=*
EOF

# User model avec TODO
cat > microservices-todo/microservices/user-service/src/main/java/com/fst/dmi/userservice/model/User.java << 'EOF'
package com.fst.dmi.userservice.model;

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

    // TODO-MS1: Complétez le modèle User avec des getters, setters et constructeurs appropriés
    // Assurez-vous d'initialiser createdAt dans les constructeurs
    
}
EOF

# UserRepository avec TODO
cat > microservices-todo/microservices/user-service/src/main/java/com/fst/dmi/userservice/repository/UserRepository.java << 'EOF'
package com.fst.dmi.userservice.repository;

import com.fst.dmi.userservice.model.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface UserRepository extends JpaRepository<User, Long> {

    // TODO-MS2: Ajoutez les méthodes de recherche suivantes :
    // - findByUsername pour trouver un utilisateur par son nom d'utilisateur
    // - findByEmail pour trouver un utilisateur par son email
    // - existsByUsername pour vérifier si un nom d'utilisateur existe déjà
    // - existsByEmail pour vérifier si un email existe déjà
    
}
EOF

# UserService avec TODOs
cat > microservices-todo/microservices/user-service/src/main/java/com/fst/dmi/userservice/service/UserService.java << 'EOF'
package com.fst.dmi.userservice.service;

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

    // TODO-MS3: Implémentez la méthode createUser pour créer un nouvel utilisateur
    // Cette méthode doit vérifier si le nom d'utilisateur ou l'email existe déjà
    // Elle doit encoder le mot de passe avant de sauvegarder l'utilisateur
    // En cas de conflit, elle doit lever une exception appropriée
    public User createUser(User user) {
        // À implémenter
        return null;
    }

    public Optional<User> findUserById(Long id) {
        return userRepository.findById(id);
    }

    public User findUserByUsername(String username) {
        return userRepository.findByUsername(username);
    }

    // TODO-MS4: Implémentez la méthode authenticateUser pour authentifier un utilisateur
    // Cette méthode doit vérifier si l'utilisateur existe puis si le mot de passe correspond
    // Elle doit utiliser passwordEncoder.matches pour comparer les mots de passe
    public boolean authenticateUser(String username, String password) {
        // À implémenter
        return false;
    }

    public List<User> getAllUsers() {
        return userRepository.findAll();
    }
}
EOF

# UserController avec TODOs
cat > microservices-todo/microservices/user-service/src/main/java/com/fst/dmi/userservice/controller/UserController.java << 'EOF'
package com.fst.dmi.userservice.controller;

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
@CrossOrigin(origins = "*")
public class UserController {

    private final UserService userService;

    @Autowired
    public UserController(UserService userService) {
        this.userService = userService;
    }

    // TODO-MS5: Implémentez l'endpoint POST /api/users pour créer un utilisateur
    // Cet endpoint doit appeler userService.createUser et gérer les erreurs possibles
    // Il doit retourner un code 201 en cas de succès et 400 en cas d'erreur
    @PostMapping
    public ResponseEntity<?> createUser(@RequestBody User user) {
        // À implémenter
        return null;
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

    // TODO-MS6: Implémentez l'endpoint POST /api/users/auth pour authentifier un utilisateur
    // Cet endpoint doit recevoir un username et password dans le corps de la requête
    // Il doit appeler userService.authenticateUser et retourner l'utilisateur ou une erreur
    @PostMapping("/auth")
    public ResponseEntity<?> authenticateUser(@RequestBody Map<String, String> credentials) {
        // À implémenter
        return null;
    }

    @GetMapping
    public ResponseEntity<List<User>> getAllUsers() {
        List<User> users = userService.getAllUsers();
        return new ResponseEntity<>(users, HttpStatus.OK);
    }

    @GetMapping("/check/{username}")
    public ResponseEntity<?> checkUsername(@PathVariable String username) {
        User user = userService.findUserByUsername(username);
        return new ResponseEntity<>(Map.of("exists", user != null), HttpStatus.OK);
    }
}
EOF

# SecurityConfig
cat > microservices-todo/microservices/user-service/src/main/java/com/fst/dmi/userservice/config/SecurityConfig.java << 'EOF'
package com.fst.dmi.userservice.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.web.SecurityFilterChain;

@Configuration
@EnableWebSecurity
public class SecurityConfig {

    @Bean
    public SecurityFilterChain securityFilterChain(HttpSecurity http) throws Exception {
        http
            .csrf(csrf -> csrf.disable())
            .authorizeHttpRequests(auth -> auth
                .requestMatchers("/api/**", "/h2-console/**").permitAll()
                .anyRequest().authenticated()
            )
            .headers(headers -> headers
                .frameOptions(frameOptions -> frameOptions.sameOrigin())
            );

        return http.build();
    }

    @Bean
    public PasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder();
    }
}
EOF

# Application principale
cat > microservices-todo/microservices/user-service/src/main/java/com/fst/dmi/userservice/UserServiceApplication.java << 'EOF'
package com.fst.dmi.userservice;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
public class UserServiceApplication {

    public static void main(String[] args) {
        SpringApplication.run(UserServiceApplication.class, args);
    }
}
EOF

# Dockerfile
cat > microservices-todo/microservices/user-service/Dockerfile << 'EOF'
FROM eclipse-temurin:17-jdk-alpine as build
WORKDIR /workspace/app

COPY . .
RUN ./gradlew build -x test

FROM eclipse-temurin:17-jre-alpine
VOLUME /tmp
COPY --from=build /workspace/app/build/libs/*.jar app.jar
ENTRYPOINT ["java","-jar","/app.jar"]
EOF

# ====================================================
# Service Tâches (Node.js/Express)
# ====================================================

# Package.json
cat > microservices-todo/microservices/task-service/package.json << 'EOF'
{
  "name": "task-service",
  "version": "1.0.0",
  "description": "Task microservice for Todo application",
  "main": "app.js",
  "scripts": {
    "start": "node app.js",
    "dev": "nodemon app.js",
    "test": "echo \"Error: no test specified\" && exit 1"
  },
  "dependencies": {
    "axios": "^1.6.0",
    "body-parser": "^1.20.2",
    "cors": "^2.8.5",
    "express": "^4.18.2",
    "sequelize": "^6.35.0",
    "sqlite3": "^5.1.6"
  },
  "devDependencies": {
    "nodemon": "^3.0.1"
  }
}
EOF

# Configuration de la base de données
cat > microservices-todo/microservices/task-service/config/database.js << 'EOF'
const { Sequelize } = require("sequelize");
const path = require("path");

const sequelize = new Sequelize({
  dialect: "sqlite",
  storage: path.join(__dirname, "../data/tasks.sqlite"),
  logging: false,
});

// Function to sync the model with the database
const syncDatabase = async () => {
  try {
    await sequelize.sync({ alter: true });
    console.log("Database synchronized successfully");
  } catch (error) {
    console.error("Error synchronizing database:", error);
  }
};

module.exports = sequelize;
module.exports.syncDatabase = syncDatabase;
EOF

# Modèle de tâche avec TODO
cat > microservices-todo/microservices/task-service/models/Task.js << 'EOF'
const { DataTypes } = require("sequelize");
const sequelize = require("../config/database");

// TODO-MS7: Complétez la définition du modèle Task
// Le modèle doit contenir les champs suivants :
// - id : identifiant unique auto-incrémenté
// - title : titre de la tâche (obligatoire)
// - description : description de la tâche (optionnel)
// - dueDate : date d'échéance (optionnel)
// - completed : statut de complétion (booléen, par défaut false)
// - userId : identifiant de l'utilisateur propriétaire (obligatoire)
// Activez également le timestamp pour avoir createdAt et updatedAt automatiquement

const Task = sequelize.define(
  "Task",
  {
    // À implémenter
  },
  {
    // À implémenter
  }
);

module.exports = Task;
EOF

# Service utilisateur pour la communication inter-services
cat > microservices-todo/microservices/task-service/services/userService.js << 'EOF'
const axios = require("axios");

// User service URL (use localhost in development)
const USER_SERVICE_URL =
  process.env.NODE_ENV === "production"
    ? "http://user-service:8081"
    : "http://localhost:8081";

// TODO-COMM1: Implémentez la fonction checkUserExists
// Cette fonction doit envoyer une requête GET au service Utilisateurs
// pour vérifier si un utilisateur avec l'ID spécifié existe
// Elle doit retourner true si la requête réussit (code 200), false sinon
const checkUserExists = async (userId) => {
  // À implémenter
};

module.exports = {
  checkUserExists,
};
EOF

# Contrôleur des tâches avec TODOs
cat > microservices-todo/microservices/task-service/controllers/taskController.js << 'EOF'
const Task = require("../models/Task");
const userService = require("../services/userService");

// TODO-MS8: Implémentez la fonction createTask
// Cette fonction doit :
// 1. Extraire les données de la requête (title, description, dueDate, userId)
// 2. Vérifier si l'utilisateur existe via userService.checkUserExists
// 3. Créer et sauvegarder la tâche si l'utilisateur existe
// 4. Retourner une erreur appropriée si l'utilisateur n'existe pas
const createTask = async (req, res) => {
  // À implémenter
};

// Get all tasks (with optional user filtering)
const getAllTasks = async (req, res) => {
  try {
    const { userId } = req.query;

    const filter = userId ? { userId } : {};
    const tasks = await Task.findAll({ where: filter });

    res.status(200).json(tasks);
  } catch (error) {
    console.error("Error retrieving tasks:", error);
    res.status(500).json({ error: "Error retrieving tasks" });
  }
};

// Get a task by ID
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

// Update a task
const updateTask = async (req, res) => {
  try {
    const { id } = req.params;
    const { title, description, dueDate, completed } = req.body;

    const task = await Task.findByPk(id);
    if (!task) {
      return res.status(404).json({ error: "Task not found" });
    }

    // Update fields
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

// Delete a task
const deleteTask = async (req, res) => {
  try {
    const { id } = req.params;

    const task = await Task.findByPk(id);
    if (!task) {
      return res.status(404).json({ error: "Task not found" });
    }

    await task.destroy();

    res.status(204).send();
  } catch (error) {
    console.error("Error deleting task:", error);
    res.status(500).json({ error: "Error deleting task" });
  }
};

// TODO-MS9: Implémentez la fonction getTasksByUserId
// Cette fonction doit :
// 1. Extraire l'userId des paramètres de route
// 2. Vérifier si l'utilisateur existe via userService.checkUserExists
// 3. Récupérer toutes les tâches pour cet utilisateur
// 4. Retourner une erreur appropriée si l'utilisateur n'existe pas
const getTasksByUserId = async (req, res) => {
  // À implémenter
};

module.exports = {
  createTask,
  getAllTasks,
  getTaskById,
  updateTask,
  deleteTask,
  getTasksByUserId,
};
EOF

# Routes
cat > microservices-todo/microservices/task-service/routes/taskRoutes.js << 'EOF'
const express = require("express");
const router = express.Router();
const taskController = require("../controllers/taskController");

// Create a new task
router.post("/tasks", taskController.createTask);

// Get all tasks (with optional user filtering)
router.get("/tasks", taskController.getAllTasks);

// Get a task by ID
router.get("/tasks/:id", taskController.getTaskById);

// Update a task
router.put("/tasks/:id", taskController.updateTask);

// Delete a task
router.delete("/tasks/:id", taskController.deleteTask);

// Get all tasks for a user
router.get("/users/:userId/tasks", taskController.getTasksByUserId);

module.exports = router;
EOF

# Application principale
cat > microservices-todo/microservices/task-service/app.js << 'EOF'
const express = require("express");
const cors = require("cors");
const sequelize = require("./config/database");
const taskRoutes = require("./routes/taskRoutes");

const app = express();
const PORT = process.env.PORT || 8082;

// Middleware
app.use(cors());
app.use(express.json());

// Routes
app.use("/api", taskRoutes);

// Test route
app.get("/", (req, res) => {
  res.send("Task service is running");
});

// Sync database and start server
sequelize.syncDatabase().then(() => {
  app.listen(PORT, () => {
    console.log(`Task service started on port ${PORT}`);
  });
});

module.exports = app;
EOF

# Dockerfile
cat > microservices-todo/microservices/task-service/Dockerfile << 'EOF'
FROM node:18-alpine

WORKDIR /app

COPY package*.json ./

RUN npm install

COPY . .

# Create the data directory
RUN mkdir -p data

EXPOSE 8082

CMD ["npm", "start"]
EOF

# ====================================================
# Service Notifications (Python/Flask)
# ====================================================

# Requirements.txt
cat > microservices-todo/microservices/notification-service/requirements.txt << 'EOF'
flask==2.3.3
flask-sqlalchemy==3.1.1
flask-cors==4.0.0
requests==2.31.0
python-dotenv==1.0.0
EOF

# Modèle de notification avec TODOs
cat > microservices-todo/microservices/notification-service/models/notification.py << 'EOF'
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
EOF

# Service utilisateur
cat > microservices-todo/microservices/notification-service/services/user_service.py << 'EOF'
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
EOF

# Service tâche avec TODO
cat > microservices-todo/microservices/notification-service/services/task_service.py << 'EOF'
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
EOF

# Service de notification avec TODO
cat > microservices-todo/microservices/notification-service/services/notification_service.py << 'EOF'
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
EOF

# Routes
cat > microservices-todo/microservices/notification-service/routes/notification_routes.py << 'EOF'
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
EOF

# Application principale
cat > microservices-todo/microservices/notification-service/app.py << 'EOF'
from flask import Flask
from flask_sqlalchemy import SQLAlchemy
from flask_cors import CORS
import os

# Initialize app
app = Flask(__name__)
CORS(app)

# Database configuration
app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///notifications.db'
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False

# Initialize database
db = SQLAlchemy(app)

# Import routes after db initialization to avoid circular imports
from routes.notification_routes import notification_bp

# Register blueprints
app.register_blueprint(notification_bp, url_prefix='/api/notifications')

# Test route
@app.route('/')
def index():
    return 'Notification service is running'

if __name__ == '__main__':
    # Create tables
    with app.app_context():
        db.create_all()

    # Start server
    port = int(os.environ.get('PORT', 8083))
    app.run(host='0.0.0.0', port=port, debug=True)
EOF

# Dockerfile
cat > microservices-todo/microservices/notification-service/Dockerfile << 'EOF'
FROM python:3.9-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

EXPOSE 8083

CMD ["python", "app.py"]
EOF

# ====================================================
# Docker Compose
# ====================================================

cat > microservices-todo/docker-compose.yml << 'EOF'
version: "3"

services:
  user-service:
    build: ./microservices/user-service
    ports:
      - "8081:8081"
    volumes:
      - ./microservices/user-service/data:/app/data
    networks:
      - microservices-network
    restart: always

  task-service:
    build: ./microservices/task-service
    ports:
      - "8082:8082"
    volumes:
      - ./microservices/task-service/data:/app/data
    networks:
      - microservices-network
    depends_on:
      - user-service
    restart: always

  notification-service:
    build: ./microservices/notification-service
    ports:
      - "8083:8083"
    volumes:
      - ./microservices/notification-service:/app
    networks:
      - microservices-network
    depends_on:
      - user-service
      - task-service
    restart: always

  frontend:
    build: ./microservices/frontend
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
    driver: bridge
EOF

echo "Structure de base créée avec succès dans le répertoire microservices-todo"
echo "Le projet contient tous les fichiers nécessaires avec les TODOs à compléter"
echo "Vous pouvez maintenant commencer à travailler sur les exercices du TP1"

# Rendre le script exécutable
chmod +x setup_lab1.sh