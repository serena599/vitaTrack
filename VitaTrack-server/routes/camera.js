const express = require("express");
const multiparty = require("multiparty");
const path = require("path");
const fs = require("fs");
const { pool } = require("../databaseConfig");

const router = express.Router();

router.post("/uploadFoodImage", (req, res) => {
  const form = new multiparty.Form();
  form.parse(req, (err, fields, files) => {
    if (err) {
      return res.status(500).json({ error: "File upload failed" });
    }

    if (!files.foodImage || !files.foodImage[0]) {
      return res.status(400).json({ error: "No food image provided" });
    }

    const userId = fields.userId
      ? fields.userId[0]
      : fields.user_id
      ? fields.user_id[0]
      : "unknown";

    const file = files.foodImage[0];
    const fileName = `food_${userId}_${Date.now()}_${path.basename(file.path)}`;
    const uploadDir = path.join(__dirname, "../uploads/food_images");
    const filePath = path.join(uploadDir, fileName);

    fs.renameSync(file.path, filePath);

    const imageUrl = `/uploads/food_images/${fileName}`;
    res.json({ success: true, imageUrl });
  });
});

router.post("/food-records", (req, res) => {
  const {
    userId,
    user_id,
    recordDate,
    imageUrl,
    mealType,
    categories,
    vegetables,
    fruit,
    grains,
    meat,
    dairy,
    extras,
  } = req.body;

  const finalUserId = user_id || userId;

  if (!finalUserId || !recordDate || !mealType) {
    return res.status(400).json({
      error: "Missing required fields: userId/user_id, recordDate, or mealType",
    });
  }

  let formattedDate;
  try {
    const inputDate = new Date(recordDate);

    const sydneyDate = new Date(inputDate.getTime() + 10 * 60 * 60 * 1000);
    const sydneyDateStr = sydneyDate.toISOString().split("T")[0];

    formattedDate = sydneyDateStr + " " + inputDate.toISOString().slice(11, 19);

    console.log(
      `Original UTC date: ${inputDate.toISOString()}, Sydney date: ${sydneyDateStr}`
    );
  } catch (error) {
    console.error("Date parsing error:", error);
    formattedDate = new Date().toISOString().slice(0, 19).replace("T", " ");
  }

  let categoriesData;

  if (categories) {
    categoriesData = categories;
  } else {
    categoriesData = {
      vegetables: vegetables !== undefined ? vegetables : 0,
      fruit: fruit !== undefined ? fruit : 0,
      grains: grains !== undefined ? grains : 0,
      meat: meat !== undefined ? meat : 0,
      dairy: dairy !== undefined ? dairy : 0,
      extras: extras !== undefined ? extras : 0,
    };
  }

  const requiredCategories = [
    "vegetables",
    "fruit",
    "grains",
    "meat",
    "dairy",
    "extras",
  ];
  for (const category of requiredCategories) {
    const value = categoriesData[category];
    if (value === undefined || (typeof value !== "number" && value !== 0)) {
      return res.status(400).json({
        error: `Invalid or missing quantity for ${category}`,
        received: value,
        type: typeof value,
      });
    }
  }

  const query = `
    INSERT INTO food_records (user_id, record_date, image_url, meal_type, vegetables, fruit, grains, meat, dairy, extras)
    VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
  `;

  const values = [
    finalUserId,
    formattedDate,
    imageUrl || null,
    mealType,
    categoriesData.vegetables || 0,
    categoriesData.fruit || 0,
    categoriesData.grains || 0,
    categoriesData.meat || 0,
    categoriesData.dairy || 0,
    categoriesData.extras || 0,
  ];

  pool.query(query, values, (err, result) => {
    if (err) {
      console.error("Error saving food record:", err);
      return res
        .status(500)
        .json({ error: "Failed to save food record", details: err.message });
    }

    res.json({
      success: true,
      recordId: result.insertId,
      message: "Food record created successfully",
    });
  });
});

router.get("/food-records/user/:userId", (req, res) => {
  const userId = req.params.userId;

  const query = `
    SELECT fr.record_id, fr.record_date, fr.image_url, fr.meal_type, fr.vegetables, fr.fruit, fr.grains, fr.meat, fr.dairy, fr.extras, fr.created_at
    FROM food_records fr
    WHERE fr.user_id = ?
    ORDER BY fr.record_date DESC
  `;

  pool.query(query, [userId], (err, records) => {
    if (err) {
      return res.status(500).json({ error: "Database query failed" });
    }

    res.json({ success: true, records });
  });
});

router.get("/food-records/:id", (req, res) => {
  const recordId = req.params.id;

  const query = `
    SELECT fr.record_id, fr.record_date, fr.image_url, fr.meal_type, fr.vegetables, fr.fruit, fr.grains, fr.meat, fr.dairy, fr.extras, fr.created_at
    FROM food_records fr
    WHERE fr.record_id = ?
  `;

  pool.query(query, [recordId], (err, records) => {
    if (err) {
      return res.status(500).json({ error: "Database query failed" });
    }

    if (records.length === 0) {
      return res
        .status(404)
        .json({ success: false, message: "Food record not found" });
    }

    res.json({ success: true, record: records[0] });
  });
});

router.put("/food-records/:id", async (req, res) => {
  const recordId = req.params.id;
  const {
    recordDate,
    imageUrl,
    image_url,
    mealType,
    vegetables,
    fruit,
    grains,
    meat,
    dairy,
    extras,
    amount,
  } = req.body;

  const finalImageUrl = imageUrl || image_url || null;

  let formattedDate;
  try {
    if (recordDate) {
      // For Sydney timezone (UTC+10/+11)
      const inputDate = new Date(recordDate);

      // Get Sydney date by adding timezone offset
      // Sydney is UTC+10 (standard) or UTC+11 (daylight saving)
      const sydneyDate = new Date(inputDate.getTime() + 10 * 60 * 60 * 1000);
      const sydneyDateStr = sydneyDate.toISOString().split("T")[0];

      // Use Sydney date for record keeping
      formattedDate =
        sydneyDateStr + " " + inputDate.toISOString().slice(11, 19);

      console.log(
        `Update - Original UTC date: ${inputDate.toISOString()}, Sydney date: ${sydneyDateStr}`
      );
    } else {
      formattedDate = new Date().toISOString().slice(0, 19).replace("T", " ");
    }
  } catch (error) {
    console.error("Date parsing error:", error);
    formattedDate = new Date().toISOString().slice(0, 19).replace("T", " ");
  }

  const connection = await pool.promise().getConnection();

  try {
    await connection.beginTransaction();

    let newRecordCreated = false;

    const [mealCheck] = await connection.query(
      "SELECT id, user_id, meal_type, record_date, image_url FROM meal_records WHERE food_id = ?",
      [recordId]
    );

    if (mealCheck.length === 0) {
      throw new Error(`No meal_records found with food_id=${recordId}`);
    }

    const mealRecord = mealCheck[0];
    const userId = mealRecord.user_id;

    const [foodRecordsCheck] = await connection.query(
      "SELECT record_id, image_url FROM food_records WHERE record_id = ?",
      [recordId]
    );

    let originalImageUrl = null;
    if (foodRecordsCheck.length > 0) {
      originalImageUrl = foodRecordsCheck[0].image_url;
    } else {
      const [relatedRecords] = await connection.query(
        `SELECT fr.record_id, fr.image_url 
         FROM food_records fr
         JOIN meal_records mr ON fr.user_id = mr.user_id 
            AND DATE(fr.record_date) = DATE(mr.record_date)
            AND fr.meal_type = mr.meal_type
         WHERE mr.food_id = ?
         LIMIT 1`,
        [recordId]
      );

      if (relatedRecords.length > 0) {
        const relatedRecordId = relatedRecords[0].record_id;
        originalImageUrl = relatedRecords[0].image_url;

        await connection.query(
          "UPDATE food_records SET record_id = ? WHERE record_id = ?",
          [recordId, relatedRecordId]
        );
      } else {
        newRecordCreated = true;

        const mealImageUrl = mealRecord.image_url;
        originalImageUrl = mealImageUrl;

        await connection.query(
          `INSERT INTO food_records 
           (record_id, user_id, record_date, image_url, meal_type, vegetables, fruit, grains, meat, dairy, extras)
           VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
          [
            recordId,
            userId,
            formattedDate,
            finalImageUrl || mealImageUrl || null,
            mealType || mealRecord.meal_type,
            vegetables || 0,
            fruit || 0,
            grains || 0,
            meat || 0,
            dairy || 0,
            extras || 0,
          ]
        );
      }
    }

    const imageUrlToUse = finalImageUrl || originalImageUrl;

    if (!newRecordCreated) {
      await connection.query(
        `UPDATE food_records 
         SET record_date = ?, 
             meal_type = ?, 
             vegetables = ?, 
             fruit = ?, 
             grains = ?, 
             meat = ?, 
             dairy = ?, 
             extras = ?,
             image_url = CASE WHEN ? IS NULL THEN image_url ELSE ? END
         WHERE record_id = ?`,
        [
          formattedDate,
          mealType,
          vegetables || 0,
          fruit || 0,
          grains || 0,
          meat || 0,
          dairy || 0,
          extras || 0,
          imageUrlToUse,
          imageUrlToUse,
          recordId,
        ]
      );
    }

    await connection.query(
      `UPDATE meal_records 
       SET record_date = ?, 
           meal_type = ?, 
           amount = ?,
           image_url = CASE WHEN ? IS NULL THEN image_url ELSE ? END
       WHERE food_id = ?`,
      [
        formattedDate,
        mealType,
        amount || 1.0,
        imageUrlToUse,
        imageUrlToUse,
        recordId,
      ]
    );

    const foodName = `Camera Food (Vegetables: ${vegetables || 0}, Fruit: ${
      fruit || 0
    }, Grains: ${grains || 0}, Meat: ${meat || 0}, Dairy: ${
      dairy || 0
    }, Extras: ${extras || 0})`;

    const totalCalories =
      (vegetables || 0) * 50 +
      (fruit || 0) * 60 +
      (grains || 0) * 100 +
      (meat || 0) * 150 +
      (dairy || 0) * 120 +
      (extras || 0) * 200;

    await connection.query(
      `UPDATE foods 
       SET name = ?, 
           calories = ?, 
           unit = ?, 
           amount = ?
       WHERE id = ?`,
      [foodName, totalCalories, "photo", amount || 1.0, recordId]
    );

    await connection.commit();

    res.json({
      success: true,
      message: "Record updated successfully",
      data: {
        newRecordCreated,
        imageUrl: imageUrlToUse,
      },
    });
  } catch (error) {
    await connection.rollback();
    console.error("Update error:", error);
    res.status(500).json({
      success: false,
      message: "Update failed",
      error: error.message,
    });
  } finally {
    connection.release();
  }
});

router.delete("/food-records/:id", async (req, res) => {
  const connection = await pool.promise().getConnection();

  try {
    await connection.beginTransaction();

    const { id } = req.params;
    console.log("Attempting to delete food record with ID:", id);

    // First step: Check if the record exists (check both tables)
    const [foodCheck] = await connection.query(
      "SELECT id FROM foods WHERE id = ?",
      [id]
    );

    const [recordCheck] = await connection.query(
      "SELECT record_id FROM food_records WHERE record_id = ?",
      [id]
    );

    // If two tables have no records, no need to delete
    if (foodCheck.length === 0 && recordCheck.length === 0) {
      console.log(`No records found with ID=${id}, aborting delete operation`);
      await connection.commit();
      return res.json({
        success: false,
        message: "Record not found",
        affectedRows: {
          foodRecords: 0,
          mealRecords: 0,
          foods: 0,
        },
      });
    }

    // Delete order is important: first meal_records, then food_records, then foods

    // Step 1: Delete records from the meal_records table
    const [mealRecordResult] = await connection.query(
      "DELETE FROM meal_records WHERE food_id = ?",
      [id]
    );
    console.log(
      `Deleted ${mealRecordResult.affectedRows} rows from meal_records table`
    );

    // 2. Delete records from the food_records table
    // First try direct match
    let foodRecordResult = { affectedRows: 0 };
    if (recordCheck.length > 0) {
      [foodRecordResult] = await connection.query(
        "DELETE FROM food_records WHERE record_id = ?",
        [id]
      );
      console.log(
        `Deleted ${foodRecordResult.affectedRows} rows from food_records table using direct record_id match`
      );
    }

    // If direct deletion does not affect any rows, try to find records through other associations
    if (foodRecordResult.affectedRows === 0) {
      // Find possibly related food_records (by date and user ID)
      const [relatedRecordsCheck] = await connection.query(
        `SELECT fr.record_id 
         FROM food_records fr
         JOIN foods f ON f.id = ?
         WHERE fr.user_id = f.user_id`,
        [id]
      );

      if (relatedRecordsCheck.length > 0) {
        // If related records are found, delete them
        const relatedIds = relatedRecordsCheck.map(
          (record) => record.record_id
        );
        console.log(
          `Found related food_records with IDs: ${relatedIds.join(", ")}`
        );

        for (const relatedId of relatedIds) {
          const [relatedResult] = await connection.query(
            "DELETE FROM food_records WHERE record_id = ?",
            [relatedId]
          );
          foodRecordResult.affectedRows += relatedResult.affectedRows;
        }
        console.log(
          `Deleted ${foodRecordResult.affectedRows} rows from food_records table through related records`
        );
      }
    }

    // 3. Finally, delete records from the foods table
    const [foodResult] = await connection.query(
      "DELETE FROM foods WHERE id = ?",
      [id]
    );
    console.log(`Deleted ${foodResult.affectedRows} rows from foods table`);

    await connection.commit();
    console.log("Delete transaction committed successfully");

    res.json({
      success: true,
      message: "Food record deleted successfully",
      affectedRows: {
        foodRecords: foodRecordResult.affectedRows,
        mealRecords: mealRecordResult.affectedRows,
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
