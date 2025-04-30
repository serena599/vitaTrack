import pandas as pd
import mysql.connector
from datetime import datetime

# 数据库连接配置
config = {
    'user': 'root',
    'password': 'szzSZZ!350',  # 输入你的密码
    'host': 'localhost',
    'database': 'myfoodchoice'
}

# 创建Excel写入器
excel_writer = pd.ExcelWriter('/Users/zhongzhengsu/Desktop/VitaTrack/data.xlsx', engine='xlsxwriter')

try:
    # 连接数据库
    conn = mysql.connector.connect(**config)
    cursor = conn.cursor()

    # 要导出的表名列表
    tables = ['user', 'foods', 'meal_records', 'food_records', 'goal_settings']

    # 遍历每个表并导出到Excel的不同sheet
    for table in tables:
        # 执行查询
        query = f"SELECT * FROM {table}"
        cursor.execute(query)
        
        # 获取列名
        columns = [desc[0] for desc in cursor.description]
        
        # 获取数据
        data = cursor.fetchall()
        
        # 创建DataFrame
        df = pd.DataFrame(data, columns=columns)
        
        # 写入Excel
        df.to_excel(excel_writer, sheet_name=table, index=False)
        
        print(f"Exported {table} table successfully")

    # 保存Excel文件
    excel_writer.close()
    print("All tables exported successfully to data.xlsx")

except mysql.connector.Error as err:
    print(f"Error: {err}")

finally:
    if 'conn' in locals() and conn.is_connected():
        cursor.close()
        conn.close()
        print("Database connection closed")