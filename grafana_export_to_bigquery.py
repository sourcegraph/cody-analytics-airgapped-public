# This script uses the grafana API to pull data from a sourcegraph instance into Google BigQuery
import requests
import pandas as pd
from io import StringIO
from dotenv import load_dotenv, find_dotenv
from google.oauth2 import service_account
from google.cloud import bigquery
import os
import logging

# Set up logging
logging.basicConfig(
    level=logging.INFO, format="%(asctime)s - %(levelname)s - %(message)s"
)

load_dotenv(find_dotenv())

credentials = service_account.Credentials.from_service_account_file(
    os.getenv("GOOGLE_SERVICE_ACCOUNT_FILE")
)

# initialize the Google BigQuery client
bq_client = bigquery.Client(credentials=credentials)


def get_api_response(query):
    # Define the API endpoint
    url = "{sg_instance_url}/debug/grafana/api/tsdb/query"
    api_key = os.getenv("GRAFANA_API_KEY")
    # Define the headers
    headers = {
        "content-type": "application/json",
        "Authorization": f"token {api_key}",
    }

    # Define the payload
    payload = {
        "from": "1725842082378",
        "to": "1728434082378",
        "queries": [
            {
                "refId": "A",
                "intervalMs": 3600000,
                "maxDataPoints": 852,
                "datasourceId": 3,
                "rawSql": query
                "format": "table",
            }
        ],
    }

    # Make the POST request
    response = requests.post(url, headers=headers, json=payload)

    response.raise_for_status()

    return response


def get_dataframe(response):
    # Parse the JSON response
    data = response.json()

    # Check if there's an error in the response
    if "error" in data["results"]["A"]:
        raise ValueError(f"Error: {data['results']['A']['error']}")
    # Extract the table data
    table_data = data["results"]["A"]["tables"][0]

    # Create a DataFrame
    df = pd.DataFrame(
        table_data["rows"], columns=[col["text"] for col in table_data["columns"]]
    )
    return cast_df_types(df)


def cast_df_types(df):
    type_mapping = {
        "int64": ["id", "user_id"],
        "string": [
            "name",
            "url",
            "anonymous_user_id",
            "source",
            "argument",
            "version",
            "feature_flags",
            "cohort_id",
            "public_argument",
            "first_source_url",
            "last_source_url",
            "referrer",
            "device_id",
            "insert_id",
            "billing_product_category",
            "billing_event_id",
            "client",
            "tenant_id",
        ],
        "datetime64[ns]": ["timestamp"],
    }
    for dtype, columns in type_mapping.items():
        for col in columns:
            if col in df.columns:
                if dtype == "datetime64[ns]":
                    df[col] = pd.to_datetime(df[col]).dt.tz_localize(None)
                else:
                    df[col] = df[col].astype(dtype)
    return df


def df_to_bq_table(df, project_id, dataset_id, table_id):
    # Create a BigQuery client
    client = bigquery.Client()
    # Define the table ID
    table_id = f"{project_id}.{dataset_id}.{table_id}"
    # Define the schema
    schema = [
        bigquery.SchemaField("id", "INTEGER"),
        bigquery.SchemaField("name", "STRING"),
        bigquery.SchemaField("url", "STRING"),
        bigquery.SchemaField("user_id", "INTEGER"),
        bigquery.SchemaField("anonymous_user_id", "STRING"),
        bigquery.SchemaField("source", "STRING"),
        bigquery.SchemaField("argument", "STRING"),
        bigquery.SchemaField("version", "STRING"),
        bigquery.SchemaField("timestamp", "TIMESTAMP"),
        bigquery.SchemaField("feature_flags", "STRING"),
        bigquery.SchemaField("cohort_id", "STRING"),
        bigquery.SchemaField("public_argument", "STRING"),
        bigquery.SchemaField("first_source_url", "STRING"),
        bigquery.SchemaField("last_source_url", "STRING"),
        bigquery.SchemaField("referrer", "STRING"),
        bigquery.SchemaField("device_id", "STRING"),
        bigquery.SchemaField("insert_id", "STRING"),
        bigquery.SchemaField("billing_product_category", "STRING"),
        bigquery.SchemaField("billing_event_id", "STRING"),
        bigquery.SchemaField("client", "STRING"),
        bigquery.SchemaField("tenant_id", "STRING"),
    ]

    # Configure the load job
    job_config = bigquery.LoadJobConfig(
        write_disposition=bigquery.WriteDisposition.WRITE_TRUNCATE, schema=schema
    )

    # Load the dataframe into the BigQuery table
    job = client.load_table_from_dataframe(df, table_id, job_config=job_config)

    # Wait for the job to complete and get the result
    job.result()

    logging.info(f"Loaded {job.output_rows} rows into {table_id}")
    return job


def main():
	query = "select * from event_logs where date(timestamp) = '2024-10-09'"
    project_name = "project_name"
    dataset_name = "dataset_name"
    table_name = "table_name"

    try:
        response = get_api_response(query)
        df = get_dataframe(response)
        df_to_bq_table(df, project_name, dataset_name, table_name)
    except Exception as e:
        logging.error(f"An error occurred: {str(e)}")


if __name__ == "__main__":
    main()
