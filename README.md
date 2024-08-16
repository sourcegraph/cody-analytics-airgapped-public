# cody-analytics-airgapped-public

Use this repo to share SQL queries with customers who have telemetry disabled, but still need to get Cody usage analytics

## Running the Queries (Sourcegraph Customer)

This script can be used in either of two modes, depending on where your Sourcegraph database is hosted, and how you can connect to it

### Mode 1: Your Sourcegraph database is running in the pgsql pod in the default Helm chart, and you have kubectl access to your cluster

The script will send commands to the kubectl CLI on your computer

1. Clone this repo to your computer with kubectl installed
2. Pull the latest commits to main
3. Configure and authenticate kubectl to your Kubernetes cluster before running this script
4. Run the [run-sql-queries.sh](./run-sql-queries.sh) script with no args

`./run-sql-queries.sh`

5. Find the query output in the `./run-sql-queries.sh-output.txt` file

### Mode 2: You have direct psql access to your database

The script will send commands to the psql CLI on your computer

1. Clone this repo to your computer with the psql CLI client installed
2. Pull the latest commits to main
3. Run the [run-sql-queries.sh](./run-sql-queries.sh) script, with the following args:

`./run-sql-queries.sh psql <hostname> <port> <database name> <username or role>`

4. Find the query output in the `./run-sql-queries.sh-output.txt` file

## Updating the List of Cody Telemetry Event Names (Sourcegraph Staff)

This process will be eliminated once [RFC 978](https://docs.google.com/document/d/1EvyH1kaU-fsn59h-DyoaO2Qy4C2TYLmDGjG73bdb2V4/edit#heading=h.trqab8y0kufp) is implemented, as the SQL query to pull the correct event types will be succinct and added in the `.sql` files, or once we find a way to automate this.

1. Copy the contents from either (both should automatically update themselves every 24 hours):
    1. [This Google Sheet](https://docs.google.com/spreadsheets/d/1Hef4yQxSlelKINs3Jo9TyF4BMWwa7XETP-iPUsriibA/edit?gid=971556367#gid=971556367)
    2. [This Redash Query](https://redash.sgdev.org/queries/929/source), download as a TSV
2. Replace the contents of the [cody-events-list](./cody-events-list) file
3. Commit and push the changes to this repo
4. Notify the customer

## Editing Queries

1. Store SQL queries as individual `.sql` files in the [./queries](./queries) directory of this repo
2. Include the line `--cody-events-list-gets-inserted-here` if / where you'd like the contents of the [cody-events-list](./cody-events-list) file to get inserted, ex:

```sql
-- Total Cody users, all time
SELECT
    COUNT(DISTINCT user_id) AS distinct_users
FROM
    event_logs
WHERE
    LOWER(name) LIKE 'cody%'
    AND name IN(
        --cody-events-list-gets-inserted-here
    );
```

3. Ensure the query ends with a semicolon, because SQL
4. Ensure the `.sql` file names are numbered in the order you'd like them to run in
5. Ensure the `.sql` file names are descriptive, as they're used as section headers between the output tables in the `./run-sql-queries.sh-output.txt` file
6. [Test the queries on S2](https://docs.google.com/document/d/1wHYHhr2BmgOPDl6tCO3fiiLyV_WOQQ-nL8IomxcP1FM/edit#heading=h.34phj72ft71k)
7. Commit and push your changes to this repo
8. Notify the customer

## Internal Project Context

1. [Google doc](https://docs.google.com/document/d/1wHYHhr2BmgOPDl6tCO3fiiLyV_WOQQ-nL8IomxcP1FM/edit)
2. [Slack channel](https://sourcegraph.slack.com/archives/C07EZ2W4U9H)
3. Sourcegraph Docs page on [how to connect to your Sourcegraph database](https://sourcegraph.com/docs/admin/deploy/kubernetes/operations#access-the-database)
