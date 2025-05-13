// src/services/taskService.js
import axios from "axios";

const API_URL = "http://localhost:8082/api";

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
const taskService = {
  // Get all tasks for a user
  getUserTasks: async userId => {
    try {
      const response = await apiClient.get(`/users/${userId}/tasks`);
      return response.data;
    } catch (error) {
      throw error.response?.data || { error: "Failed to fetch tasks" };
    }
  },

  // Get a specific task
  getTask: async taskId => {
    try {
      const response = await apiClient.get(`/tasks/${taskId}`);
      return response.data;
    } catch (error) {
      throw error.response?.data || { error: "Failed to fetch task" };
    }
  },

  // Create a new task
  createTask: async task => {
    try {
      const response = await apiClient.post("/tasks", task);
      return response.data;
    } catch (error) {
      throw error.response?.data || { error: "Failed to create task" };
    }
  },

  // Update a task
  updateTask: async (taskId, task) => {
    try {
      const response = await apiClient.put(`/tasks/${taskId}`, task);
      return response.data;
    } catch (error) {
      throw error.response?.data || { error: "Failed to update task" };
    }
  },

  // Delete a task
  deleteTask: async taskId => {
    try {
      await apiClient.delete(`/tasks/${taskId}`);
      return true;
    } catch (error) {
      throw error.response?.data || { error: "Failed to delete task" };
    }
  },

  // Mark a task as completed
  completeTask: async taskId => {
    try {
      const response = await apiClient.put(`/tasks/${taskId}`, {
        completed: true,
      });
      return response.data;
    } catch (error) {
      throw error.response?.data || { error: "Failed to complete task" };
    }
  },
};

export default taskService;
