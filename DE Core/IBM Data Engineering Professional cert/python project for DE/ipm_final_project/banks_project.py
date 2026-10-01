from datetime import datetime
import sqlite3
from bs4 import BeautifulSoup
import numpy as np
import pandas as pd
import requests

# Global Variables
url = 'https://web.archive.org/web/20230908091635/https://en.wikipedia.org/wiki/List_of_largest_banks'
table_attribs = ['Name', 'MC_USD_Billion']
table_name = 'Largest_banks'
exchange_rate_csv = 'exchange_rate.csv'
Largest_banks_data = './Largest_banks_data.csv'
db_name = 'Banks.db'
log_file = 'code_log.txt'


def log_progress(message):
  '''Logs the mentioned message at a given stage of the code execution to a log file.'''
  timestamp_format = '%Y-%b-%d-%H:%M:%S'
  now = datetime.now()
  timestamp = now.strftime(timestamp_format)
  with open(log_file, 'a') as f:
    f.write(f'{timestamp} : {message}\n')


def extract(url, table_attribs):
  '''Extracts the required information from the website using web scraping.'''
  page = requests.get(url).text
  data = BeautifulSoup(page, 'html.parser')

  df = pd.DataFrame(columns=table_attribs)

  tables = data.find_all('tbody')
  rows = tables[0].find_all('tr')

  for row in rows:
    col = row.find_all('td')
    if len(col) != 0:
      bank_name = (
          col[1].find_all('a')[1].text.strip()
          if len(col[1].find_all('a')) > 1
          else col[1].text.strip()
      )
      market_cap = float(
          col[2].text.strip().replace(',', '').replace('\n', '')
      )

      df1 = pd.DataFrame([{
          table_attribs[0]: bank_name,
          table_attribs[1]: market_cap,
      }])
      df = pd.concat([df, df1], ignore_index=True)

  return df

extract(url, table_attribs)
df= extract(url, table_attribs)

def transform(df, csv_path):
  '''Converts Market Cap to GBP, EUR, and INR, and rounds to 2 decimal places.'''
  exchange_rate_df = pd.read_csv(csv_path)
  dict_rates = exchange_rate_df.set_index('Currency').to_dict()['Rate']

  df['MC_GBP_Billion'] = [
      np.round(x * dict_rates['GBP'], 2) for x in df['MC_USD_Billion']
  ]
  df['MC_EUR_Billion'] = [
      np.round(x * dict_rates['EUR'], 2) for x in df['MC_USD_Billion']
  ]
  df['MC_INR_Billion'] = [
      np.round(x * dict_rates['INR'], 2) for x in df['MC_USD_Billion']
  ]

  return df

transform(df, exchange_rate_csv)
df=transform(df, exchange_rate_csv)

def load_to_csv(df, csv_path):
  '''Saves the final dataframe as a CSV file.'''
  df.to_csv(csv_path, index=False)
  log_progress('Data saved to CSV file')

load_to_csv(df, Largest_banks_data)

def load_to_db(df, sql_connection, table_name):
  '''Saves the final dataframe to a database table.'''
  df.to_sql(table_name, sql_connection, if_exists='replace', index=False)

load_to_db(df, sqlite3.connect(db_name), table_name)

def run_query(query_statement, sql_connection):
  '''Runs specified queries on the database table.'''
  print(f'query : {query_statement}\n')
  query_output = pd.read_sql(query_statement, sql_connection)
  print(query_output)

run_query('SELECT * FROM Largest_banks', sqlite3.connect(db_name))

# --- Pipeline Execution ---
if __name__ == '__main__':
  log_progress('ETL Process Started')

  # Extract
  df = extract(url, table_attribs)
  log_progress('Data extraction completed')

  # Transform
  df = transform(df, exchange_rate_csv)
  log_progress('Data transformation completed')

  # Load to CSV
  load_to_csv(df, Largest_banks_data)

  # Load to DB
  log_progress('SQL Connection initiated')
  conn = sqlite3.connect(db_name)
  load_to_db(df, conn, table_name)
  log_progress('Data loaded to Database as table. Running queries now')

  # Queries
  run_query('SELECT * FROM Largest_banks', conn)
  run_query('SELECT AVG(MC_GBP_Billion) FROM Largest_banks', conn)
  run_query('SELECT Name from Largest_banks LIMIT 5', conn)

  conn.close()
  log_progress('Process Completed')
  

# Task 7: Verify Log File
def verify_log_file(log_file):
    with open(log_file, 'r') as file:
        print(file.read())

verify_log_file('code_log.txt')

import urllib.request

url = "https://cf-courses-data.s3.us.cloud-object-storage.appdomain.cloud/IBMSkillsNetwork-PY0221EN-Coursera/labs/v2/exchange_rate.csv"
urllib.request.urlretrieve(url, "exchange_rate.csv")