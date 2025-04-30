const express = require("express");
const cors = require("cors");
const bodyParser = require("body-parser");
const path = require("path");
const fs = require("fs");
const app = express();
const port = 4000;
const pool = require("./databaseConfig");

// Middleware
app.use(cors());
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: true }));
app.use(express.json()); // Parse JSON requests

// Ensure upload directories exist
const uploadDirs = {
  avatars: path.join(__dirname, "uploads/avatars"),
  foodImages: path.join(__dirname, "uploads/food_images"),
};

Object.values(uploadDirs).forEach((dir) => {
  if (!fs.existsSync(dir)) {
    fs.mkdirSync(dir, { recursive: true });
  }
});

// Create necessary tables
pool.getConnection((err, connection) => {
  if (err) {
    process.exit(1);
  }

  const createTablesQueries = [
    `CREATE TABLE IF NOT EXISTS user (
        user_id INT AUTO_INCREMENT PRIMARY KEY,
        firstName VARCHAR(255) NOT NULL,
        lastName VARCHAR(255) NOT NULL,
        gender VARCHAR(50),
        dob DATE,
        phone VARCHAR(20),
        email VARCHAR(255) NOT NULL,
        joinedYear VARCHAR(4),
        password VARCHAR(255) NOT NULL,
        avatar_path VARCHAR(255),
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        username VARCHAR(100)
    )`,
    `CREATE TABLE IF NOT EXISTS foods (
        id INT AUTO_INCREMENT PRIMARY KEY,
        name VARCHAR(255) NOT NULL,
        calories INT NOT NULL,
        unit VARCHAR(50) NOT NULL,
        amount DOUBLE NOT NULL,
        user_id INT NOT NULL,
        food_category VARCHAR(50),
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (user_id) REFERENCES user(user_id)
    )`,
    `CREATE TABLE IF NOT EXISTS meal_records (
        id INT AUTO_INCREMENT PRIMARY KEY,
        user_id INT NOT NULL,
        food_id INT NOT NULL,
        amount DOUBLE NOT NULL,
        meal_type VARCHAR(50) NOT NULL,
        food_category VARCHAR(50),
        image_url VARCHAR(255),
        record_date DATE NOT NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (user_id) REFERENCES user(user_id),
        FOREIGN KEY (food_id) REFERENCES foods(id)
    )`,
    `CREATE TABLE IF NOT EXISTS food_records (
        record_id INT AUTO_INCREMENT PRIMARY KEY,
        user_id INT NOT NULL,
        record_date DATETIME NOT NULL,
        image_url VARCHAR(255),
        meal_type VARCHAR(50) NOT NULL,
        vegetables INT NOT NULL DEFAULT 0,
        fruit INT NOT NULL DEFAULT 0,
        grains INT NOT NULL DEFAULT 0,
        meat INT NOT NULL DEFAULT 0,
        dairy INT NOT NULL DEFAULT 0,
        extras INT NOT NULL DEFAULT 0,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (user_id) REFERENCES user(user_id)
    )`,
    `CREATE TABLE IF NOT EXISTS user_favorites (
        id INT AUTO_INCREMENT PRIMARY KEY,
        user_id INT NOT NULL,
        recipe_ID INT NOT NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        UNIQUE KEY user_recipe (user_id, recipe_ID)
    )`,
    `CREATE TABLE IF NOT EXISTS goal_settings (
        id INT AUTO_INCREMENT PRIMARY KEY,
        user_id INT NOT NULL,
        vegetables DECIMAL(5,2) NOT NULL DEFAULT 0,
        fruits DECIMAL(5,2) NOT NULL DEFAULT 0,
        grains DECIMAL(5,2) NOT NULL DEFAULT 0,
        meat DECIMAL(5,2) NOT NULL DEFAULT 0,
        dairy DECIMAL(5,2) NOT NULL DEFAULT 0,
        extras DECIMAL(5,2) NOT NULL DEFAULT 0,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
        UNIQUE KEY user_id (user_id),
        FOREIGN KEY (user_id) REFERENCES user(user_id)
    )`,
  ];

  createTablesQueries.forEach((query) => {
    connection.query(query, (err) => {
      // Error handling remains but without logging
    });
  });

  // Release the connection when done
  connection.release();
});

// Import routes
const userRoutes = require("./routes/user");
const foodRoutes = require("./routes/foods");
const profileRoutes = require("./routes/profile");
const cameraRoutes = require("./routes/camera");
const recipeRoutes = require("./routes/recipe");
const homepageRoutes = require("./routes/homepage");

// Routes
app.use("/api", userRoutes);
app.use("/api", foodRoutes);
app.use("/api", profileRoutes);
app.use("/api", cameraRoutes);
app.use("/api", recipeRoutes);
app.use("/api", homepageRoutes);

// Serve static files
app.use("/uploads", express.static(path.join(__dirname, "uploads")));

// Error handling middleware
app.use((err, req, res, next) => {
  res.status(500).json({
    message: "Server error",
    error: err.message,
    details: err.stack,
  });
});

app.post("/api/update_goal", (req, res) => {
  const { userId, vegetables, fruits, grains, meat, dairy, extras } = req.body;
  if (!userId) {
    return res.status(400).json({ error: "User ID can not be null!" });
  }
  const sql = `
      INSERT INTO goal_settings (user_id, vegetables, fruits, grains, meat, dairy, extras)
      VALUES (?, ?, ?, ?, ?, ?, ?)
      ON DUPLICATE KEY UPDATE 
          vegetables = VALUES(vegetables),
          fruits = VALUES(fruits),
          grains = VALUES(grains),
          meat = VALUES(meat),
          dairy = VALUES(dairy),
          extras = VALUES(extras);
  `;
  pool.query(
    sql,
    [userId, vegetables, fruits, grains, meat, dairy, extras],
    (err, result) => {
      if (err) {
        res.status(500).json({ error: "Server Error" });
      } else {
        res.json({ message: "Updated Successfully!" });
      }
    }
  );
});

app.post("/update_goal", (req, res) => {
  const { userId, vegetables, fruits, grains, meat, dairy, extras } = req.body;
  if (!userId) {
    return res.status(400).json({ error: "User ID can not be null!" });
  }

  const sql = `
      INSERT INTO goal_settings (user_id, vegetables, fruits, grains, meat, dairy, extras)
      VALUES (?, ?, ?, ?, ?, ?, ?)
      ON DUPLICATE KEY UPDATE 
          vegetables = VALUES(vegetables),
          fruits = VALUES(fruits),
          grains = VALUES(grains),
          meat = VALUES(meat),
          dairy = VALUES(dairy),
          extras = VALUES(extras);
  `;
  pool.query(
    sql,
    [userId, vegetables, fruits, grains, meat, dairy, extras],
    (err, result) => {
      if (err) {
        res.status(500).json({ error: "Server Error" });
      } else {
        res.json({ message: "Updated Successfully!" });
      }
    }
  );
});

// Daily Intake
app.get("/api/daily_intake", (req, res) => {
  const { userId, date } = req.query;

  if (!userId || !date) {
    return res.status(400).json({ error: "Id and date can not be null" });
  }

  const sql = `
    SELECT 
      COALESCE(SUM(vegetables), 0) as vegetables,
      COALESCE(SUM(fruits), 0) as fruits,
      COALESCE(SUM(grains), 0) as grains,
      COALESCE(SUM(meat), 0) as meat,
      COALESCE(SUM(dairy), 0) as dairy,
      COALESCE(SUM(extras), 0) as extras
    FROM (
      -- 从food_records表获取数据
      SELECT 
        vegetables,
        fruit as fruits,
        grains,
        meat,
        dairy,
        extras
      FROM food_records
      WHERE user_id = ? AND DATE(record_date) = ?
      
      UNION ALL
      
      -- 从meal_records和foods表关联查询，使用meal_records的record_date
      SELECT 
        SUM(CASE WHEN f.food_category = 'vegetables' THEN mr.amount ELSE 0 END) as vegetables,
        SUM(CASE WHEN f.food_category = 'fruits' THEN mr.amount ELSE 0 END) as fruits,
        SUM(CASE WHEN f.food_category = 'grains' THEN mr.amount ELSE 0 END) as grains,
        SUM(CASE WHEN f.food_category = 'meat' THEN mr.amount ELSE 0 END) as meat,
        SUM(CASE WHEN f.food_category = 'dairy' THEN mr.amount ELSE 0 END) as dairy,
        SUM(CASE WHEN f.food_category = 'extras' THEN mr.amount ELSE 0 END) as extras
      FROM meal_records mr
      JOIN foods f ON mr.food_id = f.id
      WHERE mr.user_id = ? AND DATE(mr.record_date) = ?
      GROUP BY DATE(mr.record_date)
    ) combined_data
  `;

  pool.query(sql, [userId, date, userId, date], (err, result) => {
    if (err) {
      return res
        .status(500)
        .json({ error: "Database query failed", details: err.message });
    }

    // Handle empty result set
    const defaultResponse = {
      vegetables: 0,
      fruits: 0,
      grains: 0,
      meat: 0,
      dairy: 0,
      extras: 0,
    };

    if (!result || result.length === 0) {
      return res.json(defaultResponse);
    }

    // Ensure all values are numbers and not null
    const response = {
      vegetables: Number(result[0].vegetables) || 0,
      fruits: Number(result[0].fruits) || 0,
      grains: Number(result[0].grains) || 0,
      meat: Number(result[0].meat) || 0,
      dairy: Number(result[0].dairy) || 0,
      extras: Number(result[0].extras) || 0,
    };

    res.json(response);
  });
});

// Get Goals
app.get("/api/goal_settings", (req, res) => {
  const userId = req.query.userId;

  if (!userId) {
    return res.status(400).json({ error: "User ID can not be null!" });
  }

  const sql = "SELECT * FROM goal_settings WHERE user_id = ?";
  pool.query(sql, [userId], (err, result) => {
    if (err) {
      res.status(500).json({ error: "Server Error" });
    } else if (result.length === 0) {
      res.json({ message: "No user data", data: {} });
    } else {
      res.json(result[0]);
    }
  });
});

// Delete food record
app.delete("/api/meal-records/:id", async (req, res) => {
  const connection = await pool.promise().getConnection();

  try {
    await connection.beginTransaction();

    const { id } = req.params;

    // First delete records from meal_records table
    const [mealResult] = await connection.query(
      "DELETE FROM meal_records WHERE food_id = ?",
      [id]
    );

    // Then delete record from foods table (只有在没有其他关联的情况下)
    if (mealResult.affectedRows > 0) {
      const [foodResult] = await connection.query(
        "DELETE FROM foods WHERE id = ?",
        [id]
      );

      await connection.commit();

      res.json({
        success: true,
        message: "Record completely deleted",
        affectedRows: {
          meals: mealResult.affectedRows,
          foods: foodResult.affectedRows,
        },
      });
    } else {
      await connection.commit();
      res.json({
        success: true,
        message: "No records found to delete",
        affectedRows: {
          meals: 0,
          foods: 0,
        },
      });
    }
  } catch (error) {
    await connection.rollback();
    res.status(500).json({
      success: false,
      message: "Delete failed",
      error: error.message,
    });
  } finally {
    connection.release();
  }
});

// Start server
app.listen(port, "0.0.0.0", () => {
  console.log(
    `Server running on port: ${port} and accessible from external devices`
  );
});
