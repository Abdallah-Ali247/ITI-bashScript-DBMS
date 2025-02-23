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


# create a new table
function create_table() {
    local dbname="$1"
    read -p "Enter table name: " tablename
    #check if var is not empty
    if [[ -z "$tablename" ]]; then

        echo -e "\nError: Table name cannot be empty!"
        return
    fi
    #check if the file exist
    if [[ -f "$DB_DIR/$dbname/$tablename" ]]; then
        echo -e "\nError: Table '$tablename' already exists!"
    else
        touch "$DB_DIR/$dbname/$tablename"
        echo -e "\nTable '$tablename' created successfully."
    fi
}

# list tables in a database
function list_tables() {
    local dbname="$1"
    echo -e "\nTables in database '$dbname':"
    ls "$DB_DIR/$dbname"
}

# drop table
function drop_table() {
    local dbname="$1"
    read -p "Enter table name to delete: " tablename
    if [[ -f "$DB_DIR/$dbname/$tablename" ]]; then
        
        read -p "Are you sure you want to delete '$tablename'? (y/n): " confirm
       
        if [[ "$confirm" == "y" ]]; then
            rm "$DB_DIR/$dbname/$tablename"
            echo -e "\nTable '$tablename' deleted successfully."
        else
            echo -e "\nOperation cancelled."
        fi
    else
        echo -e "\nError: Table '$tablename' does not exist!"
    fi
}


# Database Menu Function
function database_menu() {
    local dbname="$1"
    while true; do
        clear
        echo "========================="
        echo "  Database: $dbname  "
        echo "========================="
        echo "1) Create Table"
        echo "2) List Tables"
        echo "3) Drop Table"
        echo "4) Back to Main Menu"
        echo "========================="
        read -p "Enter your choice: " choice

        case $choice in
            1) create_table "$dbname" ;;
            2) list_tables "$dbname" ;;
            3) drop_table "$dbname" ;;
            4) return ;;
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
