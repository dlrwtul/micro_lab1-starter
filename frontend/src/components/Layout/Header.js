// src/components/Layout/Header.js
import React, { useState, useContext, useRef, useEffect } from "react";
import { Link, useNavigate } from "react-router-dom";
import { FontAwesomeIcon } from "@fortawesome/react-fontawesome";
import {
  faBell,
  faUser,
  faSignOutAlt,
  faBars,
  faTimes,
} from "@fortawesome/free-solid-svg-icons";
import AuthContext from "../../contexts/AuthContext";
import NotificationContext from "../../contexts/NotificationContext";
import NotificationList from "../Notifications/NotificationList";
import "./Layout.css";

const Header = () => {
  const [showNotifications, setShowNotifications] = useState(false);
  const [showUserMenu, setShowUserMenu] = useState(false);
  const [showMobileMenu, setShowMobileMenu] = useState(false);

  const { currentUser, logout } = useContext(AuthContext);
  const { unreadCount } = useContext(NotificationContext);
  const navigate = useNavigate();

  const notificationRef = useRef(null);
  const userMenuRef = useRef(null);

  // Close menus when clicking outside
  useEffect(() => {
    const handleClickOutside = event => {
      if (
        notificationRef.current &&
        !notificationRef.current.contains(event.target)
      ) {
        setShowNotifications(false);
      }

      if (userMenuRef.current && !userMenuRef.current.contains(event.target)) {
        setShowUserMenu(false);
      }
    };

    document.addEventListener("mousedown", handleClickOutside);
    return () => {
      document.removeEventListener("mousedown", handleClickOutside);
    };
  }, []);

  const handleLogout = () => {
    logout();
    navigate("/login");
  };

  return (
    <header className="app-header">
      <div className="header-content">
        <div className="logo-container">
          <Link to="/" className="logo">
            Task Manager
          </Link>

          <button
            className="mobile-toggle"
            onClick={() => setShowMobileMenu(!showMobileMenu)}
          >
            <FontAwesomeIcon icon={showMobileMenu ? faTimes : faBars} />
          </button>
        </div>

        <nav className={`nav-menu ${showMobileMenu ? "show" : ""}`}>
          <ul>
            <li>
              <Link to="/dashboard" onClick={() => setShowMobileMenu(false)}>
                Dashboard
              </Link>
            </li>
            <li>
              <Link to="/tasks" onClick={() => setShowMobileMenu(false)}>
                Tasks
              </Link>
            </li>
            <li>
              <Link
                to="/notifications"
                onClick={() => setShowMobileMenu(false)}
              >
                Notifications
              </Link>
            </li>
          </ul>
        </nav>

        <div className="header-actions">
          {currentUser ? (
            <>
              <div className="notification-dropdown" ref={notificationRef}>
                <button
                  className="btn-icon notification-btn"
                  onClick={() => {
                    setShowNotifications(!showNotifications);
                    setShowUserMenu(false);
                  }}
                >
                  <FontAwesomeIcon icon={faBell} />
                  {unreadCount > 0 && (
                    <span className="notification-badge">{unreadCount}</span>
                  )}
                </button>

                {showNotifications && (
                  <div className="dropdown-menu notification-menu">
                    <NotificationList />
                    <div className="dropdown-footer">
                      <Link
                        to="/notifications"
                        onClick={() => setShowNotifications(false)}
                      >
                        View All
                      </Link>
                    </div>
                  </div>
                )}
              </div>

              <div className="user-dropdown" ref={userMenuRef}>
                <button
                  className="btn-icon user-btn"
                  onClick={() => {
                    setShowUserMenu(!showUserMenu);
                    setShowNotifications(false);
                  }}
                >
                  <FontAwesomeIcon icon={faUser} />
                </button>

                {showUserMenu && (
                  <div className="dropdown-menu user-menu">
                    <div className="user-info">
                      <div className="username">{currentUser.username}</div>
                      <div className="email">{currentUser.email}</div>
                    </div>

                    <ul>
                      <li>
                        <Link
                          to="/profile"
                          onClick={() => setShowUserMenu(false)}
                        >
                          Profile
                        </Link>
                      </li>
                      <li>
                        <button onClick={handleLogout} className="logout-btn">
                          <FontAwesomeIcon icon={faSignOutAlt} />
                          Log Out
                        </button>
                      </li>
                    </ul>
                  </div>
                )}
              </div>
            </>
          ) : (
            <div className="auth-buttons">
              <Link to="/login" className="btn-login">
                Log In
              </Link>
              <Link to="/register" className="btn-register">
                Register
              </Link>
            </div>
          )}
        </div>
      </div>
    </header>
  );
};

export default Header;
