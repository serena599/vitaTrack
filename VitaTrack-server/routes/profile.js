const express = require("express");
const multiparty = require("multiparty");
const path = require("path");
const fs = require("fs");
const { pool } = require("../databaseConfig");

const router = express.Router();

// Get user information
router.get("/user/:user_id", (req, res) => {
  const userId = req.params.user_id;
  console.log(`Getting user information for userId: ${userId}`);
  
  const query = "SELECT * FROM user WHERE user_id = ?";
  pool.query(query, [userId], (err, results) => {
    if (err) {
      console.error("Database query failed:", err);
      return res.status(500).json({ error: "Database query failed" });
    }
    
    console.log(`User query results: ${results ? results.length : 0} records found`);
    
    if (results.length > 0) {
      // If username is not present in the database results, use email as default username
      const user = results[0];
      if (!user.username) {
        user.username = user.email;
      }
      
      // Add joinedYear if not present, using the creation timestamp or current year as fallback
      if (!user.joinedYear) {
        // Try to extract from created_at if available
        if (user.created_at) {
          user.joinedYear = new Date(user.created_at).getFullYear().toString();
        } else {
          user.joinedYear = new Date().getFullYear().toString();
        }
      }
      
      res.json({ success: true, user: user });
    } else {
      res.status(404).json({ success: false, message: "User not found" });
    }
  });
});

// Update user information
router.put("/user/:user_id", (req, res) => {
  const userId = req.params.user_id;
  const { firstName, lastName, gender, dob, phone, email, username, joinedYear } = req.body;
  
  console.log(`Updating user ${userId} with data:`, req.body);
  
  // Validate required fields
  if (!firstName || !lastName || !email) {
    return res.status(400).json({ error: "Missing required fields: firstName, lastName, email" });
  }
  
  // First check if username and joinedYear columns exist
  pool.query("SHOW COLUMNS FROM user LIKE 'username'", (err, usernameResults) => {
    if (err) {
      console.error("Failed to check if username column exists:", err);
      return res.status(500).json({ error: "Database error" });
    }
    
    pool.query("SHOW COLUMNS FROM user LIKE 'joinedYear'", (err, joinedYearResults) => {
      if (err) {
        console.error("Failed to check if joinedYear column exists:", err);
        return res.status(500).json({ error: "Database error" });
      }
      
      // Prepare array of missing columns that need to be added
      const columnsToAdd = [];
      
      if (usernameResults.length === 0) {
        columnsToAdd.push("username VARCHAR(255)");
      }
      
      if (joinedYearResults.length === 0) {
        columnsToAdd.push("joinedYear VARCHAR(4)");
      }
      
      if (columnsToAdd.length > 0) {
        // One or more columns need to be added
        const alterQuery = `ALTER TABLE user ADD COLUMN ${columnsToAdd.join(", ADD COLUMN ")}`;
        
        pool.query(alterQuery, (alterErr) => {
          if (alterErr) {
            console.error("Failed to add columns:", alterErr);
            // Continue with update regardless of missing columns
          } else {
            console.log("Added columns to user table:", columnsToAdd.join(", "));
          }
          
          // Proceed with update
          proceedWithUpdate();
        });
      } else {
        // All columns exist, proceed with update
        proceedWithUpdate();
      }
    });
  });
  
  function proceedWithUpdate() {
    // Prepare SQL query with appropriate columns
    pool.query("SHOW COLUMNS FROM user", (err, allColumns) => {
      if (err) {
        console.error("Failed to get column list:", err);
        return res.status(500).json({ error: "Database error" });
      }
      
      // Get all column names
      const columnNames = allColumns.map(col => col.Field);
      
      // Build dynamic query based on existing columns
      const updateFields = [];
      const params = [];
      
      if (columnNames.includes('firstName')) {
        updateFields.push('firstName = ?');
        params.push(firstName);
      }
      
      if (columnNames.includes('lastName')) {
        updateFields.push('lastName = ?');
        params.push(lastName);
      }
      
      if (columnNames.includes('gender')) {
        updateFields.push('gender = ?');
        params.push(gender);
      }
      
      if (columnNames.includes('dob')) {
        updateFields.push('dob = ?');
        params.push(dob);
      }
      
      if (columnNames.includes('phone')) {
        updateFields.push('phone = ?');
        params.push(phone);
      }
      
      if (columnNames.includes('email')) {
        updateFields.push('email = ?');
        params.push(email);
      }
      
      if (columnNames.includes('username')) {
        updateFields.push('username = ?');
        params.push(username || email);
      }
      
      if (columnNames.includes('joinedYear')) {
        updateFields.push('joinedYear = ?');
        params.push(joinedYear || new Date().getFullYear().toString());
      }
      
      params.push(userId); // Add userId for WHERE clause
      
      // Create and execute the query
      const query = `UPDATE user SET ${updateFields.join(', ')} WHERE user_id = ?`;
      
      pool.query(query, params, (updateErr, results) => {
        if (updateErr) {
          console.error("Database update failed:", updateErr);
          return res.status(500).json({ error: "Database update failed" });
        }
        
        console.log(`Update result: affectedRows = ${results.affectedRows}`);
        
        if (results.affectedRows === 0) {
          return res.status(404).json({ success: false, message: "User not found" });
        }
        
        res.json({ success: true, message: "User information updated successfully" });
      });
    });
  }
});

// Upload avatar
router.post("/uploadAvatar", (req, res) => {
  console.log("Received avatar upload request");
  
  const form = new multiparty.Form();
  form.parse(req, (err, fields, files) => {
    if (err) {
      console.error("File upload parsing error:", err);
      return res.status(500).json({ error: "File upload failed" });
    }
    
    // Accept both userId and user_id parameter names
    const userId = fields.userId ? fields.userId[0] : (fields.user_id ? fields.user_id[0] : null);
    
    console.log("Received avatar upload request, userId:", userId);
    console.log("Available fields:", Object.keys(fields));
    
    // Check if userId was provided
    if (!userId) {
      return res.status(400).json({ error: "userId is required" });
    }
    
    // Check if avatar file was provided
    if (!files.avatar || !files.avatar[0]) {
      return res.status(400).json({ error: "No avatar file provided" });
    }
    
    const file = files.avatar[0];
    const fileName = `user_${userId}_${Date.now()}_${path.basename(file.path)}`; // Generate unique filename
    const uploadDir = path.join(__dirname, "../uploads/avatars");
    const filePath = path.join(uploadDir, fileName);
    
    console.log("Saving avatar to:", filePath);
    
    // Ensure the upload directory exists
    if (!fs.existsSync(uploadDir)) {
      fs.mkdirSync(uploadDir, { recursive: true });
    }
    
    // Move file to target directory
    fs.renameSync(file.path, filePath);
    
    // Save file path to database
    const avatarUrl = `/uploads/avatars/${fileName}`;
    pool.query("UPDATE user SET avatar_path = ? WHERE user_id = ?", [avatarUrl, userId], (err, result) => {
      if (err) {
        console.error("Database update failed:", err);
        return res.status(500).json({ error: "Database update failed" });
      }
      
      console.log("Avatar path updated in database:", avatarUrl);
      console.log("Database update result:", result);
      
      res.json({ success: true, avatarUrl });
    });
  });
});

// Reset password
router.put("/user/:user_id/updatePassword", (req, res) => {
  const userId = req.params.user_id;
  const { newPassword } = req.body;
  
  console.log(`Updating password for user ${userId}`);
  
  // Validate required fields
  if (!newPassword) {
    return res.status(400).json({ error: "Missing required field: newPassword" });
  }
  
  const query = "UPDATE user SET password = ? WHERE user_id = ?";
  pool.query(query, [newPassword, userId], (err, results) => {
    if (err) {
      console.error("Password update failed:", err);
      return res.status(500).json({ error: "Password update failed" });
    }
    
    console.log(`Password update result: affectedRows = ${results.affectedRows}`);
    
    if (results.affectedRows === 0) {
      return res.status(404).json({ success: false, message: "User not found" });
    }
    
    res.json({ success: true, message: "Password updated successfully" });
  });
});

module.exports = router;