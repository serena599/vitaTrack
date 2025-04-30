const express = require("express");
const router = express.Router();
const { pool } = require("../databaseConfig");

// Get all recommended recipes
router.get("/recipes", (req, res) => {
  pool.query(
    "SELECT * FROM Recipe WHERE is_recommend = true;",
    (error, results) => {
      if (error) {
        console.error("Query error:", error);
        return res.status(500).json({ message: "Database query failed" });
      }
      // Convert is_recommend to true/false
      if (results && results.length > 0) {
        results.forEach((recipe) => {
          recipe.is_recommend = recipe.is_recommend === 1;
        });
      }
      res.json(results || []);
    }
  );
});

// Search recipes by name
router.post("/search", (req, res) => {
  const searchQuery = req.body.query;
  if (!searchQuery) {
    return res
      .status(400)
      .json({ message: "Search parameter cannot be empty" });
  }
  const sql = "SELECT * FROM Recipe WHERE recipe_name LIKE ? ;";
  pool.query(sql, [`%${searchQuery}%`], (error, results) => {
    if (error) {
      return res.status(500).json({ message: "Database query error" });
    }
    // Convert is_recommend to true/false
    if (results && results.length > 0) {
      results.forEach((recipe) => {
        recipe.is_recommend = recipe.is_recommend === 1;
      });
    }
    res.json(results || []);
  });
});

// Get user's favorite recipes
router.get("/favorites/:userID", (req, res) => {
  const userID = req.params.userID;
  if (!userID) {
    return res.status(400).json({ message: "User ID cannot be empty" });
  }

  const sql = "SELECT * FROM user_favorites WHERE user_id = ?";
  pool.query(sql, [userID], (error, results) => {
    if (error) {
      console.error("Query error:", error);
      return res.status(500).json({ message: "Database query error" });
    }
    res.json(results || []);
  });
});

// Add a recipe to favorites
router.post("/favorites/add", (req, res) => {
  const { user_id, recipe_ID } = req.body;
  if (!user_id || !recipe_ID) {
    return res
      .status(400)
      .json({ message: "User ID and Recipe ID cannot be empty" });
  }

  const sql =
    "INSERT INTO user_favorites (user_id, recipe_ID) VALUES (?, ?) ON DUPLICATE KEY UPDATE created_at = CURRENT_TIMESTAMP";
  pool.query(sql, [user_id, recipe_ID], (error, results) => {
    if (error) {
      console.error("Error adding favorite:", error);
      return res.status(500).json({ message: "Failed to add favorite" });
    }
    res.json({ message: "Successfully added to favorites" });
  });
});

// Remove a recipe from favorites
router.post("/favorites/remove", (req, res) => {
  const { user_id, recipe_ID } = req.body;
  if (!user_id || !recipe_ID) {
    return res
      .status(400)
      .json({ message: "User ID and Recipe ID cannot be empty" });
  }

  const sql = "DELETE FROM user_favorites WHERE user_id = ? AND recipe_ID = ?";
  pool.query(sql, [user_id, recipe_ID], (error, results) => {
    if (error) {
      console.error("Error removing favorite:", error);
      return res.status(500).json({ message: "Failed to remove favorite" });
    }
    res.json({ message: "Successfully removed from favorites" });
  });
});

// Get user's favorite recipes with details
router.get("/user-favorite-recipes/:userID", (req, res) => {
  const userID = req.params.userID;
  if (!userID) {
    return res.status(400).json({ message: "User ID cannot be empty" });
  }

  const sql = `
    SELECT r.* 
    FROM Recipe r
    JOIN user_favorites uf ON r.recipe_ID = uf.recipe_ID
    WHERE uf.user_id = ?
  `;

  pool.query(sql, [userID], (error, results) => {
    if (error) {
      console.error("Error fetching favorite recipes:", error);
      return res
        .status(500)
        .json({ message: "Failed to fetch favorite recipes" });
    }

    // Process boolean type conversion (if needed)
    if (results && results.length > 0) {
      results.forEach((recipe) => {
        recipe.is_recommend = recipe.is_recommend === 1;
      });
    }

    res.json(results || []);
  });
});

// Get detailed recipes by ID list
router.post("/recipes/favorites", (req, res) => {
  const { recipe_ids } = req.body;
  if (!recipe_ids || !Array.isArray(recipe_ids) || recipe_ids.length === 0) {
    return res.status(400).json({ message: "Recipe ID list cannot be empty" });
  }

  // Create placeholders for each ID
  const placeholders = recipe_ids.map(() => "?").join(",");
  const sql = `SELECT * FROM Recipe WHERE recipe_ID IN (${placeholders})`;

  pool.query(sql, recipe_ids, (error, results) => {
    if (error) {
      console.error("Error querying favorite recipes:", error);
      return res
        .status(500)
        .json({ message: "Failed to query favorite recipes" });
    }

    // Convert is_recommend from 1/0 to true/false
    if (results && results.length > 0) {
      results.forEach((recipe) => {
        recipe.is_recommend = recipe.is_recommend === 1;
      });
    }

    res.json(results || []);
  });
});

module.exports = router;
