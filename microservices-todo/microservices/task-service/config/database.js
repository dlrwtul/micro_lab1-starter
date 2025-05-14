const { Sequelize } = require("sequelize");
const path = require("path");

const sequelize = new Sequelize({
  dialect: "sqlite",
  storage: path.join(__dirname, "../data/tasks.sqlite"),
  logging: false,
});

// Function to sync the model with the database
const syncDatabase = async () => {
  try {
    await sequelize.sync({ alter: true });
    console.log("Database synchronized successfully");
  } catch (error) {
    console.error("Error synchronizing database:", error);
  }
};

module.exports = sequelize;
module.exports.syncDatabase = syncDatabase;
