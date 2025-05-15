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
};
