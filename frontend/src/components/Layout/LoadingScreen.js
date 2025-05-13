// src/components/Layout/LoadingScreen.js
import React from "react";
import "./Layout.css";

const LoadingScreen = ({ message = "Loading..." }) => {
  return (
    <div className="loading-screen">
      <div className="loading-content">
        <div className="loading-spinner"></div>
        <p>{message}</p>
      </div>
    </div>
  );
};

export default LoadingScreen;
