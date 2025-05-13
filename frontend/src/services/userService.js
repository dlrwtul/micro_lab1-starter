// src/services/userService.js
import axios from "axios";

const API_URL = "http://localhost:8081/api";

// Create an axios instance with improved error handling
const apiClient = axios.create({
  baseURL: API_URL,
  headers: {
    "Content-Type": "application/json",
    Accept: "application/json",
  },
  withCredentials: false,
});

// Add interceptor to add auth token to requests
apiClient.interceptors.request.use(
  config => {
    const token = localStorage.getItem("token");
    if (token) {
      config.headers["Authorization"] = `Bearer ${token}`;
    }
    return config;
  },
  error => {
    return Promise.reject(error);
  }
);

// Service functions
const userService = {
  // Créer un nouvel utilisateur
  createUser: async userData => {
    try {
      console.log("Creating user with data:", userData);
      const response = await apiClient.post("/users", userData);
      console.log("User creation response:", response.data);
      return response.data;
    } catch (error) {
      console.error("Error creating user:", error);
      throw error.response?.data || { error: "Failed to create user" };
    }
  },

  // Authentifier un utilisateur
  authenticateUser: async (username, password) => {
    try {
      console.log("Authenticating user:", username);
      const response = await apiClient.post("/users/auth", {
        username,
        password,
      });
      console.log("Authentication response:", response.data);
      return response.data;
    } catch (error) {
      console.error("Error authenticating user:", error);
      throw error.response?.data || { error: "Failed to authenticate" };
    }
  },

  // Obtenir les détails d'un utilisateur
  getUserById: async userId => {
    try {
      const response = await apiClient.get(`/users/${userId}`);
      return response.data;
    } catch (error) {
      console.error("Error fetching user:", error);
      throw error.response?.data || { error: "Failed to fetch user" };
    }
  },

  // Vérifier si un nom d'utilisateur existe déjà
  checkUsername: async username => {
    try {
      const response = await apiClient.get(`/users/check/${username}`);
      return response.data;
    } catch (error) {
      console.error("Error checking username:", error);
      throw error.response?.data || { error: "Failed to check username" };
    }
  },

  // Alias pour compatibilité avec l'ancien authService
  register: async (username, email, password) => {
    return userService.createUser({ username, email, password });
  },

  login: async (username, password) => {
    return userService.authenticateUser(username, password);
  },

  // Déconnexion utilisateur
  logout: () => {
    localStorage.removeItem("user");
    localStorage.removeItem("token");
    localStorage.removeItem("currentUser");
  },

  // Récupérer l'utilisateur actuel du localStorage
  getCurrentUser: () => {
    const user = localStorage.getItem("currentUser");
    return user ? JSON.parse(user) : null;
  },

  // Vérifier si un utilisateur est connecté
  isLoggedIn: () => {
    return !!localStorage.getItem("currentUser");
  },

  // Mettre à jour les informations utilisateur
  updateUser: async (userId, userData) => {
    try {
      const response = await apiClient.put(`/users/${userId}`, userData);
      return response.data;
    } catch (error) {
      console.error("Error updating user:", error);
      throw error.response?.data || { error: "Failed to update user" };
    }
  },

  // Obtenir tous les utilisateurs (pour l'administration)
  getAllUsers: async () => {
    try {
      const response = await apiClient.get("/users");
      return response.data;
    } catch (error) {
      console.error("Error fetching users:", error);
      throw error.response?.data || { error: "Failed to fetch users" };
    }
  },
};

export default userService;
