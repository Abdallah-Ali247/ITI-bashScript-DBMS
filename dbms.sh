#!/bin/bash

# ***********************************************
# ******************* db dir ********************
# ***********************************************

DB_DIR="databases"

# create db dir if not exist
mkdir -p "$DB_DIR"

# create db
function create_database() {
    
    # store user input at `dbname`
    read -p "Enter database name: " dbname
    #check if `dbname` not empty
    if [[ -z "$dbname" ]]; then
        echo -e "\nError: Database name cannot be empty!"
        return
    fi
    if [[ -d "$DB_DIR/$dbname" ]]; then
        echo -e "\nError: Database '$dbname' already exists!"
    else
        mkdir "$DB_DIR/$dbname"
        echo -e "\nDatabase '$dbname' created successfully."
    fi
}

# ***********************************************
# **************** list all db ******************
# ***********************************************

function list_databases() {
    echo -e "\nAvailable Databases:"
    ls "$DB_DIR"
}

# ***********************************************
# **************** connect to db ****************
# ***********************************************

function connect_database() {
    # store user input at `dbname`
    read -p "Enter database name to connect: " dbname
    # check if db is exist dir
    if [[ -d "$DB_DIR/$dbname" ]]; then
        echo -e "\nConnected to database '$dbname'."
        database_menu "$dbname"
    else
        echo -e "\nError: Database '$dbname' does not exist!"
    fi
}

# **************************************************
# ******************** drop db *********************
# **************************************************

function drop_database() {
    # store user input at `dbname`
    echo -e "\n"
    read -p "Enter database name to delete: " dbname
    # check if `dbname` is a dir
    if [[ -d "$DB_DIR/$dbname" ]]; then

        read -p "Are you sure you want to delete '$dbname'? (y/n): " confirm

        if [[ "$confirm" == "y" ]]; then
            rm -r "$DB_DIR/$dbname"
            echo -e "\nDatabase '$dbname' deleted successfully."
        else
            echo -e "\nOperation cancelled."
        fi
    else
        echo -e "\nError: Database '$dbname' does not exist!"
    fi
}

# /////////////////////////////////////////////////////
# /////////////////////////////////////////////////////
# /////////////////////////////////////////////////////

# **************************************************
# *************** create a new table ***************
# **************************************************

function create_table() {
    local dbname="$1"
    echo -e "\n"
    read -p "Enter table name: " tablename
    #check if var is not empty
    if [[ -z "$tablename" ]]; then

        echo -e "\nError: Table name cannot be empty!"
        return
    fi
    #check if the file exist
    if [[ -f "$DB_DIR/$dbname/$tablename" ]]; then
        echo -e "\nError: Table '$tablename' already exists!"
        return
    fi

    # Ask for column details
    echo -e "\n"
    read -p "Enter number of columns: " col_count
    if ! [[ "$col_count" =~ ^[1-9][0-9]*$ ]]; then
        echo -e "\nError: Column count must be a positive number!"
        return
    fi

    schema=""
    pk_column=""
    for (( i=1; i<=col_count; i++ )); do
        echo -e "\n"
        read -p "Enter name for column $i: " col_name
        echo -e "\n"
        read -p "Enter data type for column $i (string/int): " col_type
        if [[ "$col_type" != "string" && "$col_type" != "int" ]]; then
            echo -e "\nError: Data type must be 'string' or 'int'!"
            return
        fi

        # Ask if this column is the primary key
        if [[ -z "$pk_column" ]]; then
            echo -e "\n"
            read -p "Should this column be the PRIMARY KEY? (y/n): " is_pk
            if [[ "$is_pk" == "y" ]]; then
                pk_column="$col_name"
            fi
        fi

        schema+="$col_name:$col_type|"
    done

    # Ensure at least one primary key
    if [[ -z "$pk_column" ]]; then
        echo -e "\nError: You must define a primary key!"
        return
    fi

    # Save schema metadata
    schema+="PK:$pk_column"
    echo -e "\n"
    echo "$schema" > "$DB_DIR/$dbname/$tablename.meta"
    touch "$DB_DIR/$dbname/$tablename"  # Create data file
    echo -e "\nTable '$tablename' created successfully with schema."
}

# **************************************************
# **************** list tables in a database *******
# **************************************************

function list_tables() {
    local dbname="$1"
    echo -e "\nTables in database '$dbname':"
    # ls "$DB_DIR/$dbname"
    for table in "$DB_DIR/$dbname"/*.meta; do
        if [[ -f "$table" ]]; then
            tablename=$(basename "$table" .meta)
            schema=$(head -n 1 "$table")
            echo "- $tablename ($schema)"
        fi
    done
}

# ***************************************************
# ******** Function to show table schema ************
# ***************************************************

function show_table_schema() {
    local dbname="$1"
    echo -e "\n"
    read -p "Enter table name: " tablename
    if [[ ! -f "$DB_DIR/$dbname/$tablename.meta" ]]; then
        echo -e "\nError: Table '$tablename' does not exist!"
        return
    fi
    echo -e "\nSchema for table '$tablename':"
    cat "$DB_DIR/$dbname/$tablename.meta"
}

# **************************************************
# ********************* drop table *****************
# **************************************************

function drop_table() {
    local dbname="$1"
    read -p "Enter table name to delete: " tablename
    if [[ -f "$DB_DIR/$dbname/$tablename" ]]; then
        
        read -p "Are you sure you want to delete '$tablename'? (y/n): " confirm
       
        if [[ "$confirm" == "y" ]]; then
            rm "$DB_DIR/$dbname/$tablename"
            rm "$DB_DIR/$dbname/$tablename.meta"

            echo -e "\nTable '$tablename' deleted successfully."
        else
            echo -e "\nOperation cancelled."
        fi
    else
        echo -e "\nError: Table '$tablename' does not exist!"
    fi
}


# *********************************************************
# ******** Function to insert data into a table ***********
# *********************************************************

function insert_into_table() {
    local dbname="$1"
    echo -e "\n"
    read -p "Enter table name: " tablename

    local table_file="$DB_DIR/$dbname/$tablename"
    local schema_file="$table_file.meta"

    if [[ ! -f "$table_file" || ! -f "$schema_file" ]]; then
        echo -e "\nError: Table '$tablename' does not exist!"
        return
    fi

    # Read schema
    schema=$(head -n 1 "$schema_file")
    IFS='|' read -ra columns <<< "$schema"

    declare -A row_data
    pk_column=""
    pk_value=""

    # Read input values
    for col_def in "${columns[@]}"; do
        IFS=':' read -r col_name col_type <<< "$col_def"

        if [[ "$col_name" == "PK" ]]; then
            pk_column="$col_type"
            continue
        fi

        echo -e "\n"
        read -p "Enter value for $col_name ($col_type): " value

        # Validate data type
        if [[ "$col_type" == "int" && ! "$value" =~ ^[0-9]+$ ]]; then
            echo -e "\nError: '$col_name' must be an integer!"
            return
        fi

        # Store value
        row_data["$col_name"]="$value"

        # Check if it's the primary key
        if [[ "$col_name" == "$pk_column" ]]; then
            pk_value="$value"
        fi
    done

    # Check for duplicate primary key
    if grep -q "^$pk_value|" "$table_file"; then
        echo -e "\nError: Primary key '$pk_value' already exists!"
        return
    fi

    # Construct row string
    row=""
    for col_def in "${columns[@]}"; do
        IFS=':' read -r col_name _ <<< "$col_def"
        [[ "$col_name" == "PK" ]] && continue
        row+="${row_data[$col_name]}|"
    done

    # Save row
    echo "${row%|}" >> "$table_file"
    echo -e "\nRow inserted successfully."
}

# **********************************************************
# Function to select and display data from a table *******
# **********************************************************

function select_from_table() {
    local dbname="$1"
    read -p "Enter table name: " tablename

    local table_file="$DB_DIR/$dbname/$tablename"
    local schema_file="$table_file.meta"

    if [[ ! -f "$table_file" || ! -f "$schema_file" ]]; then
        echo "Error: Table '$tablename' does not exist!"
        return
    fi

    # Read schema
    schema=$(head -n 1 "$schema_file")
    IFS='|' read -ra columns <<< "$schema"


    declare -a col_names
    for col_def in "${columns[@]}"; do
        IFS=':' read -r col_name _ <<< "$col_def"
        [[ "$col_name" == "PK" ]] && continue
        col_names+=("$col_name")
    done

    # Print table header
    echo "--------------------------------------------------------------"
    for col_name in "${col_names[@]}"; do
        printf "%-15s" "$col_name"
    done
    echo
    echo "--------------------------------------------------------------"

    # Print rows
    while IFS='|' read -r row_data; do
        IFS='|' read -ra values <<< "$row_data"
        for value in "${values[@]}"; do
            printf "%-15s" "$value"
        done
        echo
    done < "$table_file"

    echo "--------------------------------------------------------------"
}


# **************************************************
# ****************** Database Menu Function ********
# **************************************************

function database_menu() {
    local dbname="$1"
    while true; do
        clear
        echo "========================="
        echo "  Database: $dbname  "
        echo "========================="
        echo "1) Create Table"
        echo "2) List Tables"
        echo "3) Show Table Schema"
        echo "4) Insert into Table"
        echo "5) Select From Table"
        echo "6) Drop Table"
        echo "7) Back to Main Menu"
        echo "========================="
        read -p "Enter your choice: " choice

        case $choice in
            1) create_table "$dbname" ;;
            2) list_tables "$dbname" ;;
            3) show_table_schema "$dbname" ;;
            4) insert_into_table "$dbname" ;;
            5) select_from_table "$dbname" ;;
            6) drop_table "$dbname" ;;
            7) return ;;
            *) echo "Invalid option. Please try again." ;;
        esac

        echo -e "\n"
        read -p "Press Enter to continue..."
    done
}







# **************************************************************************************
# ********************************* Main Menu Function *********************************
# **************************************************************************************

function main_menu() {
    while true; do
        clear
        echo "========================="
        echo "  Bash DBMS Main Menu   "
        echo "========================="
        echo "1) Create Database"
        echo "2) List Databases"
        echo "3) Connect to Database"
        echo "4) Drop Database"
        echo "5) Exit"
        echo -e "=========================\n"
        read -p "Enter your choice: " choice

        case $choice in
            1) create_database ;;
            2) list_databases ;;
            3) connect_database ;;
            4) drop_database ;;
            5) echo -e "\nExiting..."; exit 0 ;;
            *) echo -e "\nInvalid option. Please try again." ;;
        esac

        echo -e "\n"
        read -p "Press Enter to continue..."
    done
}

# Run the main menu
main_menu
