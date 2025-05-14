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
        if (userRepository.existsByUsername(user.getUsername())) {
            throw new RuntimeException("Username already exists");
        }
        if (userRepository.existsByEmail(user.getEmail())) {
            throw new RuntimeException("Email already exists");
        }

        user.setPassword(passwordEncoder.encode(user.getPassword()));

        return userRepository.save(user);
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
        User user = userRepository.findByUsername(username);
        if (user == null) {
            return false;
        }
        
        return passwordEncoder.matches(password, user.getPassword());
    }

    public List<User> getAllUsers() {
        return userRepository.findAll();
    }
}
