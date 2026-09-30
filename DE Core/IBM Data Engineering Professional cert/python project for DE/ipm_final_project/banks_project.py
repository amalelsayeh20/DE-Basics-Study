import requests
from bs4 import BeautifulSoup
import pandas as pd
import numpy as np
import sqlite3
from datetime import datetime

url = "https://web.archive.org/web/20230908091635/https://en.wikipedia.org/wiki/List_of_largest_banks"
table_attribs = ['Name', 'MC_USD_Billion']

table_name =  'Largest_banks'
exchange_rate_csv = 'https://cf-courses-data.s3.us.cloud-object-storage.appdomain.cloud/IBMSkillsNetwork-PY0221EN-Coursera/labs/v2/exchange_rate.csv'
output_csv = './Largest_banks_data.csv'

db_name = 'Banks.db'
log_file = 'code_log.txt'

df = pd.DataFrame(columns=table_attribs)

# --- Task 1: Logging Function ---
def log_progress(message):
    ''' Logs the mentioned message at a given stage of the code execution to a log file. '''
    
    timestamp_format = '%Y-%b-%d-%H:%M:%S' # Year-Monthname-Day-Hour-Minute-Second
    now = datetime.now()
    timestamp = now.strftime(timestamp_format)
    with open(log_file, "a") as f:
        f.write(f"{timestamp} : {message}\n")
        
        
def extract(url, table_attribs):
    page = requests.get(url).text
    data = BeautifulSoup(page, 'html.parser')
    
    rows_list = []
    tables = data.find_all('tbody')
    rows = tables[0].find_all('tr')

    for row in rows:
        col = row.find_all('td')
        if len(col) != 0:
            bank_name = col[1].text.strip()
            market_cap = float(col[2].text.strip().replace(',', '').replace('\n', ''))
            rows_list.append({'Name': bank_name, 'MC_USD_Billion': market_cap})

    df = pd.DataFrame(rows_list)
    return df

extract(url, table_attribs)
df = extract(url, table_attribs)


# --- Task 3: Transformation Function ---
def transform(df, csv_path):
    ''' Reads exchange rate CSV, converts Market Cap to GBP, EUR, and INR, and rounds to 2 decimal places. '''
    exchange_rate_df = pd.read_csv(csv_path)
    dict_rates = exchange_rate_df.set_index('Currency').to_dict()['Rate']
    
    # تحويل القيم والتقريب لرقيمين عشريين
    df['MC_GBP_Billion'] = [np.round(x * dict_rates['GBP'], 2) for x in df['MC_USD_Billion']]
    df['MC_EUR_Billion'] = [np.round(x * dict_rates['EUR'], 2) for x in df['MC_USD_Billion']]
    df['MC_INR_Billion'] = [np.round(x * dict_rates['INR'], 2) for x in df['MC_USD_Billion']]
    
    return df

transform(df, exchange_rate_csv)
df = transform(df, exchange_rate_csv)

# Task 4: Load to CSV
def load_to_csv(df, csv_path):
    df.to_csv(csv_path, index=False)
    
load_to_csv(df, output_csv)

# Task 5: Load to DB
def load_to_db(df, sql_connection, table_name):
    df.to_sql(table_name, sql_connection, if_exists='replace', index=False)

load_to_db(df, sqlite3.connect('Banks.db'), table_name)

# Task 6: Run Query
def run_query(query_statement, sql_connection): # ✅ تصحيح run_query
    print(f'query : {query_statement}\n')
    query_output = pd.read_sql(query_statement, sql_connection)
    print(query_output)
run_query("SELECT * FROM Largest_banks", sqlite3.connect('Banks.db'))



log_progress('ETL Process Started')
log_progress('Data extraction completed')
log_progress('Data transformation completed')
log_progress('Data saved to CSV file')
log_progress('SQL Connection initiated')
log_progress('Data loaded to Database as table. Running queries now')
log_progress('Process Completed')


# Task 7: Verify Log File
def verify_log_file(log_file):
    with open(log_file, 'r') as file:
        print(file.read())

verify_log_file('code_log.txt')


import urllib.request

url = "https://cf-courses-data.s3.us.cloud-object-storage.appdomain.cloud/IBMSkillsNetwork-PY0221EN-Coursera/labs/v2/exchange_rate.csv"
urllib.request.urlretrieve(url, "exchange_rate.csv")