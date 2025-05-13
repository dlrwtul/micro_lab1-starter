// src/components/Notifications/NotificationItem.js
import React, { useContext } from "react";
import { Link } from "react-router-dom";
import { FontAwesomeIcon } from "@fortawesome/react-fontawesome";
import { faBell, faCheck } from "@fortawesome/free-solid-svg-icons";
import NotificationContext from "../../contexts/NotificationContext";
import "./Notifications.css";

const NotificationItem = ({ notification }) => {
  const { markAsRead } = useContext(NotificationContext);

  // Format the creation date for display
  const formatDate = dateString => {
    if (!dateString) return "";

    const date = new Date(dateString);
    const now = new Date();
    const diffTime = Math.abs(now - date);
    const diffDays = Math.floor(diffTime / (1000 * 60 * 60 * 24));

    if (diffDays === 0) {
      // Today, show time only
      return new Intl.DateTimeFormat("en-US", {
        hour: "2-digit",
        minute: "2-digit",
      }).format(date);
    } else if (diffDays === 1) {
      // Yesterday
      return "Yesterday";
    } else if (diffDays < 7) {
      // This week
      return new Intl.DateTimeFormat("en-US", {
        weekday: "long",
      }).format(date);
    } else {
      // Older
      return new Intl.DateTimeFormat("en-US", {
        year: "numeric",
        month: "short",
        day: "numeric",
      }).format(date);
    }
  };

  const handleMarkAsRead = () => {
    if (!notification.read) {
      markAsRead(notification.id);
    }
  };

  return (
    <div
      className={`notification-item ${notification.read ? "read" : "unread"}`}
      onClick={handleMarkAsRead}
    >
      <div className="notification-icon">
        <FontAwesomeIcon icon={faBell} />
      </div>

      <div className="notification-content">
        <div className="notification-message">{notification.message}</div>
        <div className="notification-date">
          {formatDate(notification.created_at)}
        </div>

        <Link
          to={`/tasks/${notification.task_id}`}
          className="notification-link"
        >
          View Task
        </Link>
      </div>

      {!notification.read && (
        <button
          className="btn-mark-read"
          onClick={e => {
            e.stopPropagation();
            markAsRead(notification.id);
          }}
          title="Mark as read"
        >
          <FontAwesomeIcon icon={faCheck} />
        </button>
      )}
    </div>
  );
};

export default NotificationItem;
