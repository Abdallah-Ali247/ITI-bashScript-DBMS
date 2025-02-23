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
        # Placeholder for database menu (to be implemented next)
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
