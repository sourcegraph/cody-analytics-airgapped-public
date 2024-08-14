#!/bin/bash

# File paths
sql_queries_directory="$(pwd)"
output_file="$0-output.txt"
cody_events_list_file="cody-events-list"
cody_events_list_content="$(cat "$cody_events_list_file")"

# Any match of the $cody_events_list_file_insert_marker string
# will be replaced with the contents of the $cody_events_list_file
cody_events_list_file_insert_marker="--cody-events-list-gets-inserted-here"

# Define log function for consistent output format
function log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

## Script start
script_start_time_seconds="$(date +%s)"
log "$0 Started"

# Determine if we need to run these SQL commands either
# direct through an open tunnel to the postgres database
# or via kubectl
command_prefix=""
if [ "$1" == "psql" ]
then

    # psql mode
    command_prefix="psql -h $2 -p $3 -d $4 -U $5 "

    if ! $command_prefix -c 'SELECT 1;' &> /dev/null
    then

        log "Failed to connect to database, ensure your tunnel is connected."
        exit 1

    fi

else

    # kubectl mode
    pgsql_pod_name=$(kubectl get pod -l app=pgsql -o jsonpath="{.items[0].metadata.name}")

    if [ -z "${pgsql_pod_name}" ]
    then
        log "kubectl get pod -l app=pgsql failed, ensure your kubectl is authenticated and configured to your Sourcegraph cluster."
        exit 2
    fi

    command_prefix="kubectl exec -i $pgsql_pod_name -- psql -U sg "

fi

# Create / clear output file
> "$output_file"

# Loop through all .sql files in the $sql_queries_directory
for query_file in "$sql_queries_directory"/*.sql
do

    query_file_base_name="$(basename "$query_file")"
    query_start_time_seconds="$(date +%s)"

    # Let the user know we've found the .sql file and we're processing it
    log "$query_file_base_name Started"

    # Write the .sql file's name (without the full file path) to the output file
    echo $query_file_base_name >> "$output_file"

    # Read the contents of the .sql file into a variable
    query_file_content="$(cat "$query_file")"

    # Replace the insert marker with the contents of the $cody_events_list_file
    query="${query_file_content/$cody_events_list_file_insert_marker/$cody_events_list_content}"

    # Execute the command with the query
    # Warning: This formatting is brittle
    echo "$($command_prefix \
<< EOF
$query
EOF
        )
        " >> "$output_file"

    # Leht the user know the query has finished, and how long it took
    log "$query_file_base_name Finished with runtime: $(($(date +%s) - $query_start_time_seconds)) seconds"

done

# Let the user know we've finished the script
log "$0 Finished with runtime: $(($(date +%s) - $script_start_time_seconds)) seconds"
