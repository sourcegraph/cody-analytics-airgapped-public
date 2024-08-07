#!/bin/bash

# File paths
sql_queries_directory="$(pwd)"
output_file="$0-output.txt"
cody_events_list_file="cody-events-list"
cody_events_list_content="$(cat "$cody_events_list_file")"

# Any line in the .sql files containing $cody_events_list_file_insert_marker
# will be replaced with the contents of the $cody_events_list_file
cody_events_list_file_insert_marker="--cody-events-list-gets-inserted-here"

## Script start
echo "Starting $0"

pgsql_pod_name=$(kubectl get pod -l app=pgsql -o jsonpath="{.items[0].metadata.name}")

# Create / clear output file
> "$output_file"

# Loop through all .sql files in the $sql_queries_directory
for query_file in "$sql_queries_directory"/*.sql
do

    query_file_base_name="$(basename "$query_file")"

    # Let the user know we've found the .sql file and we're processing it
    echo "Running SQL query from $query_file_base_name"

    # Write the .sql file's name (without the full file path) to the output file
    echo $query_file_base_name >> "$output_file"

    # Read the contents of the .sql file into a variable
    query_file_content="$(cat "$query_file")"

    # Replace the insert marker with the contents of the $cody_events_list_file
    query="${query_file_content/$cody_events_list_file_insert_marker/$cody_events_list_content}"

    # Execute the psql command, inside a kubectl exec command, using the $query_file_content variable as the query
    echo "$(kubectl exec    \
        -i                  \
        $pgsql_pod_name     \
        --                  \
        psql                \
        -U sg               \
<< EOF
$query
EOF
        )
        "                   \
        >> "$output_file"

done

# Let the user know we've finished the script
echo "Finishing $0"
