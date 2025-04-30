const express = require('express');
const router = express.Router();
const mysql = require('mysql2');
const pool = require('../databaseConfig');

/**
 * Endpoint for getting comprehensive nutrition progress data
 * Consolidates goal settings, daily intake, and progress calculation
 */
router.get('/nutrition_progress', (req, res) => {
  const { userId, date } = req.query;
  
  if (!userId) {
    return res.status(400).json({
      success: false,
      message: 'User ID is required',
      data: null
    });
  }
  
  // Use today's date if not provided
  const queryDate = date || new Date().toISOString().slice(0, 10);
  
  // First, check if goal_settings table exists
  pool.query(`SHOW TABLES LIKE 'goal_settings'`, (err, tables) => {
    if (err) {
      return res.status(500).json({
        success: false,
        message: 'Database error',
        data: null
      });
    }
    
    // If table doesn't exist, create it
    if (tables.length === 0) {
      const createTableSQL = `
        CREATE TABLE IF NOT EXISTS goal_settings (
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
          UNIQUE KEY user_id (user_id)
        )
      `;
      
      pool.query(createTableSQL, (err) => {
        if (err) {
          return res.status(500).json({
            success: false,
            message: 'Failed to create goal_settings table',
            data: null
          });
        }
        
        // After creating table, continue with data fetch
        fetchNutritionProgress();
      });
    } else {
      // Table exists, proceed with data fetch
      fetchNutritionProgress();
    }
  });

  function fetchNutritionProgress() {
    // Get user's goal settings
    pool.query(
      'SELECT vegetables, fruits, grains, meat, dairy, extras FROM goal_settings WHERE user_id = ?',
      [userId],
      (err, goalResults) => {
        if (err) {
          return res.status(500).json({
            success: false,
            message: 'Error fetching goal settings',
            data: null
          });
        }
        
        let goalSettings;
        
        if (goalResults.length === 0) {
          // No goals set, use default values
          goalSettings = {
            vegetables: 5.0,
            fruits: 2.0,
            grains: 5.0,
            meat: 2.5,
            dairy: 2.5,
            extras: 0.5
          };
          
          // Insert default goal for this user
          pool.query(
            'INSERT INTO goal_settings (user_id, vegetables, fruits, grains, meat, dairy, extras) VALUES (?, ?, ?, ?, ?, ?, ?)',
            [userId, goalSettings.vegetables, goalSettings.fruits, goalSettings.grains, goalSettings.meat, goalSettings.dairy, goalSettings.extras],
            (err) => {
              // Error handled silently
            }
          );
        } else {
          goalSettings = goalResults[0];
        }
        
        // Use the same query logic as the fixed daily_intake, including data from both food_records and meal_records tables
        // Get data from the food_records table
        // Join query from meal_records and foods tables, using meal_records' record_date
        const dailyIntakeSQL = `
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
        
        pool.query(dailyIntakeSQL, [userId, queryDate, userId, queryDate], (err, intakeResults) => {
          if (err) {
            return res.status(500).json({
              success: false,
              message: 'Error fetching daily intake',
              data: null
            });
          }
          
          // Default intake values if no results
          const dailyIntake = intakeResults.length > 0 ? intakeResults[0] : {
            vegetables: 0,
            fruits: 0,
            grains: 0,
            meat: 0,
            dairy: 0,
            extras: 0
          };
          
          // Convert from MySQL BigInt to Number and handle null values
          Object.keys(dailyIntake).forEach(key => {
            dailyIntake[key] = Number(dailyIntake[key]) || 0;
          });
          
          // Calculate progress for each category
          const vegetablesProgress = Math.min(dailyIntake.vegetables / Math.max(goalSettings.vegetables, 1), 1.0);
          const fruitsProgress = Math.min(dailyIntake.fruits / Math.max(goalSettings.fruits, 1), 1.0);
          const grainsProgress = Math.min(dailyIntake.grains / Math.max(goalSettings.grains, 1), 1.0);
          const meatProgress = Math.min(dailyIntake.meat / Math.max(goalSettings.meat, 1), 1.0);
          const dairyProgress = Math.min(dailyIntake.dairy / Math.max(goalSettings.dairy, 1), 1.0);
          const extrasProgress = Math.min(dailyIntake.extras / Math.max(goalSettings.extras, 1), 1.0);
          
          // Calculate total progress (simple average)
          const totalProgress = (vegetablesProgress + fruitsProgress + grainsProgress + meatProgress + dairyProgress + extrasProgress) / 6.0;
          
          // Format the nutrition progress data
          const categoriesData = [
            {
              name: 'Vegetables',
              goalValue: parseFloat(goalSettings.vegetables) || 0,
              consumedValue: dailyIntake.vegetables || 0,
              progress: parseFloat(vegetablesProgress)
            },
            {
              name: 'Fruit',
              goalValue: parseFloat(goalSettings.fruits) || 0,
              consumedValue: dailyIntake.fruits || 0,
              progress: parseFloat(fruitsProgress)
            },
            {
              name: 'Grains',
              goalValue: parseFloat(goalSettings.grains) || 0,
              consumedValue: dailyIntake.grains || 0,
              progress: parseFloat(grainsProgress)
            },
            {
              name: 'Meat',
              goalValue: parseFloat(goalSettings.meat) || 0,
              consumedValue: dailyIntake.meat || 0,
              progress: parseFloat(meatProgress)
            },
            {
              name: 'Dairy',
              goalValue: parseFloat(goalSettings.dairy) || 0,
              consumedValue: dailyIntake.dairy || 0,
              progress: parseFloat(dairyProgress)
            },
            {
              name: 'Extras',
              goalValue: parseFloat(goalSettings.extras) || 0,
              consumedValue: dailyIntake.extras || 0,
              progress: parseFloat(extrasProgress)
            }
          ];
          
          // Use queryDate directly (string) instead of converting to Date object
          const response = {
            success: true,
            message: 'Nutrition progress data fetched successfully',
            data: {
              userId: parseInt(userId),
              date: queryDate,
              totalProgress: totalProgress,
              categories: categoriesData
            }
          };
          
          return res.json(response);
        });
      }
    );
  }
});

// Goal Settings Endpoint
router.get('/goal_settings', (req, res) => {
  const { userId } = req.query;
  
  if (!userId) {
    return res.status(400).json({
      success: false,
      message: 'User ID is required'
    });
  }
  
  const DEFAULT_GOALS = {
    vegetables: 5.0,
    fruits: 2.0,
    grains: 5.0,
    meat: 2.5,
    dairy: 2.5,
    extras: 0.5
  };

  pool.query(
    'SELECT vegetables, fruits, grains, meat, dairy, extras FROM goal_settings WHERE user_id = ?',
    [userId],
    (err, results) => {
      if (err) {
        return res.status(500).json({
          success: false,
          message: 'Database error'
        });
      }
      
      // Return found settings or default goals
      return res.json(results.length > 0 ? results[0] : DEFAULT_GOALS);
    }
  );
});

// Update Goal Endpoint
router.post("/update_goal", (req, res) => {
  const { userId, vegetables, fruits, grains, meat, dairy, extras } = req.body;

  if (!userId) {
    return res.status(400).json({ error: "User ID cannot be null!" });
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
      extras = VALUES(extras)
  `;

  pool.query(
    sql,
    [userId, vegetables, fruits, grains, meat, dairy, extras],
    (err, result) => {
      if (err) {
        return res.status(500).json({ error: "Server Error" });
      }
      
      return res.json({ 
        success: true,
        message: "Goals updated successfully!" 
      });
    }
  );
});

// Daily Nutrition Intake Endpoint
router.get("/daily_nutrition", (req, res) => {
  const { userId, date } = req.query;

  if (!userId || !date) {
    return res.status(400).json({ 
      error: "User ID and date are required" 
    });
  }

  const sql = `
    SELECT 
      COALESCE(SUM(vegetables), 0) as vegetables,
      COALESCE(SUM(fruit), 0) as fruits,
      COALESCE(SUM(grains), 0) as grains,
      COALESCE(SUM(meat), 0) as meat,
      COALESCE(SUM(dairy), 0) as dairy,
      COALESCE(SUM(extras), 0) as extras
    FROM food_records
    WHERE user_id = ? AND DATE(record_date) = ?
  `;

  pool.query(sql, [userId, date], (err, result) => {
    if (err) {
      return res.status(500).json({ 
        error: "Database query failed", 
        details: err.message 
      });
    }

    // Default response if no data found
    const defaultResponse = {
      vegetables: 0,
      fruits: 0,
      grains: 0,
      meat: 0,
      dairy: 0,
      extras: 0
    };

    // Return results or default
    return res.json(result.length > 0 ? result[0] : defaultResponse);
  });
});

module.exports = router;