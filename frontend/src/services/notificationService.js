// src/services/notificationService.js
import axios from "axios";

const API_URL = "http://localhost:8083/api/notifications";

// Create an axios instance
const apiClient = axios.create({
  baseURL: API_URL,
  headers: {
    "Content-Type": "application/json",
  },
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
const notificationService = {
  // Get notifications for a user
  getUserNotifications: async userId => {
    try {
      const response = await apiClient.get(`/user/${userId}`);
      return response.data;
    } catch (error) {
      console.error("Error fetching user notifications:", error);
      throw error.response?.data || { error: "Failed to fetch notifications" };
    }
  },

  // Check for due tasks
  checkDueTasks: async () => {
    try {
      const response = await apiClient.post(`/check-due-tasks`);
      return response.data;
    } catch (error) {
      console.error("Error checking due tasks:", error);
      throw error.response?.data || { error: "Failed to check due tasks" };
    }
  },

  // Mark notification as read
  markAsRead: async notificationId => {
    try {
      const response = await apiClient.put(`/${notificationId}/read`);
      return response.data;
    } catch (error) {
      console.error("Error marking notification as read:", error);
      throw (
        error.response?.data || { error: "Failed to mark notification as read" }
      );
    }
  },

  // Create a new notification (if needed)
  createNotification: async notificationData => {
    try {
      const response = await apiClient.post("", notificationData);
      return response.data;
    } catch (error) {
      console.error("Error creating notification:", error);
      throw error.response?.data || { error: "Failed to create notification" };
    }
  },
};

export default notificationService;
