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
    User findByUsername(String username);
    User findByEmail(String email);
    boolean existsByUsername(String username);
    boolean existsByEmail(String email);
    
}
