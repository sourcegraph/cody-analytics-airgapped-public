#!/bin/bash

## Global variables

# Configure these for your psql client
hostname="localhost" # localhost if using proxy tunnelling
port="5433"
database="pgsql"
username="src-c7169e025021d705@src-747bc765eb31a4873e4b.iam"
password="" # If using password authentication to the database

# File paths
sql_queries_directory="$(pwd)"
output_file="$0-output.txt"
#output_file="$0-output-$(date +%Y-%m-%d-%H-%M-%S).txt"
cody_events_list_file="cody-events-list"
cody_events_list_content="$(cat "$cody_events_list_file")"

# Any line in the .sql files containing $cody_events_list_file_insert_marker
# will be replaced with the contents of the $cody_events_list_file
cody_events_list_file_insert_marker="--cody-events-list-gets-inserted-here"

# Leave these alone
OLD_PGPASSFILE=""
date_format="'%Y-%m-%d %H:%M:%S'"

## Functions

# Define the cleanup function here, to be called when the script ends
function cleanup_password_file() {

    if [[ -n "$password" ]]
    then
        # Delete the temporary credential file
        rm -fv $PGPASSFILE

        # If the user's shell context already had the PGPASSFILE environment variable set, then reset it to its original value
        if [[ -n "$OLD_PGPASSFILE" ]]
        then
            PGPASSFILE="$OLD_PGPASSFILE"
            export PGPASSFILE
            echo "Restored PGPASSFILE environment variable to: $PGPASSFILE"
        fi
    fi
}


## Script start
start_time="$(date +"$date_format")"
echo "Starting $0 at $start_time"

start_time_seconds="$(date +%s)"

# If you use a password to authenticate to your database, then store database connection information in a PGPASSFILE
if [[ -n "$password" ]]
then

    # If the user's shell context already has the PGPASSFILE environment variable set, then capture its value
    if [[ -n "$PGPASSFILE" ]]
    then
        echo "PGPASSFILE environment variable previously set to: $PGPASSFILE, capturing it to restore later"
        OLD_PGPASSFILE="$PGPASSFILE"

    fi

    # Give temp file a unique name to avoid collisions
    PGPASSFILE=/tmp/sg_cody_analytics_pgpasswd

    # Define the trap here, between configuring PGPASSFILE, and creating the file,
    # So that we're not deleting their previously defined PGPASSFILE
    # And we ensure that ours is deleted
    trap cleanup_password_file EXIT

    # Create the temporary credential file
    touch $PGPASSFILE

    # Set the file's permissions
    chmod 600 $PGPASSFILE

    # Write the database connection information to the temporary credential file
    echo "$hostname:$port:$database:$username:$password" > $PGPASSFILE

    # Set the PGPASSFILE environment variable to the temporary credential file
    # for the psql client to use
    export PGPASSFILE

    # Write the PGPASSFILE path to the console for user verification
    echo "PGPASSFILE path: $PGPASSFILE"

    # For troubleshooting
    # echo "PGPASSFILE contents:"
    # cat $PGPASSFILE
fi

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

    # Execute the psql command, using the $query_file_content variable as the query
    echo "$(psql \
        -h "$hostname" \
        -p "$port" \
        -d "$database" \
        -U "$username" \
<< EOF
$query
EOF
        )
        " \
        >> "$output_file"

done


# Let the user know we've finished the script
end_time="$(date +"$date_format")"
echo "Finishing $0 at $end_time"
end_time_seconds="$(date +%s)"
script_runtime_seconds="$(($end_time_seconds - $start_time_seconds))"
echo "Script runtime: $script_runtime_seconds seconds"
