const express = require("express");
const cors = require("cors");
const sequelize = require("./config/database");
const taskRoutes = require("./routes/taskRoutes");

const app = express();
const PORT = process.env.PORT || 8082;

// Middleware
app.use(cors());
app.use(express.json());

// Routes
app.use("/api", taskRoutes);

// Test route
app.get("/", (req, res) => {
  res.send("Task service is running");
});

// Sync database and start server
sequelize.syncDatabase().then(() => {
  app.listen(PORT, () => {
    console.log(`Task service started on port ${PORT}`);
  });
});

module.exports = app;
