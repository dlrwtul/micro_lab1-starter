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
