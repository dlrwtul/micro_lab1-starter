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
    // À implémenter
  },
  {
    // À implémenter
  }
);

module.exports = Task;
