// src/contexts/AuthContext.js
import React, { createContext, useState, useEffect } from "react";
import userService from "../services/userService";

export const AuthContext = createContext();

export const AuthProvider = ({ children }) => {
  const [currentUser, setCurrentUser] = useState(null);
  const [isAuthenticated, setIsAuthenticated] = useState(false);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  // Vérifier si l'utilisateur est déjà connecté au chargement
  useEffect(() => {
    // Essayer de récupérer l'utilisateur du localStorage
    const storedUser = localStorage.getItem("currentUser");
    const token = localStorage.getItem("token");

    if (storedUser && token) {
      try {
        // Convertir la chaîne JSON en objet
        const user = JSON.parse(storedUser);
        setCurrentUser(user);
        setIsAuthenticated(true);
      } catch (err) {
        // En cas d'erreur de parsing, nettoyer le localStorage
        console.error("Error parsing stored user:", err);
        localStorage.removeItem("currentUser");
        localStorage.removeItem("token");
      }
    }

    setLoading(false);
  }, []);

  // Fonction de connexion
  const login = async (username, password) => {
    setLoading(true);
    setError(null);

    try {
      // Utiliser le service unifié
      const response = await userService.authenticateUser(username, password);

      // Stocker les informations utilisateur
      localStorage.setItem("currentUser", JSON.stringify(response));
      localStorage.setItem("token", "dummy-token"); // À remplacer par un vrai token JWT si disponible

      setCurrentUser(response);
      setIsAuthenticated(true);
      setLoading(false);
      return response;
    } catch (err) {
      setLoading(false);
      setError(err.message || "Failed to login");
      throw err;
    }
  };

  // Fonction d'inscription
  const register = async userData => {
    setLoading(true);
    setError(null);

    try {
      // Utiliser le service unifié
      const response = await userService.createUser(userData);
      setLoading(false);
      return response;
    } catch (err) {
      setLoading(false);
      setError(err.message || "Failed to register");
      throw err;
    }
  };

  // Fonction de déconnexion complète
  const logout = () => {
    // Supprimer toutes les données d'authentification du localStorage
    localStorage.removeItem("token");
    localStorage.removeItem("currentUser");
    localStorage.removeItem("userId");

    // Supprimer les éventuelles préférences ou paramètres utilisateur
    localStorage.removeItem("userSettings");
    localStorage.removeItem("userPreferences");

    // Vider complètement sessionStorage
    sessionStorage.clear();

    // Réinitialiser l'état du contexte
    setCurrentUser(null);
    setIsAuthenticated(false);
    setError(null);

    // Supprimer tous les cookies liés à l'authentification
    document.cookie.split(";").forEach(cookie => {
      const equalPos = cookie.indexOf("=");
      const name =
        equalPos > -1 ? cookie.substr(0, equalPos).trim() : cookie.trim();
      document.cookie = name + "=;expires=Thu, 01 Jan 1970 00:00:00 GMT;path=/";
    });

    console.log("User logged out completely");
  };

  // Valeur retournée par le contexte
  const contextValue = {
    currentUser,
    isAuthenticated,
    loading,
    error,
    login,
    register,
    logout,
    setCurrentUser,
    setIsAuthenticated,
  };

  return (
    <AuthContext.Provider value={contextValue}>{children}</AuthContext.Provider>
  );
};

export default AuthContext;
