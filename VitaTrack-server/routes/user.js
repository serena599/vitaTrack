const express = require("express");
const router = express.Router();
const { pool } = require("../databaseConfig");

// Login endpoint
router.post("/login", (req, res) => {
  const { username, password } = req.body;
  const sql = "SELECT * FROM user WHERE username = ? AND password = ?";
  pool.query(sql, [username, password], (error, results) => {
    if (error) {
      return res.status(500).json({
        success: false,
        message: "Login failed, server error",
      });
    }
    if (results.length > 0) {
      const user = results[0];
      res.json({
        success: true,
        message: "Login successful",
        user: {
          id: user.user_id,
          user_id: user.user_id,
          username: user.username,
        },
      });
    } else {
      res.json({
        success: false,
        message: "Invalid username or password",
      });
    }
  });
});

// Signup endpoint
router.post("/signup", (req, res) => {
  const { username, password, email, phone, firstName, lastName, dob } =
    req.body;

  // Validate required fields
  if (!username || !password || !email) {
    return res.status(400).json({
      success: false,
      message: "Username, password and email are required",
    });
  }

  // Validate email format
  const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
  if (!emailRegex.test(email)) {
    return res.status(400).json({
      success: false,
      message: "Invalid email format",
    });
  }

  // Convert username to lowercase for case-insensitive comparison
  const lowercaseUsername = username.toLowerCase();

  // Check if username or email already exists
  pool.query(
    "SELECT username, email FROM user WHERE LOWER(username) = ? OR email = ?",
    [lowercaseUsername, email],
    (error, results) => {
      if (error) {
        return res.status(500).json({
          success: false,
          message: "Registration failed, server error",
        });
      }

      if (results.length > 0) {
        const existingUser = results[0];
        if (existingUser.username.toLowerCase() === lowercaseUsername) {
          return res.json({
            success: false,
            message: "Username already exists",
          });
        }
        if (existingUser.email === email) {
          return res.json({
            success: false,
            message: "Email already exists",
          });
        }
      }

      // Insert new user with all required fields
      const currentYear = new Date().getFullYear().toString();
      const sql =
        "INSERT INTO user (username, password, email, phone, joinedYear, firstName, lastName, gender, dob) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";

      const values = [
        lowercaseUsername,
        password,
        email,
        phone || "",
        currentYear,
        firstName || lowercaseUsername,
        lastName || "",
        "",
        dob || new Date().toISOString().split("T")[0],
      ];

      pool.query(sql, values, (error, results) => {
        if (error) {
          return res.status(500).json({
            success: false,
            message: "Registration failed, server error",
            details: error.message,
          });
        }
        res.json({
          success: true,
          message: "Registration successful",
          userId: results.insertId,
          user: {
            id: results.insertId,
            user_id: results.insertId,
            username: lowercaseUsername,
          },
        });
      });
    }
  );
});

module.exports = router;
