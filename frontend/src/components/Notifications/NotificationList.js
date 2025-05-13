// src/components/Notifications/NotificationList.js
import React, { useContext } from "react";
import NotificationItem from "./NotificationItem";
import NotificationContext from "../../contexts/NotificationContext";
import "./Notifications.css";

const NotificationList = ({ showAll = false }) => {
  const {
    notifications,
    unreadCount,
    loading,
    error,
    markAllAsRead,
    fetchUserNotifications,
  } = useContext(NotificationContext);

  // If not showing all, only show the latest 5 notifications
  const displayedNotifications = showAll
    ? notifications
    : notifications.slice(0, 5);

  // Sort notifications by date (newest first)
  const sortedNotifications = [...displayedNotifications].sort(
    (a, b) => new Date(b.created_at) - new Date(a.created_at)
  );

  const handleRefresh = () => {
    fetchUserNotifications();
  };

  const handleMarkAllAsRead = () => {
    markAllAsRead();
  };

  if (loading && notifications.length === 0) {
    return <div className="loading">Loading notifications...</div>;
  }

  return (
    <div className="notification-list-container">
      <div className="notification-list-header">
        <h3>
          {showAll ? "All Notifications" : "Recent Notifications"}
          {unreadCount > 0 && (
            <span className="unread-count">{unreadCount}</span>
          )}
        </h3>

        <div className="notification-actions">
          {unreadCount > 0 && (
            <button
              className="btn-text"
              onClick={handleMarkAllAsRead}
              disabled={loading}
            >
              Mark all as read
            </button>
          )}

          <button
            className="btn-text"
            onClick={handleRefresh}
            disabled={loading}
          >
            Refresh
          </button>
        </div>
      </div>

      {error && <div className="error-message">{error}</div>}

      {sortedNotifications.length === 0 ? (
        <div className="no-notifications-message">
          You don't have any notifications yet.
        </div>
      ) : (
        <div className="notification-list">
          {sortedNotifications.map(notification => (
            <NotificationItem
              key={notification.id}
              notification={notification}
            />
          ))}

          {!showAll && notifications.length > 5 && (
            <div className="more-notifications">
              + {notifications.length - 5} more notifications
            </div>
          )}
        </div>
      )}
    </div>
  );
};

export default NotificationList;
