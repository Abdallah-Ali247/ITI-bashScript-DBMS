#!/bin/bash 

DBMS="databases"
current_DB=""

function main_menu {
    while true; do
        choice=$(zenity --list --title="Main Menu" --text="Choose an option:" --column="Option" "Create Database" "List Databases" "Connect to Database" "Drop Database" --width=400 --height=400)

        case $choice in
            "Create Database") create_database ;;
            "List Databases") list_databases ;;
            "Connect to Database") connect_to_database ;;
            "Drop Database") drop_database ;;
            *) exit 0 ;;
        esac
    done
}

function create_database {
    db_name=$(zenity --entry --title="Create Database" --text="Enter database name:" --width=400 --height=150)
    if [[ -z "$db_name" ]]; then
        zenity --error --text="You must enter DataBase name."
        return
    fi
    if [[ -d "$DBMS/$db_name" ]]; then
        zenity --error --text="Database '$db_name' already exists."
    else
        mkdir -p "$DBMS/$db_name"
        zenity --info --text="Database '$db_name' created successfully."
    fi
}

function list_databases {
    if [[ -d "$DBMS" ]]; then
        databases=$(ls "$DBMS" | grep -vE '\.sh$')
        zenity --list --title="DataBases" --text="Your DataBases:" --column="Database" $databases
    else
        zenity --info --text="No databases exist."
    fi
}

function connect_to_database {
    db_name=$(zenity --entry --title="Connect to Database" --text="Enter database name:" --width=400 --height=150)
    if [[ -z "$db_name" ]]; then 
            zenity --error --text="you must enter DB name!!"
            return
    fi

    if [[ -d "$DBMS/$db_name" ]]; then
        current_DB="$db_name"
        zenity --info --text="Connected to database '$db_name'."
        source "$DBMS/tables.sh" "$current_DB"
    else
        zenity --error --text="Database '$db_name' does not exist."
    fi
}
function drop_database {
    db_name=$(zenity --entry --title="Drop Database" --text="Enter database name:" --width=400 --height=150)
    if [[ -z "$db_name" ]]; then 
	    zenity --error --text="you must enter DB name!!"
	    return
    fi
    if [[ -d "$DBMS/$db_name" ]]; then
	zenity --question --text="Are you sure you want to drop '$db_name'?"    
	if [[ $? -eq 0 ]]; then
		rm -r "$DBMS/$db_name"
		zenity --info --text="Database '$db_name' is dropped."

        else
                zenity --info --text="Operation canceled !!."
        fi

    else
        zenity --error --text="Database '$db_name' does not exist."
    fi
}
main_menu
