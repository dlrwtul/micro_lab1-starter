// src/components/Tasks/TaskList.js
import React, { useState, useEffect, useContext } from "react";
import TaskItem from "./TaskItem";
import TaskForm from "./TaskForm";
import taskService from "../../services/taskService";
import AuthContext from "../../contexts/AuthContext";
import "./Tasks.css";

const TaskList = () => {
  const [tasks, setTasks] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState("");
  const [filter, setFilter] = useState("all"); // 'all', 'active', 'completed'

  const { currentUser } = useContext(AuthContext);

  useEffect(() => {
    fetchTasks();
  }, [currentUser]);

  const fetchTasks = async () => {
    if (!currentUser) return;

    setLoading(true);
    setError("");

    try {
      const data = await taskService.getUserTasks(currentUser.id);
      setTasks(data);
    } catch (err) {
      setError(err.error || "Failed to fetch tasks");
    } finally {
      setLoading(false);
    }
  };

  const handleTaskAdded = newTask => {
    setTasks([...tasks, newTask]);
  };

  const handleTaskUpdated = updatedTask => {
    setTasks(
      tasks.map(task => (task.id === updatedTask.id ? updatedTask : task))
    );
  };

  const handleTaskDeleted = taskId => {
    setTasks(tasks.filter(task => task.id !== taskId));
  };

  // Filter tasks based on selected filter
  const filteredTasks = tasks.filter(task => {
    if (filter === "active") return !task.completed;
    if (filter === "completed") return task.completed;
    return true; // 'all' filter
  });

  if (loading && tasks.length === 0) {
    return <div className="loading">Loading tasks...</div>;
  }

  return (
    <div className="task-list-container">
      <div className="task-list-header">
        <h2>My Tasks</h2>
        <div className="task-filters">
          <button
            className={`filter-btn ${filter === "all" ? "active" : ""}`}
            onClick={() => setFilter("all")}
          >
            All
          </button>
          <button
            className={`filter-btn ${filter === "active" ? "active" : ""}`}
            onClick={() => setFilter("active")}
          >
            Active
          </button>
          <button
            className={`filter-btn ${filter === "completed" ? "active" : ""}`}
            onClick={() => setFilter("completed")}
          >
            Completed
          </button>
        </div>
      </div>

      <TaskForm onTaskAdded={handleTaskAdded} />

      {error && <div className="error-message">{error}</div>}

      {filteredTasks.length === 0 ? (
        <div className="no-tasks-message">
          {filter === "all"
            ? "You don't have any tasks yet. Create one above!"
            : filter === "active"
            ? "You don't have any active tasks."
            : "You don't have any completed tasks."}
        </div>
      ) : (
        <div className="task-list">
          {filteredTasks.map(task => (
            <TaskItem
              key={task.id}
              task={task}
              onTaskUpdated={handleTaskUpdated}
              onTaskDeleted={handleTaskDeleted}
            />
          ))}
        </div>
      )}
    </div>
  );
};

export default TaskList;
