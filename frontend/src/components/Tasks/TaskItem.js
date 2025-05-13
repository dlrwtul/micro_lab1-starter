// src/components/Tasks/TaskItem.js
import React, { useState } from "react";
import { FontAwesomeIcon } from "@fortawesome/react-fontawesome";
import {
  faCheck,
  faTrash,
  faEdit,
  faTimes,
  faSave,
} from "@fortawesome/free-solid-svg-icons";
import taskService from "../../services/taskService";
import "./Tasks.css";

const TaskItem = ({ task, onTaskUpdated, onTaskDeleted }) => {
  const [isEditing, setIsEditing] = useState(false);
  const [editTitle, setEditTitle] = useState(task.title);
  const [editDescription, setEditDescription] = useState(
    task.description || ""
  );
  const [editDueDate, setEditDueDate] = useState(
    task.dueDate ? new Date(task.dueDate).toISOString().slice(0, 16) : ""
  );
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState("");

  // Format the due date for display
  const formatDate = dateString => {
    if (!dateString) return "No due date";

    const date = new Date(dateString);
    return new Intl.DateTimeFormat("en-US", {
      year: "numeric",
      month: "short",
      day: "numeric",
      hour: "2-digit",
      minute: "2-digit",
    }).format(date);
  };

  // Handle marking task as complete
  const handleComplete = async () => {
    setLoading(true);
    setError("");

    try {
      const updatedTask = await taskService.completeTask(task.id);
      if (onTaskUpdated) {
        onTaskUpdated(updatedTask);
      }
    } catch (err) {
      setError(err.error || "Failed to update task");
    } finally {
      setLoading(false);
    }
  };

  // Handle deleting a task
  const handleDelete = async () => {
    if (!window.confirm("Are you sure you want to delete this task?")) {
      return;
    }

    setLoading(true);
    setError("");

    try {
      await taskService.deleteTask(task.id);
      if (onTaskDeleted) {
        onTaskDeleted(task.id);
      }
    } catch (err) {
      setError(err.error || "Failed to delete task");
    } finally {
      setLoading(false);
    }
  };

  // Handle saving edited task
  const handleSave = async () => {
    if (!editTitle) {
      setError("Task title is required");
      return;
    }

    setLoading(true);
    setError("");

    try {
      const updatedTaskData = {
        title: editTitle,
        description: editDescription,
        dueDate: editDueDate
          ? new Date(editDueDate).toISOString()
          : task.dueDate,
        completed: task.completed,
      };

      const updatedTask = await taskService.updateTask(
        task.id,
        updatedTaskData
      );

      if (onTaskUpdated) {
        onTaskUpdated(updatedTask);
      }

      setIsEditing(false);
    } catch (err) {
      setError(err.error || "Failed to update task");
    } finally {
      setLoading(false);
    }
  };

  // Cancel editing
  const handleCancel = () => {
    setEditTitle(task.title);
    setEditDescription(task.description || "");
    setEditDueDate(
      task.dueDate ? new Date(task.dueDate).toISOString().slice(0, 16) : ""
    );
    setIsEditing(false);
    setError("");
  };

  return (
    <div className={`task-item ${task.completed ? "completed" : ""}`}>
      {error && <div className="error-message">{error}</div>}

      {isEditing ? (
        <div className="task-edit-form">
          <div className="form-group">
            <label htmlFor={`edit-title-${task.id}`}>Title</label>
            <input
              type="text"
              id={`edit-title-${task.id}`}
              value={editTitle}
              onChange={e => setEditTitle(e.target.value)}
              disabled={loading}
            />
          </div>

          <div className="form-group">
            <label htmlFor={`edit-description-${task.id}`}>Description</label>
            <textarea
              id={`edit-description-${task.id}`}
              value={editDescription}
              onChange={e => setEditDescription(e.target.value)}
              disabled={loading}
            />
          </div>

          <div className="form-group">
            <label htmlFor={`edit-due-date-${task.id}`}>Due Date</label>
            <input
              type="datetime-local"
              id={`edit-due-date-${task.id}`}
              value={editDueDate}
              onChange={e => setEditDueDate(e.target.value)}
              disabled={loading}
            />
          </div>

          <div className="task-actions">
            <button
              className="btn-icon btn-save"
              onClick={handleSave}
              disabled={loading}
              title="Save changes"
            >
              <FontAwesomeIcon icon={faSave} />
            </button>

            <button
              className="btn-icon btn-cancel"
              onClick={handleCancel}
              disabled={loading}
              title="Cancel editing"
            >
              <FontAwesomeIcon icon={faTimes} />
            </button>
          </div>
        </div>
      ) : (
        <>
          <div className="task-content">
            <div className="task-header">
              <h4 className="task-title">{task.title}</h4>
              <div className="task-status">
                {task.completed ? (
                  <span className="status-badge completed">Completed</span>
                ) : (
                  <span className="status-badge pending">Pending</span>
                )}
              </div>
            </div>

            {task.description && (
              <p className="task-description">{task.description}</p>
            )}

            <p className="task-due-date">Due: {formatDate(task.dueDate)}</p>
          </div>

          <div className="task-actions">
            {!task.completed && (
              <button
                className="btn-icon btn-complete"
                onClick={handleComplete}
                disabled={loading}
                title="Mark as completed"
              >
                <FontAwesomeIcon icon={faCheck} />
              </button>
            )}

            <button
              className="btn-icon btn-edit"
              onClick={() => setIsEditing(true)}
              disabled={loading}
              title="Edit task"
            >
              <FontAwesomeIcon icon={faEdit} />
            </button>

            <button
              className="btn-icon btn-delete"
              onClick={handleDelete}
              disabled={loading}
              title="Delete task"
            >
              <FontAwesomeIcon icon={faTrash} />
            </button>
          </div>
        </>
      )}
    </div>
  );
};

export default TaskItem;
