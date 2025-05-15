const { DataTypes } = require("sequelize");
const sequelize = require("../config/database");

// TODO-MS7: Complétez la définition du modèle Task
// Le modèle doit contenir les champs suivants :
// - id : identifiant unique auto-incrémenté
// - title : titre de la tâche (obligatoire)
// - description : description de la tâche (optionnel)
// - dueDate : date d'échéance (optionnel)
// - completed : statut de complétion (booléen, par défaut false)
// - userId : identifiant de l'utilisateur propriétaire (obligatoire)
// Activez également le timestamp pour avoir createdAt et updatedAt automatiquement

const Task = sequelize.define(
  "Task",
  {
    id: {
      type: DataTypes.INTEGER,
      primaryKey: true,
      autoIncrement: true,
    },
    title: {
      type: DataTypes.STRING,
      allowNull: false,
    },
    description: {
      type: DataTypes.TEXT,
      allowNull: true,
    },
    dueDate: {
      type: DataTypes.DATE,
      allowNull: true,
    },
    completed: {
      type: DataTypes.BOOLEAN,
      defaultValue: false,
    },
    userId: {
      type: DataTypes.INTEGER,
      allowNull: false,
    },
  },
  {
    timestamps: true,
  }
);

module.exports = Task;
