// src/App.js
import React from "react";
import {
  BrowserRouter as Router,
  Routes,
  Route,
  Navigate,
} from "react-router-dom";
import { AuthProvider } from "./contexts/AuthContext";
import { NotificationProvider } from "./contexts/NotificationContext";
import Header from "./components/Layout/Header";
import Login from "./components/Auth/Login";
import Register from "./components/Auth/Register";
import Dashboard from "./components/Dashboard";
import TaskList from "./components/Tasks/TaskList";
import NotificationList from "./components/Notifications/NotificationList";
import PrivateRoute from "./components/PrivateRoute";
import "./App.css";

function App() {
  return (
    <Router>
      <AuthProvider>
        <NotificationProvider>
          <div className="app">
            <Header />
            <main className="main-content">
              <Routes>
                <Route
                  path="/"
                  element={<Navigate to="/dashboard" replace />}
                />

                <Route path="/login" element={<Login />} />
                <Route path="/register" element={<Register />} />

                <Route
                  path="/dashboard"
                  element={
                    <PrivateRoute>
                      <Dashboard />
                    </PrivateRoute>
                  }
                />

                <Route
                  path="/tasks"
                  element={
                    <PrivateRoute>
                      <TaskList />
                    </PrivateRoute>
                  }
                />

                <Route
                  path="/notifications"
                  element={
                    <PrivateRoute>
                      <div className="notifications-page">
                        <h1>All Notifications</h1>
                        <NotificationList showAll={true} />
                      </div>
                    </PrivateRoute>
                  }
                />

                <Route
                  path="*"
                  element={<Navigate to="/dashboard" replace />}
                />
              </Routes>
            </main>
            <footer className="app-footer">
              <p>&copy; {new Date().getFullYear()} Task Manager DMI/FST/UCAD</p>
            </footer>
          </div>
        </NotificationProvider>
      </AuthProvider>
    </Router>
  );
}

export default App;
