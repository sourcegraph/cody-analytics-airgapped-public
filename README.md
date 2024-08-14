# cody-analytics-airgapped-public

Use this repo to share SQL queries with customers who have telemetry disabled, but still need to get Cody usage analytics

## Running the Queries

This script can be used in either of two modes.

### Mode 1: Your Sourcegraph database is running in the pgsql pod in the default Helm chart, and you have kubectl access to your cluster

1. Clone this repo to your host with kubectl installed
2. Configure and authenticate kubectl to your Kubernetes cluster before running this script
3. Run the [run-sql-queries.sh](./run-sql-queries.sh) script with no args
4. Find your output in the [run-sql-queries.sh-output.txt](run-sql-queries.sh-output.txt) file

### Mode 2: You have direct psql access to your database

1. Clone this repo to your host with the psql CLI client installed
2. Run the [run-sql-queries.sh](./run-sql-queries.sh) script, with the following args:

`./run-sql-queries.sh psql <hostname> <port> <database name> <username or role>`

3. Find your output in the [run-sql-queries.sh-output.txt](run-sql-queries.sh-output.txt) file

## Editing Queries

1. Store SQL queries as individual `.sql` files in the root directory of this repo
2. Include the line `--cody-events-list-gets-inserted-here` if / where you'd like the contents of the [cody-events-list](./cody-events-list) file to get inserted
3. Name the files in the order you'd like them run; these file names will be included in the [run-sql-queries.sh-output.txt](run-sql-queries.sh-output.txt) file

## Updating the List of Cody Telemetry Event Names

1. Open [this](https://redash.sgdev.org/queries/929/source) query
2. Download the results as a TSV file
3. Replace the contents of the [cody-events-list](./cody-events-list) file with the contents of the results TSV file

## Context

1. Sourcegraph Docs page on [how to connect to your Sourcegraph database](https://sourcegraph.com/docs/admin/deploy/kubernetes/operations#access-the-database)
2. Internal project [Google doc](https://docs.google.com/document/d/1wHYHhr2BmgOPDl6tCO3fiiLyV_WOQQ-nL8IomxcP1FM/edit)
3. Internal project [Slack channel](https://sourcegraph.slack.com/archives/C07EZ2W4U9H)
