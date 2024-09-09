
#!pip install kaggle
#Download dataset using kaggle api
import kaggle
!kaggle datasets download ankitbansal06/retail-orders -f orders.csv

#extract file from zip file
import zipfile
zip_ref = zipfile.ZipFile('orders.csv.zip')
zip_ref.extractall()
zip_ref.close()

#import pandas
import pandas as pd

#read data from the file and handle null values
df = pd.read_csv('orders.csv',na_values=['Not Available', 'unknown'])

#rename column names, make them lower case and replace space with underscore
df.columns= df.columns.str.lower().str.replace(' ','_')

#derive new columns discount, sale price and profit
df["discount_price"] = df["list_price"]* df["discount_percent"]*.01
df["sale_price"] = df["list_price"] - df["discount_percent"]
df["profit"] = df["sale_price"] - df["cost_price"]

#drop cost price, list price and discount percent columns
del df["cost_price"]
df = df.drop(columns=["list_price","discount_percent"])

#convert order date from object data type to datetime
df['order_date']= pd.to_datetime(df['order_date'], format ="%Y-%m-%d")

#establish a connection to MSSQL Server database named masters using ODBC Driver 17 for SQL Server
import pyodbc
connection = pyodbc.connect('Driver={ODBC Driver 17 for SQL Server};Server=LAPTOP-A4UVL8PI\SQLEXPRESS;'
                            'Database=masters;Trusted_Connection=yes;')

#The df_orders table's DDL is already available so we append the data to the table						
df.to_sql('df_orders', con=conn, index=False, if_exists='append')