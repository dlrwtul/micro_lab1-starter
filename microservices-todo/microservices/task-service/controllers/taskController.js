const Task = require("../models/Task");
const userService = require("../services/userService");

// TODO-MS8: Implémentez la fonction createTask
// Cette fonction doit :
// 1. Extraire les données de la requête (title, description, dueDate, userId)
// 2. Vérifier si l'utilisateur existe via userService.checkUserExists
// 3. Créer et sauvegarder la tâche si l'utilisateur existe
// 4. Retourner une erreur appropriée si l'utilisateur n'existe pas
const createTask = async (req, res) => {
  // À implémenter
};

// Get all tasks (with optional user filtering)
const getAllTasks = async (req, res) => {
  try {
    const { userId } = req.query;

    const filter = userId ? { userId } : {};
    const tasks = await Task.findAll({ where: filter });

    res.status(200).json(tasks);
  } catch (error) {
    console.error("Error retrieving tasks:", error);
    res.status(500).json({ error: "Error retrieving tasks" });
  }
};

// Get a task by ID
const getTaskById = async (req, res) => {
  try {
    const { id } = req.params;

    const task = await Task.findByPk(id);
    if (!task) {
      return res.status(404).json({ error: "Task not found" });
    }

    res.status(200).json(task);
  } catch (error) {
    console.error("Error retrieving task:", error);
    res.status(500).json({ error: "Error retrieving task" });
  }
};

// Update a task
const updateTask = async (req, res) => {
  try {
    const { id } = req.params;
    const { title, description, dueDate, completed } = req.body;

    const task = await Task.findByPk(id);
    if (!task) {
      return res.status(404).json({ error: "Task not found" });
    }

    // Update fields
    if (title) task.title = title;
    if (description !== undefined) task.description = description;
    if (dueDate) task.dueDate = dueDate;
    if (completed !== undefined) task.completed = completed;

    await task.save();

    res.status(200).json(task);
  } catch (error) {
    console.error("Error updating task:", error);
    res.status(500).json({ error: "Error updating task" });
  }
};

// Delete a task
const deleteTask = async (req, res) => {
  try {
    const { id } = req.params;

    const task = await Task.findByPk(id);
    if (!task) {
      return res.status(404).json({ error: "Task not found" });
    }

    await task.destroy();

    res.status(204).send();
  } catch (error) {
    console.error("Error deleting task:", error);
    res.status(500).json({ error: "Error deleting task" });
  }
};

// TODO-MS9: Implémentez la fonction getTasksByUserId
// Cette fonction doit :
// 1. Extraire l'userId des paramètres de route
// 2. Vérifier si l'utilisateur existe via userService.checkUserExists
// 3. Récupérer toutes les tâches pour cet utilisateur
// 4. Retourner une erreur appropriée si l'utilisateur n'existe pas
const getTasksByUserId = async (req, res) => {
  // À implémenter
};

module.exports = {
  createTask,
  getAllTasks,
  getTaskById,
  updateTask,
  deleteTask,
  getTasksByUserId,
};
