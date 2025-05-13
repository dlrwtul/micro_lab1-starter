// src/components/Dashboard.js
import React, { useContext, useState, useEffect } from "react";
import { Link } from "react-router-dom";
import { FontAwesomeIcon } from "@fortawesome/react-fontawesome";
import {
  faClipboardList,
  faBell,
  faCheckCircle,
  faExclamationCircle,
} from "@fortawesome/free-solid-svg-icons";
import AuthContext from "../contexts/AuthContext";
import NotificationContext from "../contexts/NotificationContext";
import taskService from "../services/taskService";
import "./Dashboard.css";

const Dashboard = () => {
  const { currentUser } = useContext(AuthContext);
  const { notifications } = useContext(NotificationContext);
  const [taskStats, setTaskStats] = useState({
    total: 0,
    completed: 0,
    pending: 0,
    dueToday: 0,
  });
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState("");

  useEffect(() => {
    fetchTaskStats();
  }, [currentUser]);

  const fetchTaskStats = async () => {
    if (!currentUser) return;

    setLoading(true);
    setError("");

    try {
      const tasks = await taskService.getUserTasks(currentUser.id);

      const completed = tasks.filter(task => task.completed).length;
      const pending = tasks.filter(task => !task.completed).length;

      // Count tasks due today
      const today = new Date();
      today.setHours(0, 0, 0, 0);
      const tomorrow = new Date(today);
      tomorrow.setDate(tomorrow.getDate() + 1);

      const dueToday = tasks.filter(task => {
        if (!task.dueDate || task.completed) return false;

        const dueDate = new Date(task.dueDate);
        dueDate.setHours(0, 0, 0, 0);

        return dueDate.getTime() === today.getTime();
      }).length;

      setTaskStats({
        total: tasks.length,
        completed,
        pending,
        dueToday,
      });
    } catch (err) {
      setError(err.error || "Failed to fetch task statistics");
    } finally {
      setLoading(false);
    }
  };

  // Get the number of unread notifications
  const unreadNotifications = notifications.filter(
    notification => !notification.read
  ).length;

  if (loading) {
    return <div className="loading">Loading dashboard...</div>;
  }

  return (
    <div className="dashboard-container">
      <h1>Welcome, {currentUser?.username}!</h1>

      {error && <div className="error-message">{error}</div>}

      <div className="dashboard-summary">
        <div className="summary-card">
          <div className="card-icon task-icon">
            <FontAwesomeIcon icon={faClipboardList} />
          </div>
          <div className="card-content">
            <h3>Total Tasks</h3>
            <p className="stat-number">{taskStats.total}</p>
            <Link to="/tasks" className="card-link">
              View All Tasks
            </Link>
          </div>
        </div>

        <div className="summary-card">
          <div className="card-icon completed-icon">
            <FontAwesomeIcon icon={faCheckCircle} />
          </div>
          <div className="card-content">
            <h3>Completed Tasks</h3>
            <p className="stat-number">{taskStats.completed}</p>
            <p className="stat-percentage">
              {taskStats.total > 0
                ? `${Math.round(
                    (taskStats.completed / taskStats.total) * 100
                  )}%`
                : "0%"}
            </p>
          </div>
        </div>

        <div className="summary-card">
          <div className="card-icon pending-icon">
            <FontAwesomeIcon icon={faExclamationCircle} />
          </div>
          <div className="card-content">
            <h3>Pending Tasks</h3>
            <p className="stat-number">{taskStats.pending}</p>
            <p className="stat-info">
              {taskStats.dueToday > 0 && `${taskStats.dueToday} due today`}
            </p>
          </div>
        </div>

        <div className="summary-card">
          <div className="card-icon notification-icon">
            <FontAwesomeIcon icon={faBell} />
          </div>
          <div className="card-content">
            <h3>Notifications</h3>
            <p className="stat-number">{notifications.length}</p>
            <p className="stat-info">
              {unreadNotifications > 0 && `${unreadNotifications} unread`}
            </p>
            <Link to="/notifications" className="card-link">
              View All Notifications
            </Link>
          </div>
        </div>
      </div>

      <div className="dashboard-sections">
        <div className="dashboard-section">
          <h2>Recent Tasks</h2>
          {taskStats.total === 0 ? (
            <div className="empty-state">
              <p>You don't have any tasks yet.</p>
              <Link to="/tasks" className="btn-primary">
                Create Your First Task
              </Link>
            </div>
          ) : (
            // This would be replaced with a component showing recent tasks
            <div className="placeholder">
              <Link to="/tasks" className="btn-primary">
                View Tasks
              </Link>
            </div>
          )}
        </div>

        <div className="dashboard-section">
          <h2>Recent Notifications</h2>
          {notifications.length === 0 ? (
            <div className="empty-state">
              <p>You don't have any notifications yet.</p>
            </div>
          ) : (
            // This would be replaced with a component showing recent notifications
            <div className="placeholder">
              <Link to="/notifications" className="btn-primary">
                View Notifications
              </Link>
            </div>
          )}
        </div>
      </div>
    </div>
  );
};

export default Dashboard;
