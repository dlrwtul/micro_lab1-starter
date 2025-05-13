// src/components/Tasks/TaskForm.js
import React, { useState, useContext } from "react";
import AuthContext from "../../contexts/AuthContext";
import taskService from "../../services/taskService";
import "./Tasks.css";

const TaskForm = ({ onTaskAdded }) => {
  const [title, setTitle] = useState("");
  const [description, setDescription] = useState("");
  const [dueDate, setDueDate] = useState("");
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState("");

  const { currentUser } = useContext(AuthContext);

  const handleSubmit = async e => {
    e.preventDefault();
    setError("");

    // Validate form
    if (!title) {
      setError("Task title is required");
      return;
    }

    setLoading(true);

    try {
      const newTask = {
        title,
        description,
        dueDate: dueDate ? new Date(dueDate).toISOString() : null,
        userId: currentUser.id,
      };

      const createdTask = await taskService.createTask(newTask);

      // Reset form
      setTitle("");
      setDescription("");
      setDueDate("");

      // Notify parent component
      if (onTaskAdded) {
        onTaskAdded(createdTask);
      }
    } catch (err) {
      setError(err.error || "Failed to create task. Please try again.");
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="task-form-container">
      <h3>Add New Task</h3>
      {error && <div className="error-message">{error}</div>}

      <form onSubmit={handleSubmit} className="task-form">
        <div className="form-group">
          <label htmlFor="title">Title</label>
          <input
            type="text"
            id="title"
            value={title}
            onChange={e => setTitle(e.target.value)}
            placeholder="What needs to be done?"
            disabled={loading}
          />
        </div>

        <div className="form-group">
          <label htmlFor="description">Description (optional)</label>
          <textarea
            id="description"
            value={description}
            onChange={e => setDescription(e.target.value)}
            placeholder="Add details..."
            disabled={loading}
          />
        </div>

        <div className="form-group">
          <label htmlFor="dueDate">Due Date (optional)</label>
          <input
            type="datetime-local"
            id="dueDate"
            value={dueDate}
            onChange={e => setDueDate(e.target.value)}
            disabled={loading}
          />
        </div>

        <button type="submit" className="btn-primary" disabled={loading}>
          {loading ? "Adding..." : "Add Task"}
        </button>
      </form>
    </div>
  );
};

export default TaskForm;
