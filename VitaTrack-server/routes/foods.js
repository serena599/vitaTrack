const express = require("express");
const router = express.Router();
const { pool } = require("../databaseConfig");

// Define server base URL variable
const SERVER_BASE_URL = "http://192.168.1.109:4000";

// Get all foods
router.get("/foods", (req, res) => {
  pool.query("SELECT * FROM foods ORDER BY id DESC", (error, results) => {
    if (error) {
      console.error("Database error:", error);
      return res.status(500).json({
        message: "Query failed",
        error: error.message,
      });
    }

    const formattedResults = results.map((food) => ({
      local_id: food.id.toString(),
      db_id: food.id,
      name: food.name,
      calories: food.calories,
      unit: food.unit,
      amount: food.amount,
      food_category: food.food_category,
    }));

    return res.status(200).json({
      message: "Query successful",
      data: formattedResults || [],
    });
  });
});

// Add new food record
router.post("/foods", async (req, res) => {
  try {
    const {
      name,
      calories,
      unit,
      date,
      user_id,
      meal_type,
      amount,
      food_category,
      image_url,
    } = req.body;

    if (
      !name ||
      calories === undefined ||
      !unit ||
      !user_id ||
      !meal_type ||
      !amount
    ) {
      console.error("Invalid input data:", req.body);
      return res.status(400).json({
        message: "Failed to add food",
        error: "Missing required fields",
        details: {
          name,
          calories,
          unit,
          date,
          user_id,
          meal_type,
          amount,
          food_category,
          image_url,
        },
      });
    }

    let formattedDate;
    if (date) {
      // For Sydney timezone (UTC+10/+11)
      const inputDate = new Date(date);
      // Get Sydney date by adding timezone offset
      // Sydney is UTC+10 (standard) or UTC+11 (daylight saving)
      const sydneyDate = new Date(inputDate.getTime() + 10 * 60 * 60 * 1000);

      // Format to show date and time with minutes in the format YYYY-MM-DD HH:MM
      const year = sydneyDate.getUTCFullYear();
      const month = String(sydneyDate.getUTCMonth() + 1).padStart(2, "0");
      const day = String(sydneyDate.getUTCDate()).padStart(2, "0");
      const hours = String(sydneyDate.getUTCHours()).padStart(2, "0");
      const minutes = String(sydneyDate.getUTCMinutes()).padStart(2, "0");

      formattedDate = `${year}-${month}-${day} ${hours}:${minutes}`;

      console.log(
        `Original UTC date: ${inputDate.toISOString()}, Sydney date and time: ${formattedDate}`
      );

      // Print record_date with minutes
      console.log(`record_date: ${formattedDate}`);
    } else {
      // If no date provided, use current date and time in Sydney timezone
      const now = new Date();
      const sydneyDate = new Date(now.getTime() + 10 * 60 * 60 * 1000);

      const year = sydneyDate.getUTCFullYear();
      const month = String(sydneyDate.getUTCMonth() + 1).padStart(2, "0");
      const day = String(sydneyDate.getUTCDate()).padStart(2, "0");
      const hours = String(sydneyDate.getUTCHours()).padStart(2, "0");
      const minutes = String(sydneyDate.getUTCMinutes()).padStart(2, "0");

      formattedDate = `${year}-${month}-${day} ${hours}:${minutes}`;

      // Print record_date with minutes for current date
      console.log(`record_date: ${formattedDate}`);
    }
    const connection = await pool.promise().getConnection();

    try {
      await connection.beginTransaction();

      const [foodResult] = await connection.query(
        "INSERT INTO foods (name, calories, unit, amount, user_id, food_category) VALUES (?, ?, ?, ?, ?, ?)",
        [
          name.trim(),
          calories,
          unit.trim(),
          amount,
          user_id,
          food_category || null,
        ]
      );
      const foodId = foodResult.insertId;

      const [mealResult] = await connection.query(
        "INSERT INTO meal_records (user_id, food_id, amount, meal_type, food_category, image_url, record_date) VALUES (?, ?, ?, ?, ?, ?, ?)",
        [
          user_id,
          foodId,
          amount,
          meal_type.toLowerCase(),
          food_category || null,
          image_url || null,
          formattedDate,
        ]
      );

      await connection.commit();

      const serverBaseUrl = SERVER_BASE_URL;
      const processedImageUrl = image_url
        ? image_url.startsWith("http")
          ? image_url
          : `${serverBaseUrl}${image_url}`
        : null;

      return res.status(200).json({
        message: "Added successfully",
        data: {
          id: mealResult.insertId.toString(),
          food_id: foodId,
          name: name.trim(),
          calories,
          unit: unit.trim(),
          amount,
          meal_type: meal_type.toLowerCase(),
          record_date: formattedDate,
          food_category: food_category || null,
          image_url: processedImageUrl,
        },
      });
    } catch (error) {
      await connection.rollback();
      throw error;
    } finally {
      connection.release();
    }
  } catch (error) {
    console.error("Error:", error);
    return res.status(500).json({
      message: "Failed to add food",
      error: error.message,
      details: error.stack,
    });
  }
});

// Get user's meal records
router.get("/meal-records/:userId", async (req, res) => {
  try {
    const { userId } = req.params;
    const { date, meal_type } = req.query;

    let adjustedDate = date;
    if (date) {
      const inputDate = new Date(date);
      adjustedDate = inputDate.toISOString().split("T")[0];
      console.log(
        `Query - Original date: ${date}, Formatted date: ${adjustedDate}`
      );
    }

    let sql = `
      SELECT 
        mr.id,
        mr.food_id,
        f.name,
        f.calories,
        f.unit,
        mr.amount,
        mr.meal_type,
        DATE_FORMAT(mr.record_date, '%Y-%m-%d') as record_date,
        mr.food_category,
        mr.image_url
      FROM meal_records mr
      JOIN foods f ON mr.food_id = f.id
      WHERE mr.user_id = ?
    `;
    let params = [userId];

    if (adjustedDate) {
      sql += " AND DATE(mr.record_date) = ?";
      params.push(adjustedDate);
    }

    if (meal_type) {
      sql += " AND mr.meal_type = ?";
      params.push(meal_type);
    }

    sql += " ORDER BY mr.record_date DESC, mr.meal_type";

    const [results] = await pool.promise().query(sql, params);

    const serverBaseUrl = SERVER_BASE_URL;

    const formattedResults = results.map((record) => {
      let imageUrl = null;
      if (record.image_url) {
        imageUrl = record.image_url.startsWith("http")
          ? record.image_url
          : `${serverBaseUrl}${record.image_url}`;
      }

      return {
        id: record.id.toString(),
        food_id: record.food_id,
        name: record.name,
        calories: record.calories,
        unit: record.unit,
        amount: record.amount,
        meal_type: record.meal_type,
        record_date: record.record_date,
        food_category: record.food_category,
        image_url: imageUrl,
      };
    });

    return res.status(200).json({
      message: "Query successful",
      data: formattedResults || [],
    });
  } catch (error) {
    console.error("Database error:", error);
    return res.status(500).json({
      message: "Query failed",
      error: error.message,
    });
  }
});

// Update food record
router.put("/foods/:id", async (req, res) => {
  try {
    const { id } = req.params;
    const {
      name,
      calories,
      unit,
      amount,
      food_category,
      image_url,
      addFoodCategory,
    } = req.body;

    const finalFoodCategory = food_category || addFoodCategory || null;

    const connection = await pool.promise().getConnection();

    try {
      await connection.beginTransaction();

      const [currentFood] = await connection.query(
        "SELECT food_category FROM foods WHERE id = ?",
        [id]
      );

      const currentFoodCategory =
        currentFood.length > 0 ? currentFood[0].food_category : null;
      const foodCategoryToUse = finalFoodCategory || currentFoodCategory;

      let categories = {
        vegetables: 0,
        fruit: 0,
        grains: 0,
        meat: 0,
        dairy: 0,
        extras: 0,
      };
      if (name && name.startsWith("Camera Food")) {
        const matches = name.match(/(\w+): (\d+)/g);
        if (matches) {
          matches.forEach((match) => {
            const [category, value] = match.split(": ");
            const categoryKey = category.toLowerCase();
            if (categories.hasOwnProperty(categoryKey)) {
              categories[categoryKey] = parseInt(value) || 0;
            }
          });
        }
      }

      await connection.query(
        `UPDATE foods 
         SET name = ?, 
             calories = ?, 
             unit = ?, 
             amount = ?, 
             food_category = ? 
         WHERE id = ?`,
        [name, calories, unit, amount, foodCategoryToUse, id]
      );

      const [currentMealRecord] = await connection.query(
        "SELECT food_category, image_url FROM meal_records WHERE food_id = ?",
        [id]
      );

      const currentMealCategory =
        currentMealRecord.length > 0
          ? currentMealRecord[0].food_category
          : null;
      const currentMealImage =
        currentMealRecord.length > 0 ? currentMealRecord[0].image_url : null;

      const mealCategoryToUse = finalFoodCategory || currentMealCategory;
      const imageUrlToUse = image_url || currentMealImage;

      await connection.query(
        `UPDATE meal_records 
         SET amount = ?, 
             food_category = ?,
             image_url = CASE WHEN ? IS NULL THEN image_url ELSE ? END
         WHERE food_id = ?`,
        [amount, mealCategoryToUse, imageUrlToUse, imageUrlToUse, id]
      );

      if (name && name.startsWith("Camera Food")) {
        await connection.query(
          `UPDATE food_records 
           SET vegetables = ?, 
               fruit = ?, 
               grains = ?, 
               meat = ?, 
               dairy = ?, 
               extras = ?,
               image_url = CASE WHEN ? IS NULL THEN image_url ELSE ? END
           WHERE record_id = ?`,
          [
            categories.vegetables,
            categories.fruit,
            categories.grains,
            categories.meat,
            categories.dairy,
            categories.extras,
            imageUrlToUse,
            imageUrlToUse,
            id,
          ]
        );
      }

      await connection.commit();

      const serverBaseUrl = SERVER_BASE_URL;
      const processedImageUrl = image_url
        ? image_url.startsWith("http")
          ? image_url
          : `${serverBaseUrl}${image_url}`
        : null;

      res.json({
        success: true,
        message: "Record updated",
        data: {
          id,
          name,
          calories,
          unit,
          amount,
          food_category: foodCategoryToUse,
          image_url: processedImageUrl,
        },
      });
    } catch (error) {
      await connection.rollback();
      throw error;
    } finally {
      connection.release();
    }
  } catch (error) {
    console.error("Update error:", error);
    res.status(500).json({
      success: false,
      message: "Update failed",
      error: error.message,
    });
  }
});

// Delete food record
router.delete("/foods/:id", async (req, res) => {
  const connection = await pool.promise().getConnection();

  try {
    await connection.beginTransaction();

    const { id } = req.params;
    console.log("Attempting to delete food with ID:", id);

    // 1. First check if the record exists
    const [foodCheck] = await connection.query(
      "SELECT id FROM foods WHERE id = ?",
      [id]
    );

    if (foodCheck.length === 0) {
      console.log(`No food found with ID=${id}, aborting delete operation`);
      await connection.commit();
      return res.json({
        success: false,
        message: "Food not found",
        affectedRows: {
          meals: 0,
          foods: 0,
        },
      });
    }

    const [mealResult] = await connection.query(
      "DELETE FROM meal_records WHERE food_id = ?",
      [id]
    );
    console.log(
      `Deleted ${mealResult.affectedRows} rows from meal_records table`
    );

    let foodRecordsResult = { affectedRows: 0 };
    const [foodRecordsCheck] = await connection.query(
      "SELECT record_id FROM food_records WHERE record_id = ?",
      [id]
    );

    if (foodRecordsCheck.length > 0) {
      [foodRecordsResult] = await connection.query(
        "DELETE FROM food_records WHERE record_id = ?",
        [id]
      );
      console.log(
        `Deleted ${foodRecordsResult.affectedRows} rows from food_records table`
      );
    }

    const [foodResult] = await connection.query(
      "DELETE FROM foods WHERE id = ?",
      [id]
    );
    console.log(`Deleted ${foodResult.affectedRows} rows from foods table`);

    await connection.commit();
    console.log("Delete transaction committed successfully");

    res.json({
      success: true,
      message: "Food deleted successfully",
      affectedRows: {
        meals: mealResult.affectedRows,
        foodRecords: foodRecordsResult.affectedRows,
        foods: foodResult.affectedRows,
      },
    });
  } catch (error) {
    await connection.rollback();
    console.error("Delete error:", error);
    res.status(500).json({
      success: false,
      message: "Delete failed",
      error: error.message,
    });
  } finally {
    connection.release();
  }
});

module.exports = router;
