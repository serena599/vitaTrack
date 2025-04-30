-- ✨ 建表SQL
-- 先删除所有有外键引用的表
DROP TABLE IF EXISTS food_records;
DROP TABLE IF EXISTS meal_records;
DROP TABLE IF EXISTS foods;
DROP TABLE IF EXISTS goal_settings;
DROP TABLE IF EXISTS daily_intake;

-- 最后删除被引用的表
DROP TABLE IF EXISTS user;

-- 然后重新创建表
CREATE TABLE IF NOT EXISTS user (
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
);

CREATE TABLE IF NOT EXISTS foods (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    calories INT NOT NULL,
    unit VARCHAR(50) NOT NULL,
    amount DOUBLE NOT NULL,
    user_id INT NOT NULL,
    food_category VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES user(user_id)
);

CREATE TABLE IF NOT EXISTS meal_records (
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
);

CREATE TABLE IF NOT EXISTS food_records (
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
);

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
    UNIQUE KEY user_id (user_id),
    FOREIGN KEY (user_id) REFERENCES user(user_id)
);


-- (下面一款一款完整SQL将在下一条信息中继续给你！)
-- 插入6个模拟用户
INSERT INTO user (firstName, lastName, gender, dob, phone, email, joinedYear, password, avatar_path, username)
VALUES
('John', 'Doe', 'male', '1990-05-15', '0400123456', 'john.doe@example.com', '2023', '123456', NULL, 'user1'),
('Emily', 'Johnson', 'female', '1995-06-20', '0400123457', 'emily.johnson@example.com', '2023', '123456', NULL, 'user2'),
('Michael', 'Smith', 'male', '1988-12-02', '0400123458', 'michael.smith@example.com', '2022', '123456', NULL, 'user3'),
('Sarah', 'Williams', 'female', '2000-09-22', '0400123459', 'sarah.williams@example.com', '2024', '123456', NULL, 'user4'),
('David', 'Brown', 'male', '1992-03-10', '0400123460', 'david.brown@example.com', '2021', '123456', NULL, 'user5'),
('Anna', 'Taylor', 'female', '1985-11-05', '0400123461', 'anna.taylor@example.com', '2024', '123456', NULL, 'user6');

-- 先删除 goal_settings 表中的所有数据
DELETE FROM goal_settings;

-- 然后重新插入数据，让系统自动生成 ID
INSERT INTO goal_settings (user_id, vegetables, fruits, grains, meat, dairy, extras)
VALUES
(1, 3.00, 2.00, 3.00, 2.00, 2.00, 1.00),
(2, 2.00, 1.00, 2.00, 3.00, 1.00, 0.00),
(3, 4.00, 2.00, 2.00, 1.00, 2.00, 1.00),
(4, 2.00, 2.00, 3.00, 2.00, 2.00, 1.00),
(5, 3.00, 3.00, 2.00, 1.00, 1.00, 2.00),
(6, 2.00, 2.00, 2.00, 2.00, 2.00, 1.00);

-- 先删除 foods 表中的所有数据
DELETE FROM foods;

-- 重新插入更多食物数据，包含更丰富的食物种类
INSERT INTO foods (name, calories, unit, amount, user_id, food_category, created_at) VALUES
-- 水果类
('Banana', 105, 'serving', 1, 1, 'fruit', '2025-04-26 23:03:36'),
('Apple', 95, 'serving', 1, 1, 'fruit', '2025-04-26 23:03:36'),
('Orange', 62, 'serving', 1, 1, 'fruit', '2025-04-26 23:03:36'),
('Blueberries', 85, 'serving', 1, 1, 'fruit', '2025-04-26 23:03:36'),
('Strawberries', 50, 'serving', 1, 1, 'fruit', '2025-04-26 23:03:36'),
('Grapes', 69, 'serving', 1, 1, 'fruit', '2025-04-26 23:03:36'),
('Watermelon', 46, 'serving', 1, 1, 'fruit', '2025-04-26 23:03:36'),
('Pineapple', 82, 'serving', 1, 1, 'fruit', '2025-04-26 23:03:36'),

-- 蔬菜类
('Broccoli', 55, 'serving', 1, 2, 'vegetables', '2025-04-26 23:03:36'),
('Carrots', 41, 'serving', 1, 2, 'vegetables', '2025-04-26 23:03:36'),
('Spinach', 23, 'serving', 1, 2, 'vegetables', '2025-04-26 23:03:36'),
('Cucumber', 16, 'serving', 1, 2, 'vegetables', '2025-04-26 23:03:36'),
('Tomatoes', 22, 'serving', 1, 2, 'vegetables', '2025-04-26 23:03:36'),
('Bell Peppers', 30, 'serving', 1, 2, 'vegetables', '2025-04-26 23:03:36'),
('Lettuce', 5, 'serving', 1, 2, 'vegetables', '2025-04-26 23:03:36'),
('Zucchini', 17, 'serving', 1, 2, 'vegetables', '2025-04-26 23:03:36'),

-- 谷物类
('Brown Rice', 216, 'serving', 1, 3, 'grains', '2025-04-26 23:03:36'),
('Oatmeal', 150, 'serving', 1, 3, 'grains', '2025-04-26 23:03:36'),
('Quinoa', 120, 'serving', 1, 3, 'grains', '2025-04-26 23:03:36'),
('Whole Wheat Bread', 79, 'serving', 1, 3, 'grains', '2025-04-26 23:03:36'),
('Pasta', 131, 'serving', 1, 3, 'grains', '2025-04-26 23:03:36'),
('Sweet Potato', 103, 'serving', 1, 3, 'grains', '2025-04-26 23:03:36'),
('Corn', 96, 'serving', 1, 3, 'grains', '2025-04-26 23:03:36'),
('Barley', 193, 'serving', 1, 3, 'grains', '2025-04-26 23:03:36'),

-- 肉类
('Chicken Breast', 165, 'serving', 1, 4, 'meat', '2025-04-26 23:03:36'),
('Salmon', 208, 'serving', 1, 4, 'meat', '2025-04-26 23:03:36'),
('Beef Steak', 271, 'serving', 1, 4, 'meat', '2025-04-26 23:03:36'),
('Pork', 242, 'serving', 1, 4, 'meat', '2025-04-26 23:03:36'),
('Tofu', 94, 'serving', 1, 4, 'meat', '2025-04-26 23:03:36'),
('Eggs', 155, 'serving', 1, 4, 'meat', '2025-04-26 23:03:36'),
('Turkey', 135, 'serving', 1, 4, 'meat', '2025-04-26 23:03:36'),
('Tuna', 120, 'serving', 1, 4, 'meat', '2025-04-26 23:03:36'),

-- 乳制品
('Milk', 122, 'serving', 1, 5, 'dairy', '2025-04-26 23:03:36'),
('Greek Yogurt', 100, 'serving', 1, 5, 'dairy', '2025-04-26 23:03:36'),
('Cheddar Cheese', 113, 'serving', 1, 5, 'dairy', '2025-04-26 23:03:36'),
('Cottage Cheese', 98, 'serving', 1, 5, 'dairy', '2025-04-26 23:03:36'),
('Mozzarella', 85, 'serving', 1, 5, 'dairy', '2025-04-26 23:03:36'),
('Yogurt', 59, 'serving', 1, 5, 'dairy', '2025-04-26 23:03:36'),
('Sour Cream', 23, 'serving', 1, 5, 'dairy', '2025-04-26 23:03:36'),
('Butter', 102, 'serving', 1, 5, 'dairy', '2025-04-26 23:03:36'),

-- 零食/额外
('Almonds', 164, 'serving', 1, 6, 'extras', '2025-04-26 23:03:36'),
('Peanut Butter', 190, 'serving', 1, 6, 'extras', '2025-04-26 23:03:36'),
('Walnuts', 185, 'serving', 1, 6, 'extras', '2025-04-26 23:03:36'),
('Cashews', 157, 'serving', 1, 6, 'extras', '2025-04-26 23:03:36'),
('Dark Chocolate', 170, 'serving', 1, 6, 'extras', '2025-04-26 23:03:36'),
('Popcorn', 31, 'serving', 1, 6, 'extras', '2025-04-26 23:03:36'),
('Trail Mix', 150, 'serving', 1, 6, 'extras', '2025-04-26 23:03:36'),
('Granola', 120, 'serving', 1, 6, 'extras', '2025-04-26 23:03:36');


-- 先删除 meal_records 表中的所有数据
DELETE FROM meal_records;

-- 插入更合理的饮食记录，覆盖一周的数据
INSERT INTO meal_records (user_id, food_id, amount, meal_type, food_category, image_url, record_date, created_at) VALUES
-- 用户1的饮食记录
-- 周一
(1, 1, 1, 'breakfast', 'fruit', NULL, '2025-04-21', '2025-04-21 08:00:00'),
(1, 9, 1, 'breakfast', 'grains', NULL, '2025-04-21', '2025-04-21 08:00:00'),
(1, 25, 1, 'lunch', 'meat', NULL, '2025-04-21', '2025-04-21 12:00:00'),
(1, 10, 1, 'lunch', 'vegetables', NULL, '2025-04-21', '2025-04-21 12:00:00'),
(1, 17, 1, 'dinner', 'meat', NULL, '2025-04-21', '2025-04-21 18:00:00'),
(1, 11, 1, 'dinner', 'vegetables', NULL, '2025-04-21', '2025-04-21 18:00:00'),
(1, 33, 1, 'snack', 'dairy', NULL, '2025-04-21', '2025-04-21 15:00:00'),

-- 周二
(1, 2, 1, 'breakfast', 'fruit', NULL, '2025-04-22', '2025-04-22 08:00:00'),
(1, 10, 1, 'breakfast', 'grains', NULL, '2025-04-22', '2025-04-22 08:00:00'),
(1, 26, 1, 'lunch', 'meat', NULL, '2025-04-22', '2025-04-22 12:00:00'),
(1, 11, 1, 'lunch', 'vegetables', NULL, '2025-04-22', '2025-04-22 12:00:00'),
(1, 18, 1, 'dinner', 'meat', NULL, '2025-04-22', '2025-04-22 18:00:00'),
(1, 12, 1, 'dinner', 'vegetables', NULL, '2025-04-22', '2025-04-22 18:00:00'),
(1, 34, 1, 'snack', 'dairy', NULL, '2025-04-22', '2025-04-22 15:00:00'),

-- 周三
(1, 3, 1, 'breakfast', 'fruit', NULL, '2025-04-23', '2025-04-23 08:00:00'),
(1, 11, 1, 'breakfast', 'grains', NULL, '2025-04-23', '2025-04-23 08:00:00'),
(1, 27, 1, 'lunch', 'meat', NULL, '2025-04-23', '2025-04-23 12:00:00'),
(1, 12, 1, 'lunch', 'vegetables', NULL, '2025-04-23', '2025-04-23 12:00:00'),
(1, 19, 1, 'dinner', 'meat', NULL, '2025-04-23', '2025-04-23 18:00:00'),
(1, 13, 1, 'dinner', 'vegetables', NULL, '2025-04-23', '2025-04-23 18:00:00'),
(1, 35, 1, 'snack', 'dairy', NULL, '2025-04-23', '2025-04-23 15:00:00'),

-- 周四
(1, 4, 1, 'breakfast', 'fruit', NULL, '2025-04-24', '2025-04-24 08:00:00'),
(1, 12, 1, 'breakfast', 'grains', NULL, '2025-04-24', '2025-04-24 08:00:00'),
(1, 28, 1, 'lunch', 'meat', NULL, '2025-04-24', '2025-04-24 12:00:00'),
(1, 13, 1, 'lunch', 'vegetables', NULL, '2025-04-24', '2025-04-24 12:00:00'),
(1, 20, 1, 'dinner', 'meat', NULL, '2025-04-24', '2025-04-24 18:00:00'),
(1, 14, 1, 'dinner', 'vegetables', NULL, '2025-04-24', '2025-04-24 18:00:00'),
(1, 36, 1, 'snack', 'dairy', NULL, '2025-04-24', '2025-04-24 15:00:00'),

-- 周五
(1, 5, 1, 'breakfast', 'fruit', NULL, '2025-04-25', '2025-04-25 08:00:00'),
(1, 13, 1, 'breakfast', 'grains', NULL, '2025-04-25', '2025-04-25 08:00:00'),
(1, 29, 1, 'lunch', 'meat', NULL, '2025-04-25', '2025-04-25 12:00:00'),
(1, 14, 1, 'lunch', 'vegetables', NULL, '2025-04-25', '2025-04-25 12:00:00'),
(1, 21, 1, 'dinner', 'meat', NULL, '2025-04-25', '2025-04-25 18:00:00'),
(1, 15, 1, 'dinner', 'vegetables', NULL, '2025-04-25', '2025-04-25 18:00:00'),
(1, 37, 1, 'snack', 'dairy', NULL, '2025-04-25', '2025-04-25 15:00:00'),

-- 周六
(1, 6, 1, 'breakfast', 'fruit', NULL, '2025-04-26', '2025-04-26 08:00:00'),
(1, 14, 1, 'breakfast', 'grains', NULL, '2025-04-26', '2025-04-26 08:00:00'),
(1, 30, 1, 'lunch', 'meat', NULL, '2025-04-26', '2025-04-26 12:00:00'),
(1, 15, 1, 'lunch', 'vegetables', NULL, '2025-04-26', '2025-04-26 12:00:00'),
(1, 22, 1, 'dinner', 'meat', NULL, '2025-04-26', '2025-04-26 18:00:00'),
(1, 16, 1, 'dinner', 'vegetables', NULL, '2025-04-26', '2025-04-26 18:00:00'),
(1, 38, 1, 'snack', 'dairy', NULL, '2025-04-26', '2025-04-26 15:00:00'),

-- 周日
(1, 7, 1, 'breakfast', 'fruit', NULL, '2025-04-27', '2025-04-27 08:00:00'),
(1, 15, 1, 'breakfast', 'grains', NULL, '2025-04-27', '2025-04-27 08:00:00'),
(1, 31, 1, 'lunch', 'meat', NULL, '2025-04-27', '2025-04-27 12:00:00'),
(1, 16, 1, 'lunch', 'vegetables', NULL, '2025-04-27', '2025-04-27 12:00:00'),
(1, 23, 1, 'dinner', 'meat', NULL, '2025-04-27', '2025-04-27 18:00:00'),
(1, 9, 1, 'dinner', 'vegetables', NULL, '2025-04-27', '2025-04-27 18:00:00'),
(1, 32, 1, 'snack', 'dairy', NULL, '2025-04-27', '2025-04-27 15:00:00'),

-- 用户2的饮食记录
-- 周一
(2, 2, 1, 'breakfast', 'fruit', NULL, '2025-04-21', '2025-04-21 08:00:00'),
(2, 10, 1, 'breakfast', 'grains', NULL, '2025-04-21', '2025-04-21 08:00:00'),
(2, 26, 1, 'lunch', 'meat', NULL, '2025-04-21', '2025-04-21 12:00:00'),
(2, 11, 1, 'lunch', 'vegetables', NULL, '2025-04-21', '2025-04-21 12:00:00'),
(2, 18, 1, 'dinner', 'meat', NULL, '2025-04-21', '2025-04-21 18:00:00'),
(2, 12, 1, 'dinner', 'vegetables', NULL, '2025-04-21', '2025-04-21 18:00:00'),
(2, 34, 1, 'snack', 'dairy', NULL, '2025-04-21', '2025-04-21 15:00:00'),

-- 周二
(2, 3, 1, 'breakfast', 'fruit', NULL, '2025-04-22', '2025-04-22 08:00:00'),
(2, 11, 1, 'breakfast', 'grains', NULL, '2025-04-22', '2025-04-22 08:00:00'),
(2, 27, 1, 'lunch', 'meat', NULL, '2025-04-22', '2025-04-22 12:00:00'),
(2, 12, 1, 'lunch', 'vegetables', NULL, '2025-04-22', '2025-04-22 12:00:00'),
(2, 19, 1, 'dinner', 'meat', NULL, '2025-04-22', '2025-04-22 18:00:00'),
(2, 13, 1, 'dinner', 'vegetables', NULL, '2025-04-22', '2025-04-22 18:00:00'),
(2, 35, 1, 'snack', 'dairy', NULL, '2025-04-22', '2025-04-22 15:00:00'),

-- 周三
(2, 4, 1, 'breakfast', 'fruit', NULL, '2025-04-23', '2025-04-23 08:00:00'),
(2, 12, 1, 'breakfast', 'grains', NULL, '2025-04-23', '2025-04-23 08:00:00'),
(2, 28, 1, 'lunch', 'meat', NULL, '2025-04-23', '2025-04-23 12:00:00'),
(2, 13, 1, 'lunch', 'vegetables', NULL, '2025-04-23', '2025-04-23 12:00:00'),
(2, 20, 1, 'dinner', 'meat', NULL, '2025-04-23', '2025-04-23 18:00:00'),
(2, 14, 1, 'dinner', 'vegetables', NULL, '2025-04-23', '2025-04-23 18:00:00'),
(2, 36, 1, 'snack', 'dairy', NULL, '2025-04-23', '2025-04-23 15:00:00'),

-- 周四
(2, 5, 1, 'breakfast', 'fruit', NULL, '2025-04-24', '2025-04-24 08:00:00'),
(2, 13, 1, 'breakfast', 'grains', NULL, '2025-04-24', '2025-04-24 08:00:00'),
(2, 29, 1, 'lunch', 'meat', NULL, '2025-04-24', '2025-04-24 12:00:00'),
(2, 14, 1, 'lunch', 'vegetables', NULL, '2025-04-24', '2025-04-24 12:00:00'),
(2, 21, 1, 'dinner', 'meat', NULL, '2025-04-24', '2025-04-24 18:00:00'),
(2, 15, 1, 'dinner', 'vegetables', NULL, '2025-04-24', '2025-04-24 18:00:00'),
(2, 37, 1, 'snack', 'dairy', NULL, '2025-04-24', '2025-04-24 15:00:00'),

-- 周五
(2, 6, 1, 'breakfast', 'fruit', NULL, '2025-04-25', '2025-04-25 08:00:00'),
(2, 14, 1, 'breakfast', 'grains', NULL, '2025-04-25', '2025-04-25 08:00:00'),
(2, 30, 1, 'lunch', 'meat', NULL, '2025-04-25', '2025-04-25 12:00:00'),
(2, 15, 1, 'lunch', 'vegetables', NULL, '2025-04-25', '2025-04-25 12:00:00'),
(2, 22, 1, 'dinner', 'meat', NULL, '2025-04-25', '2025-04-25 18:00:00'),
(2, 16, 1, 'dinner', 'vegetables', NULL, '2025-04-25', '2025-04-25 18:00:00'),
(2, 38, 1, 'snack', 'dairy', NULL, '2025-04-25', '2025-04-25 15:00:00'),

-- 周六
(2, 7, 1, 'breakfast', 'fruit', NULL, '2025-04-26', '2025-04-26 08:00:00'),
(2, 15, 1, 'breakfast', 'grains', NULL, '2025-04-26', '2025-04-26 08:00:00'),
(2, 31, 1, 'lunch', 'meat', NULL, '2025-04-26', '2025-04-26 12:00:00'),
(2, 16, 1, 'lunch', 'vegetables', NULL, '2025-04-26', '2025-04-26 12:00:00'),
(2, 23, 1, 'dinner', 'meat', NULL, '2025-04-26', '2025-04-26 18:00:00'),
(2, 9, 1, 'dinner', 'vegetables', NULL, '2025-04-26', '2025-04-26 18:00:00'),
(2, 32, 1, 'snack', 'dairy', NULL, '2025-04-26', '2025-04-26 15:00:00'),

-- 周日
(2, 8, 1, 'breakfast', 'fruit', NULL, '2025-04-27', '2025-04-27 08:00:00'),
(2, 16, 1, 'breakfast', 'grains', NULL, '2025-04-27', '2025-04-27 08:00:00'),
(2, 32, 1, 'lunch', 'meat', NULL, '2025-04-27', '2025-04-27 12:00:00'),
(2, 9, 1, 'lunch', 'vegetables', NULL, '2025-04-27', '2025-04-27 12:00:00'),
(2, 24, 1, 'dinner', 'meat', NULL, '2025-04-27', '2025-04-27 18:00:00'),
(2, 10, 1, 'dinner', 'vegetables', NULL, '2025-04-27', '2025-04-27 18:00:00'),
(2, 33, 1, 'snack', 'dairy', NULL, '2025-04-27', '2025-04-27 15:00:00'),

-- 用户3的饮食记录
-- 周一
(3, 3, 1, 'breakfast', 'fruit', NULL, '2025-04-21', '2025-04-21 08:00:00'),
(3, 11, 1, 'breakfast', 'grains', NULL, '2025-04-21', '2025-04-21 08:00:00'),
(3, 27, 1, 'lunch', 'meat', NULL, '2025-04-21', '2025-04-21 12:00:00'),
(3, 12, 1, 'lunch', 'vegetables', NULL, '2025-04-21', '2025-04-21 12:00:00'),
(3, 19, 1, 'dinner', 'meat', NULL, '2025-04-21', '2025-04-21 18:00:00'),
(3, 13, 1, 'dinner', 'vegetables', NULL, '2025-04-21', '2025-04-21 18:00:00'),
(3, 35, 1, 'snack', 'dairy', NULL, '2025-04-21', '2025-04-21 15:00:00'),

-- 周二
(3, 4, 1, 'breakfast', 'fruit', NULL, '2025-04-22', '2025-04-22 08:00:00'),
(3, 12, 1, 'breakfast', 'grains', NULL, '2025-04-22', '2025-04-22 08:00:00'),
(3, 28, 1, 'lunch', 'meat', NULL, '2025-04-22', '2025-04-22 12:00:00'),
(3, 13, 1, 'lunch', 'vegetables', NULL, '2025-04-22', '2025-04-22 12:00:00'),
(3, 20, 1, 'dinner', 'meat', NULL, '2025-04-22', '2025-04-22 18:00:00'),
(3, 14, 1, 'dinner', 'vegetables', NULL, '2025-04-22', '2025-04-22 18:00:00'),
(3, 36, 1, 'snack', 'dairy', NULL, '2025-04-22', '2025-04-22 15:00:00'),

-- 周三
(3, 5, 1, 'breakfast', 'fruit', NULL, '2025-04-23', '2025-04-23 08:00:00'),
(3, 13, 1, 'breakfast', 'grains', NULL, '2025-04-23', '2025-04-23 08:00:00'),
(3, 29, 1, 'lunch', 'meat', NULL, '2025-04-23', '2025-04-23 12:00:00'),
(3, 14, 1, 'lunch', 'vegetables', NULL, '2025-04-23', '2025-04-23 12:00:00'),
(3, 21, 1, 'dinner', 'meat', NULL, '2025-04-23', '2025-04-23 18:00:00'),
(3, 15, 1, 'dinner', 'vegetables', NULL, '2025-04-23', '2025-04-23 18:00:00'),
(3, 37, 1, 'snack', 'dairy', NULL, '2025-04-23', '2025-04-23 15:00:00'),

-- 周四
(3, 6, 1, 'breakfast', 'fruit', NULL, '2025-04-24', '2025-04-24 08:00:00'),
(3, 14, 1, 'breakfast', 'grains', NULL, '2025-04-24', '2025-04-24 08:00:00'),
(3, 30, 1, 'lunch', 'meat', NULL, '2025-04-24', '2025-04-24 12:00:00'),
(3, 15, 1, 'lunch', 'vegetables', NULL, '2025-04-24', '2025-04-24 12:00:00'),
(3, 22, 1, 'dinner', 'meat', NULL, '2025-04-24', '2025-04-24 18:00:00'),
(3, 16, 1, 'dinner', 'vegetables', NULL, '2025-04-24', '2025-04-24 18:00:00'),
(3, 38, 1, 'snack', 'dairy', NULL, '2025-04-24', '2025-04-24 15:00:00'),

-- 周五
(3, 7, 1, 'breakfast', 'fruit', NULL, '2025-04-25', '2025-04-25 08:00:00'),
(3, 15, 1, 'breakfast', 'grains', NULL, '2025-04-25', '2025-04-25 08:00:00'),
(3, 31, 1, 'lunch', 'meat', NULL, '2025-04-25', '2025-04-25 12:00:00'),
(3, 16, 1, 'lunch', 'vegetables', NULL, '2025-04-25', '2025-04-25 12:00:00'),
(3, 23, 1, 'dinner', 'meat', NULL, '2025-04-25', '2025-04-25 18:00:00'),
(3, 9, 1, 'dinner', 'vegetables', NULL, '2025-04-25', '2025-04-25 18:00:00'),
(3, 32, 1, 'snack', 'dairy', NULL, '2025-04-25', '2025-04-25 15:00:00'),

-- 周六
(3, 8, 1, 'breakfast', 'fruit', NULL, '2025-04-26', '2025-04-26 08:00:00'),
(3, 16, 1, 'breakfast', 'grains', NULL, '2025-04-26', '2025-04-26 08:00:00'),
(3, 32, 1, 'lunch', 'meat', NULL, '2025-04-26', '2025-04-26 12:00:00'),
(3, 9, 1, 'lunch', 'vegetables', NULL, '2025-04-26', '2025-04-26 12:00:00'),
(3, 24, 1, 'dinner', 'meat', NULL, '2025-04-26', '2025-04-26 18:00:00'),
(3, 10, 1, 'dinner', 'vegetables', NULL, '2025-04-26', '2025-04-26 18:00:00'),
(3, 33, 1, 'snack', 'dairy', NULL, '2025-04-26', '2025-04-26 15:00:00'),

-- 周日
(3, 1, 1, 'breakfast', 'fruit', NULL, '2025-04-27', '2025-04-27 08:00:00'),
(3, 9, 1, 'breakfast', 'grains', NULL, '2025-04-27', '2025-04-27 08:00:00'),
(3, 25, 1, 'lunch', 'meat', NULL, '2025-04-27', '2025-04-27 12:00:00'),
(3, 10, 1, 'lunch', 'vegetables', NULL, '2025-04-27', '2025-04-27 12:00:00'),
(3, 17, 1, 'dinner', 'meat', NULL, '2025-04-27', '2025-04-27 18:00:00'),
(3, 11, 1, 'dinner', 'vegetables', NULL, '2025-04-27', '2025-04-27 18:00:00'),
(3, 34, 1, 'snack', 'dairy', NULL, '2025-04-27', '2025-04-27 15:00:00'),

-- 用户4的饮食记录
-- 周一
(4, 1, 1, 'breakfast', 'fruit', NULL, '2025-04-21', '2025-04-21 08:00:00'),
(4, 9, 1, 'breakfast', 'grains', NULL, '2025-04-21', '2025-04-21 08:00:00'),
(4, 25, 1, 'lunch', 'meat', NULL, '2025-04-21', '2025-04-21 12:00:00'),
(4, 10, 1, 'lunch', 'vegetables', NULL, '2025-04-21', '2025-04-21 12:00:00'),
(4, 17, 1, 'dinner', 'meat', NULL, '2025-04-21', '2025-04-21 18:00:00'),
(4, 11, 1, 'dinner', 'vegetables', NULL, '2025-04-21', '2025-04-21 18:00:00'),
(4, 33, 1, 'snack', 'dairy', NULL, '2025-04-21', '2025-04-21 15:00:00'),

-- 周二
(4, 2, 1, 'breakfast', 'fruit', NULL, '2025-04-22', '2025-04-22 08:00:00'),
(4, 10, 1, 'breakfast', 'grains', NULL, '2025-04-22', '2025-04-22 08:00:00'),
(4, 26, 1, 'lunch', 'meat', NULL, '2025-04-22', '2025-04-22 12:00:00'),
(4, 11, 1, 'lunch', 'vegetables', NULL, '2025-04-22', '2025-04-22 12:00:00'),
(4, 18, 1, 'dinner', 'meat', NULL, '2025-04-22', '2025-04-22 18:00:00'),
(4, 12, 1, 'dinner', 'vegetables', NULL, '2025-04-22', '2025-04-22 18:00:00'),
(4, 34, 1, 'snack', 'dairy', NULL, '2025-04-22', '2025-04-22 15:00:00'),

-- 周三
(4, 3, 1, 'breakfast', 'fruit', NULL, '2025-04-23', '2025-04-23 08:00:00'),
(4, 11, 1, 'breakfast', 'grains', NULL, '2025-04-23', '2025-04-23 08:00:00'),
(4, 27, 1, 'lunch', 'meat', NULL, '2025-04-23', '2025-04-23 12:00:00'),
(4, 12, 1, 'lunch', 'vegetables', NULL, '2025-04-23', '2025-04-23 12:00:00'),
(4, 19, 1, 'dinner', 'meat', NULL, '2025-04-23', '2025-04-23 18:00:00'),
(4, 13, 1, 'dinner', 'vegetables', NULL, '2025-04-23', '2025-04-23 18:00:00'),
(4, 35, 1, 'snack', 'dairy', NULL, '2025-04-23', '2025-04-23 15:00:00'),

-- 周四
(4, 4, 1, 'breakfast', 'fruit', NULL, '2025-04-24', '2025-04-24 08:00:00'),
(4, 12, 1, 'breakfast', 'grains', NULL, '2025-04-24', '2025-04-24 08:00:00'),
(4, 28, 1, 'lunch', 'meat', NULL, '2025-04-24', '2025-04-24 12:00:00'),
(4, 13, 1, 'lunch', 'vegetables', NULL, '2025-04-24', '2025-04-24 12:00:00'),
(4, 20, 1, 'dinner', 'meat', NULL, '2025-04-24', '2025-04-24 18:00:00'),
(4, 14, 1, 'dinner', 'vegetables', NULL, '2025-04-24', '2025-04-24 18:00:00'),
(4, 36, 1, 'snack', 'dairy', NULL, '2025-04-24', '2025-04-24 15:00:00'),

-- 周五
(4, 5, 1, 'breakfast', 'fruit', NULL, '2025-04-25', '2025-04-25 08:00:00'),
(4, 13, 1, 'breakfast', 'grains', NULL, '2025-04-25', '2025-04-25 08:00:00'),
(4, 29, 1, 'lunch', 'meat', NULL, '2025-04-25', '2025-04-25 12:00:00'),
(4, 14, 1, 'lunch', 'vegetables', NULL, '2025-04-25', '2025-04-25 12:00:00'),
(4, 21, 1, 'dinner', 'meat', NULL, '2025-04-25', '2025-04-25 18:00:00'),
(4, 15, 1, 'dinner', 'vegetables', NULL, '2025-04-25', '2025-04-25 18:00:00'),
(4, 37, 1, 'snack', 'dairy', NULL, '2025-04-25', '2025-04-25 15:00:00'),

-- 周六
(4, 6, 1, 'breakfast', 'fruit', NULL, '2025-04-26', '2025-04-26 08:00:00'),
(4, 14, 1, 'breakfast', 'grains', NULL, '2025-04-26', '2025-04-26 08:00:00'),
(4, 30, 1, 'lunch', 'meat', NULL, '2025-04-26', '2025-04-26 12:00:00'),
(4, 15, 1, 'lunch', 'vegetables', NULL, '2025-04-26', '2025-04-26 12:00:00'),
(4, 22, 1, 'dinner', 'meat', NULL, '2025-04-26', '2025-04-26 18:00:00'),
(4, 16, 1, 'dinner', 'vegetables', NULL, '2025-04-26', '2025-04-26 18:00:00'),
(4, 38, 1, 'snack', 'dairy', NULL, '2025-04-26', '2025-04-26 15:00:00'),

-- 周日
(4, 7, 1, 'breakfast', 'fruit', NULL, '2025-04-27', '2025-04-27 08:00:00'),
(4, 15, 1, 'breakfast', 'grains', NULL, '2025-04-27', '2025-04-27 08:00:00'),
(4, 31, 1, 'lunch', 'meat', NULL, '2025-04-27', '2025-04-27 12:00:00'),
(4, 16, 1, 'lunch', 'vegetables', NULL, '2025-04-27', '2025-04-27 12:00:00'),
(4, 23, 1, 'dinner', 'meat', NULL, '2025-04-27', '2025-04-27 18:00:00'),
(4, 9, 1, 'dinner', 'vegetables', NULL, '2025-04-27', '2025-04-27 18:00:00'),
(4, 32, 1, 'snack', 'dairy', NULL, '2025-04-27', '2025-04-27 15:00:00'),

-- 用户5的饮食记录
-- 周一
(5, 1, 1, 'breakfast', 'fruit', NULL, '2025-04-21', '2025-04-21 08:00:00'),
(5, 9, 1, 'breakfast', 'grains', NULL, '2025-04-21', '2025-04-21 08:00:00'),
(5, 25, 1, 'lunch', 'meat', NULL, '2025-04-21', '2025-04-21 12:00:00'),
(5, 10, 1, 'lunch', 'vegetables', NULL, '2025-04-21', '2025-04-21 12:00:00'),
(5, 17, 1, 'dinner', 'meat', NULL, '2025-04-21', '2025-04-21 18:00:00'),
(5, 11, 1, 'dinner', 'vegetables', NULL, '2025-04-21', '2025-04-21 18:00:00'),
(5, 33, 1, 'snack', 'dairy', NULL, '2025-04-21', '2025-04-21 15:00:00'),

-- 周二
(5, 2, 1, 'breakfast', 'fruit', NULL, '2025-04-22', '2025-04-22 08:00:00'),
(5, 10, 1, 'breakfast', 'grains', NULL, '2025-04-22', '2025-04-22 08:00:00'),
(5, 26, 1, 'lunch', 'meat', NULL, '2025-04-22', '2025-04-22 12:00:00'),
(5, 11, 1, 'lunch', 'vegetables', NULL, '2025-04-22', '2025-04-22 12:00:00'),
(5, 18, 1, 'dinner', 'meat', NULL, '2025-04-22', '2025-04-22 18:00:00'),
(5, 12, 1, 'dinner', 'vegetables', NULL, '2025-04-22', '2025-04-22 18:00:00'),
(5, 34, 1, 'snack', 'dairy', NULL, '2025-04-22', '2025-04-22 15:00:00'),

-- 周三
(5, 3, 1, 'breakfast', 'fruit', NULL, '2025-04-23', '2025-04-23 08:00:00'),
(5, 11, 1, 'breakfast', 'grains', NULL, '2025-04-23', '2025-04-23 08:00:00'),
(5, 27, 1, 'lunch', 'meat', NULL, '2025-04-23', '2025-04-23 12:00:00'),
(5, 12, 1, 'lunch', 'vegetables', NULL, '2025-04-23', '2025-04-23 12:00:00'),
(5, 19, 1, 'dinner', 'meat', NULL, '2025-04-23', '2025-04-23 18:00:00'),
(5, 13, 1, 'dinner', 'vegetables', NULL, '2025-04-23', '2025-04-23 18:00:00'),
(5, 35, 1, 'snack', 'dairy', NULL, '2025-04-23', '2025-04-23 15:00:00'),

-- 周四
(5, 4, 1, 'breakfast', 'fruit', NULL, '2025-04-24', '2025-04-24 08:00:00'),
(5, 12, 1, 'breakfast', 'grains', NULL, '2025-04-24', '2025-04-24 08:00:00'),
(5, 28, 1, 'lunch', 'meat', NULL, '2025-04-24', '2025-04-24 12:00:00'),
(5, 13, 1, 'lunch', 'vegetables', NULL, '2025-04-24', '2025-04-24 12:00:00'),
(5, 20, 1, 'dinner', 'meat', NULL, '2025-04-24', '2025-04-24 18:00:00'),
(5, 14, 1, 'dinner', 'vegetables', NULL, '2025-04-24', '2025-04-24 18:00:00'),
(5, 36, 1, 'snack', 'dairy', NULL, '2025-04-24', '2025-04-24 15:00:00'),

-- 周五
(5, 5, 1, 'breakfast', 'fruit', NULL, '2025-04-25', '2025-04-25 08:00:00'),
(5, 13, 1, 'breakfast', 'grains', NULL, '2025-04-25', '2025-04-25 08:00:00'),
(5, 29, 1, 'lunch', 'meat', NULL, '2025-04-25', '2025-04-25 12:00:00'),
(5, 14, 1, 'lunch', 'vegetables', NULL, '2025-04-25', '2025-04-25 12:00:00'),
(5, 21, 1, 'dinner', 'meat', NULL, '2025-04-25', '2025-04-25 18:00:00'),
(5, 15, 1, 'dinner', 'vegetables', NULL, '2025-04-25', '2025-04-25 18:00:00'),
(5, 37, 1, 'snack', 'dairy', NULL, '2025-04-25', '2025-04-25 15:00:00'),

-- 周六
(5, 6, 1, 'breakfast', 'fruit', NULL, '2025-04-26', '2025-04-26 08:00:00'),
(5, 14, 1, 'breakfast', 'grains', NULL, '2025-04-26', '2025-04-26 08:00:00'),
(5, 30, 1, 'lunch', 'meat', NULL, '2025-04-26', '2025-04-26 12:00:00'),
(5, 15, 1, 'lunch', 'vegetables', NULL, '2025-04-26', '2025-04-26 12:00:00'),
(5, 22, 1, 'dinner', 'meat', NULL, '2025-04-26', '2025-04-26 18:00:00'),
(5, 16, 1, 'dinner', 'vegetables', NULL, '2025-04-26', '2025-04-26 18:00:00'),
(5, 38, 1, 'snack', 'dairy', NULL, '2025-04-26', '2025-04-26 15:00:00'),

-- 周日
(5, 7, 1, 'breakfast', 'fruit', NULL, '2025-04-27', '2025-04-27 08:00:00'),
(5, 15, 1, 'breakfast', 'grains', NULL, '2025-04-27', '2025-04-27 08:00:00'),
(5, 31, 1, 'lunch', 'meat', NULL, '2025-04-27', '2025-04-27 12:00:00'),
(5, 16, 1, 'lunch', 'vegetables', NULL, '2025-04-27', '2025-04-27 12:00:00'),
(5, 23, 1, 'dinner', 'meat', NULL, '2025-04-27', '2025-04-27 18:00:00'),
(5, 9, 1, 'dinner', 'vegetables', NULL, '2025-04-27', '2025-04-27 18:00:00'),
(5, 32, 1, 'snack', 'dairy', NULL, '2025-04-27', '2025-04-27 15:00:00'),

-- 用户6的饮食记录
-- 周一
(6, 1, 1, 'breakfast', 'fruit', NULL, '2025-04-21', '2025-04-21 08:00:00'),
(6, 9, 1, 'breakfast', 'grains', NULL, '2025-04-21', '2025-04-21 08:00:00'),
(6, 25, 1, 'lunch', 'meat', NULL, '2025-04-21', '2025-04-21 12:00:00'),
(6, 10, 1, 'lunch', 'vegetables', NULL, '2025-04-21', '2025-04-21 12:00:00'),
(6, 17, 1, 'dinner', 'meat', NULL, '2025-04-21', '2025-04-21 18:00:00'),
(6, 11, 1, 'dinner', 'vegetables', NULL, '2025-04-21', '2025-04-21 18:00:00'),
(6, 33, 1, 'snack', 'dairy', NULL, '2025-04-21', '2025-04-21 15:00:00'),

-- 周二
(6, 2, 1, 'breakfast', 'fruit', NULL, '2025-04-22', '2025-04-22 08:00:00'),
(6, 10, 1, 'breakfast', 'grains', NULL, '2025-04-22', '2025-04-22 08:00:00'),
(6, 26, 1, 'lunch', 'meat', NULL, '2025-04-22', '2025-04-22 12:00:00'),
(6, 11, 1, 'lunch', 'vegetables', NULL, '2025-04-22', '2025-04-22 12:00:00'),
(6, 18, 1, 'dinner', 'meat', NULL, '2025-04-22', '2025-04-22 18:00:00'),
(6, 12, 1, 'dinner', 'vegetables', NULL, '2025-04-22', '2025-04-22 18:00:00'),
(6, 34, 1, 'snack', 'dairy', NULL, '2025-04-22', '2025-04-22 15:00:00'),

-- 周三
(6, 3, 1, 'breakfast', 'fruit', NULL, '2025-04-23', '2025-04-23 08:00:00'),
(6, 11, 1, 'breakfast', 'grains', NULL, '2025-04-23', '2025-04-23 08:00:00'),
(6, 27, 1, 'lunch', 'meat', NULL, '2025-04-23', '2025-04-23 12:00:00'),
(6, 12, 1, 'lunch', 'vegetables', NULL, '2025-04-23', '2025-04-23 12:00:00'),
(6, 19, 1, 'dinner', 'meat', NULL, '2025-04-23', '2025-04-23 18:00:00'),
(6, 13, 1, 'dinner', 'vegetables', NULL, '2025-04-23', '2025-04-23 18:00:00'),
(6, 35, 1, 'snack', 'dairy', NULL, '2025-04-23', '2025-04-23 15:00:00'),

-- 周四
(6, 4, 1, 'breakfast', 'fruit', NULL, '2025-04-24', '2025-04-24 08:00:00'),
(6, 12, 1, 'breakfast', 'grains', NULL, '2025-04-24', '2025-04-24 08:00:00'),
(6, 28, 1, 'lunch', 'meat', NULL, '2025-04-24', '2025-04-24 12:00:00'),
(6, 13, 1, 'lunch', 'vegetables', NULL, '2025-04-24', '2025-04-24 12:00:00'),
(6, 20, 1, 'dinner', 'meat', NULL, '2025-04-24', '2025-04-24 18:00:00'),
(6, 14, 1, 'dinner', 'vegetables', NULL, '2025-04-24', '2025-04-24 18:00:00'),
(6, 36, 1, 'snack', 'dairy', NULL, '2025-04-24', '2025-04-24 15:00:00'),

-- 周五
(6, 5, 1, 'breakfast', 'fruit', NULL, '2025-04-25', '2025-04-25 08:00:00'),
(6, 13, 1, 'breakfast', 'grains', NULL, '2025-04-25', '2025-04-25 08:00:00'),
(6, 29, 1, 'lunch', 'meat', NULL, '2025-04-25', '2025-04-25 12:00:00'),
(6, 14, 1, 'lunch', 'vegetables', NULL, '2025-04-25', '2025-04-25 12:00:00'),
(6, 21, 1, 'dinner', 'meat', NULL, '2025-04-25', '2025-04-25 18:00:00'),
(6, 15, 1, 'dinner', 'vegetables', NULL, '2025-04-25', '2025-04-25 18:00:00'),
(6, 37, 1, 'snack', 'dairy', NULL, '2025-04-25', '2025-04-25 15:00:00'),

-- 周六
(6, 6, 1, 'breakfast', 'fruit', NULL, '2025-04-26', '2025-04-26 08:00:00'),
(6, 14, 1, 'breakfast', 'grains', NULL, '2025-04-26', '2025-04-26 08:00:00'),
(6, 30, 1, 'lunch', 'meat', NULL, '2025-04-26', '2025-04-26 12:00:00'),
(6, 15, 1, 'lunch', 'vegetables', NULL, '2025-04-26', '2025-04-26 12:00:00'),
(6, 22, 1, 'dinner', 'meat', NULL, '2025-04-26', '2025-04-26 18:00:00'),
(6, 16, 1, 'dinner', 'vegetables', NULL, '2025-04-26', '2025-04-26 18:00:00'),
(6, 38, 1, 'snack', 'dairy', NULL, '2025-04-26', '2025-04-26 15:00:00'),

-- 周日
(6, 7, 1, 'breakfast', 'fruit', NULL, '2025-04-27', '2025-04-27 08:00:00'),
(6, 15, 1, 'breakfast', 'grains', NULL, '2025-04-27', '2025-04-27 08:00:00'),
(6, 31, 1, 'lunch', 'meat', NULL, '2025-04-27', '2025-04-27 12:00:00'),
(6, 16, 1, 'lunch', 'vegetables', NULL, '2025-04-27', '2025-04-27 12:00:00'),
(6, 23, 1, 'dinner', 'meat', NULL, '2025-04-27', '2025-04-27 18:00:00'),
(6, 9, 1, 'dinner', 'vegetables', NULL, '2025-04-27', '2025-04-27 18:00:00'),
(6, 32, 1, 'snack', 'dairy', NULL, '2025-04-27', '2025-04-27 15:00:00');

-- 先删除 food_records 表中的所有数据
DELETE FROM food_records;

-- 插入更合理的每日总结记录
INSERT INTO food_records (user_id, record_date, meal_type, vegetables, fruit, grains, meat, dairy, extras) VALUES
-- 周一
(1, '2025-04-21 00:00:00', 'daily', 2, 1, 1, 1, 1, 0),
(2, '2025-04-21 00:00:00', 'daily', 2, 1, 1, 1, 1, 0),
(3, '2025-04-21 00:00:00', 'daily', 2, 1, 1, 1, 1, 0),
(4, '2025-04-21 00:00:00', 'daily', 2, 1, 1, 1, 1, 0),
(5, '2025-04-21 00:00:00', 'daily', 2, 1, 1, 1, 1, 0),
(6, '2025-04-21 00:00:00', 'daily', 2, 1, 1, 1, 1, 0),

-- 周二
(1, '2025-04-22 00:00:00', 'daily', 2, 1, 1, 1, 1, 0),
(2, '2025-04-22 00:00:00', 'daily', 2, 1, 1, 1, 1, 0),
(3, '2025-04-22 00:00:00', 'daily', 2, 1, 1, 1, 1, 0),
(4, '2025-04-22 00:00:00', 'daily', 2, 1, 1, 1, 1, 0),
(5, '2025-04-22 00:00:00', 'daily', 2, 1, 1, 1, 1, 0),
(6, '2025-04-22 00:00:00', 'daily', 2, 1, 1, 1, 1, 0),

-- 周三
(1, '2025-04-23 00:00:00', 'daily', 2, 1, 1, 1, 1, 0),
(2, '2025-04-23 00:00:00', 'daily', 2, 1, 1, 1, 1, 0),
(3, '2025-04-23 00:00:00', 'daily', 2, 1, 1, 1, 1, 0),
(4, '2025-04-23 00:00:00', 'daily', 2, 1, 1, 1, 1, 0),
(5, '2025-04-23 00:00:00', 'daily', 2, 1, 1, 1, 1, 0),
(6, '2025-04-23 00:00:00', 'daily', 2, 1, 1, 1, 1, 0),

-- 周四
(1, '2025-04-24 00:00:00', 'daily', 2, 1, 1, 1, 1, 0),
(2, '2025-04-24 00:00:00', 'daily', 2, 1, 1, 1, 1, 0),
(3, '2025-04-24 00:00:00', 'daily', 2, 1, 1, 1, 1, 0),
(4, '2025-04-24 00:00:00', 'daily', 2, 1, 1, 1, 1, 0),
(5, '2025-04-24 00:00:00', 'daily', 2, 1, 1, 1, 1, 0),
(6, '2025-04-24 00:00:00', 'daily', 2, 1, 1, 1, 1, 0),

-- 周五
(1, '2025-04-25 00:00:00', 'daily', 2, 1, 1, 1, 1, 0),
(2, '2025-04-25 00:00:00', 'daily', 2, 1, 1, 1, 1, 0),
(3, '2025-04-25 00:00:00', 'daily', 2, 1, 1, 1, 1, 0),
(4, '2025-04-25 00:00:00', 'daily', 2, 1, 1, 1, 1, 0),
(5, '2025-04-25 00:00:00', 'daily', 2, 1, 1, 1, 1, 0),
(6, '2025-04-25 00:00:00', 'daily', 2, 1, 1, 1, 1, 0),

-- 周六
(1, '2025-04-26 00:00:00', 'daily', 2, 1, 1, 1, 1, 0),
(2, '2025-04-26 00:00:00', 'daily', 2, 1, 1, 1, 1, 0),
(3, '2025-04-26 00:00:00', 'daily', 2, 1, 1, 1, 1, 0),
(4, '2025-04-26 00:00:00', 'daily', 2, 1, 1, 1, 1, 0),
(5, '2025-04-26 00:00:00', 'daily', 2, 1, 1, 1, 1, 0),
(6, '2025-04-26 00:00:00', 'daily', 2, 1, 1, 1, 1, 0),

-- 周日
(1, '2025-04-27 00:00:00', 'daily', 2, 1, 1, 1, 1, 0),
(2, '2025-04-27 00:00:00', 'daily', 2, 1, 1, 1, 1, 0),
(3, '2025-04-27 00:00:00', 'daily', 2, 1, 1, 1, 1, 0),
(4, '2025-04-27 00:00:00', 'daily', 2, 1, 1, 1, 1, 0),
(5, '2025-04-27 00:00:00', 'daily', 2, 1, 1, 1, 1, 0),
(6, '2025-04-27 00:00:00', 'daily', 2, 1, 1, 1, 1, 0);




