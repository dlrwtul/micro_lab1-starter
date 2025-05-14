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
        try {
            User createdUser = userService.createUser(user);
            return new ResponseEntity<>(createdUser, HttpStatus.CREATED);
        } catch (Exception e) {
            return new ResponseEntity<>(Map.of("error", e.getMessage()), HttpStatus.BAD_REQUEST);
        }
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
        List<User> users = userService.getAllUsers();
        return new ResponseEntity<>(users, HttpStatus.OK);
    }

    @GetMapping("/check/{username}")
    public ResponseEntity<?> checkUsername(@PathVariable String username) {
        User user = userService.findUserByUsername(username);
        return new ResponseEntity<>(Map.of("exists", user != null), HttpStatus.OK);
    }
}
