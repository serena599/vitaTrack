const express = require("express");
const router = express.Router();
const { pool } = require("../databaseConfig");

// Login endpoint
router.post("/login", (req, res) => {
  console.log("Received login request:", req.body);
  const { username, password } = req.body;
  // Validate username and password
  const sql = "SELECT * FROM user WHERE username = ? AND password = ?";
  pool.query(sql, [username, password], (error, results) => {
    if (error) {
      console.error("Login error:", error);
      return res.status(500).json({
        success: false,
        message: "Login failed, server error",
      });
    }
    if (results.length > 0) {
      console.log("Login successful for user:", username);
      res.json({
        success: true,
        message: "Login successful",
        user: {
          id: results[0].user_id,
          username: results[0].username,
        },
      });
    } else {
      console.log("Login failed: Invalid credentials");
      res.json({
        success: false,
        message: "Invalid username or password",
      });
    }
  });
});

// Signup endpoint
router.post("/signup", (req, res) => {
  console.log("Received signup request:", req.body);
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
        console.error("Signup error:", error);
        return res.status(500).json({
          success: false,
          message: "Registration failed, server error",
        });
      }

      // Log the results for debugging
      console.log("Existing user check results:", results);

      if (results.length > 0) {
        const existingUser = results[0];
        if (existingUser.username.toLowerCase() === lowercaseUsername) {
          console.log("Signup failed: Username exists (case-insensitive)");
          return res.json({
            success: false,
            message: "Username already exists",
          });
        }
        if (existingUser.email === email) {
          console.log("Signup failed: Email exists");
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
        lowercaseUsername, // Store username in lowercase
        password,
        email,
        phone || "",
        currentYear,
        firstName || lowercaseUsername,
        lastName || "",
        "",
        dob || new Date().toISOString().split("T")[0],
      ];

      // Log the SQL query and values for debugging
      console.log("SQL Query:", sql);
      console.log("Values:", values);

      pool.query(sql, values, (error, results) => {
        if (error) {
          console.error("User creation error:", error);
          return res.status(500).json({
            success: false,
            message: "Registration failed, server error",
            details: error.message,
          });
        }
        console.log("User created successfully");
        res.json({
          success: true,
          message: "Registration successful",
          userId: results.insertId,
        });
      });
    }
  );
});

module.exports = router;
