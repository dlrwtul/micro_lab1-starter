// src/services/healthService.js
import axios from "axios";

// URLs des services backend
const USER_SERVICE_URL = "http://user-service:8081/api/users";
const TASK_SERVICE_URL = "http://task-service:8082/api/tasks";
const NOTIFICATION_SERVICE_URL =
  "http://notification-service:8083/api/notifications";

/**
 * Vérifie l'état de santé d'un service
 * @param {string} url - URL du service à vérifier
 * @param {string} name - Nom du service pour les logs
 * @returns {Promise<boolean>} - true si le service est disponible
 */
const checkServiceHealth = async (url, name) => {
  try {
    const response = await axios.get(url, { timeout: 2000 });
    console.log(`${name} service is available`);
    return true;
  } catch (error) {
    console.warn(`${name} service is not ready yet:`, error.message);
    return false;
  }
};

/**
 * Vérifie l'état de santé de tous les services backend
 * @returns {Promise<boolean>} - true si tous les services sont disponibles
 */
export const checkServicesHealth = async () => {
  try {
    // Vérifier le service utilisateur (critique)
    const userServiceReady = await checkServiceHealth(USER_SERVICE_URL, "User");

    if (!userServiceReady) {
      return false; // Si le service utilisateur n'est pas disponible, on ne peut rien faire
    }

    // Vérifier les autres services
    const taskServiceReady = await checkServiceHealth(TASK_SERVICE_URL, "Task");
    const notificationServiceReady = await checkServiceHealth(
      NOTIFICATION_SERVICE_URL,
      "Notification"
    );

    // On peut fonctionner même si certains services ne sont pas disponibles
    console.log(
      `Services health check: User: ${userServiceReady}, Task: ${taskServiceReady}, Notification: ${notificationServiceReady}`
    );

    // Retourner true si tous les services sont disponibles
    return userServiceReady && taskServiceReady && notificationServiceReady;
  } catch (error) {
    console.error("Error checking services health:", error);
    return false;
  }
};

/**
 * Attend que les services soient disponibles
 * @param {number} timeout - Délai maximal d'attente en millisecondes
 * @returns {Promise<boolean>} - true si les services sont disponibles avant le timeout
 */
export const waitForServices = async (timeout = 30000) => {
  const startTime = Date.now();

  while (Date.now() - startTime < timeout) {
    const servicesReady = await checkServicesHealth();
    if (servicesReady) {
      return true;
    }
    // Attendre 2 secondes avant de réessayer
    await new Promise(resolve => setTimeout(resolve, 2000));
  }

  return false; // Timeout dépassé
};
