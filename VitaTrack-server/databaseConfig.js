const mysql = require("mysql2");
const path = require("path");
require("dotenv").config({ path: path.join(__dirname, ".env") });

// Add debug logs
console.log("Database Configuration:", {
 host: process.env.DB_HOST,
 user: process.env.DB_USER,
 database: process.env.DB_NAME,
 // Don't print password for security reasons
});

// Validate environment variables
if (
 !process.env.DB_HOST ||
 !process.env.DB_USER ||
 !process.env.DB_PASSWORD ||
 !process.env.DB_NAME
) {
 console.error("Missing required environment variables");
 console.error("Current environment variables:", {
   DB_HOST: process.env.DB_HOST,
   DB_USER: process.env.DB_USER,
   DB_NAME: process.env.DB_NAME,
   // Don't print password for security reasons
 });
 process.exit(1);
}

// Create MySQL connection pool
const pool = mysql.createPool({
 host: process.env.DB_HOST,
 user: process.env.DB_USER,
 password: process.env.DB_PASSWORD,
 database: process.env.DB_NAME,
 waitForConnections: true,
 connectionLimit: 10,
 queueLimit: 0,
});

// Test database connection
pool.getConnection((err, connection) => {
  if (err) {
    console.error("Database connection failed:", err);
    process.exit(1);
  }
  console.log("Database connected successfully");
  connection.release();
});

// Export both the pool object directly and as a property
// This allows both syntaxes:
// const pool = require('./databaseConfig');  
// const { pool } = require('./databaseConfig');
module.exports = pool;
module.exports.pool = pool;