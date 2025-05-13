// src/contexts/NotificationContext.js
import React, { createContext, useState, useEffect, useContext } from "react";
import AuthContext from "./AuthContext";
import notificationService from "../services/notificationService";

export const NotificationContext = createContext();

export const NotificationProvider = ({ children }) => {
  const [notifications, setNotifications] = useState([]);
  const [unreadCount, setUnreadCount] = useState(0);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState(null);

  const { currentUser, isAuthenticated } = useContext(AuthContext);

  // Fetch notifications when user changes
  useEffect(() => {
    if (isAuthenticated && currentUser) {
      fetchUserNotifications();
    } else {
      setNotifications([]);
      setUnreadCount(0);
    }
  }, [currentUser, isAuthenticated]);

  // Set up periodic checks for due tasks
  useEffect(() => {
    if (!isAuthenticated) return;

    // Check for due tasks when the component mounts
    checkDueTasks();

    // Set up interval to check for due tasks every 5 minutes
    const intervalId = setInterval(checkDueTasks, 5 * 60 * 1000);

    // Clean up interval on unmount
    return () => {
      clearInterval(intervalId);
    };
  }, [isAuthenticated]);

  // Count unread notifications when notifications change
  useEffect(() => {
    const count = notifications.filter(
      notification => !notification.read
    ).length;
    setUnreadCount(count);
  }, [notifications]);

  const fetchUserNotifications = async () => {
    if (!currentUser) return;

    setLoading(true);
    setError(null);

    try {
      const data = await notificationService.getUserNotifications(
        currentUser.id
      );
      setNotifications(data);
    } catch (err) {
      console.error("Error fetching notifications:", err);
      setError(err.error || "Failed to fetch notifications");
    } finally {
      setLoading(false);
    }
  };

  const checkDueTasks = async () => {
    if (!isAuthenticated) return;

    try {
      const newNotifications = await notificationService.checkDueTasks();
      if (newNotifications && newNotifications.length > 0) {
        // Refresh notifications list
        fetchUserNotifications();
      }
    } catch (err) {
      console.error("Error checking due tasks:", err);
    }
  };

  const markAsRead = async notificationId => {
    setLoading(true);

    try {
      const updatedNotification = await notificationService.markAsRead(
        notificationId
      );

      // Update the notifications array
      setNotifications(
        notifications.map(notification =>
          notification.id === notificationId
            ? updatedNotification
            : notification
        )
      );
    } catch (err) {
      console.error("Error marking notification as read:", err);
      setError(err.error || "Failed to mark notification as read");
    } finally {
      setLoading(false);
    }
  };

  const markAllAsRead = async () => {
    setLoading(true);

    try {
      const unreadNotifications = notifications.filter(
        notification => !notification.read
      );

      // Mark each unread notification as read
      for (const notification of unreadNotifications) {
        await notificationService.markAsRead(notification.id);
      }

      // Update all notifications to read
      setNotifications(
        notifications.map(notification => ({
          ...notification,
          read: true,
        }))
      );
    } catch (err) {
      console.error("Error marking all notifications as read:", err);
      setError(err.error || "Failed to mark all notifications as read");
    } finally {
      setLoading(false);
    }
  };

  return (
    <NotificationContext.Provider
      value={{
        notifications,
        unreadCount,
        loading,
        error,
        fetchUserNotifications,
        markAsRead,
        markAllAsRead,
        checkDueTasks,
      }}
    >
      {children}
    </NotificationContext.Provider>
  );
};

export default NotificationContext;
