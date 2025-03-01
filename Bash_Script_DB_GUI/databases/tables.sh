#!/bin/bash
DBMS="databases"
current_DB=$1

columns_name=() 
columns_type=()
primary_key=""
primary_key_index=0

function table_menu {
    while true; do
        choice=$(zenity --list --title="'$current_DB'" --text="Choose an option:" --column="Option" "Create Table" "List Tables" "Drop Table" "Insert into Table" "Select From Table" "Select All Table" "Delete From Table" "Update Table" "Back to Main Menu" --width=400 --height=400)

        case $choice in
            "Create Table") create_table ;;
            "List Tables") list_tables ;;
            "Drop Table") drop_table ;;
            "Insert into Table") insert_into_table ;;
            "Select From Table") select_from_table ;;
	    "Select All Table") select_all_table ;;
            "Delete From Table") delete_from_table ;;
            "Update Table") update_table ;;
            "Back to Main Menu") break ;;
	    *) exit 0 ;;
            
        esac
    done
}

function create_table {
    table_name=$(zenity --entry --title="Create Table" --text="Enter table name:" --width=400 --height=150)
    if [[ -z "$table_name" ]]; then
        zenity --error --text="you must write table name."
        return
    fi
    if [[ -f "$DBMS/$current_DB/$table_name" ]]; then
        zenity --error --text="Table '$table_name' already exists."
    else
        columns=$(zenity --entry --title="Create Table" --text="Enter columns lik(col1:type1;col2:type2;..)" --width=400 --height=150)
        primary_key=$(zenity --entry --title="Create Table" --text="Enter primary key column:" --width=400 --height=150)
        echo "$columns|$primary_key" > "$DBMS/$current_DB/$table_name"
	chmod +rwx "$DBMS/$current_DB/$table_name"
        zenity --info --text="Table '$table_name' created successfully."
    fi
}

function list_tables {
	tables=$(ls "$DBMS/$current_DB")
        if [[ -z "$tables" ]]; then 
		zenity --error --text="there is no tables."
		return
	fi
	zenity --list --title="Tables" --text="List of tables:" --column="Table" $(echo "$tables")

}

function drop_table {
    table_name=$(zenity --entry --title="Drop Table" --text="Enter table name:" --width=400 --height=150)
    if [[ -z "$table_name" ]]; then
        zenity --error --text="you must write table name."
        return
    fi

    if [[ -f "$DBMS/$current_DB/$table_name" ]]; then
	    zenity --question --title="Confirm Deletion" --text="Are you sure you want to drop table '$table_name'?"
        
            if [[ $? -eq 0 ]]; then 
            	rm "$DBMS/$current_DB/$table_name"
            	zenity --info --text="Table '$table_name' dropped successfully."
            else
            	zenity --info --text="Operation canceled !!."
	    fi
    else
        zenity --error --text="Table '$table_name' does not exist."
    fi
}

function table_metadata {
    table_name=$1
    first_line=$(head -n 1 "$DBMS/$current_DB/$table_name")
    columns=$(echo "$first_line" | cut -d'|' -f1)
    primary_key=$(echo "$first_line" | cut -d'|' -f2)

    columns_name=()
    columns_type=()

    mapfile -t raw < <(echo "$columns" | awk -F';' '{
        for (i=1; i<=NF; i++) {
            split($i, arr, ":")
            print arr[1]  
            print arr[2]  
        }
    }')
    for ((i=0; i<${#raw[@]}; i+=2)); do
        columns_name+=("${raw[i]}")
        columns_type+=("${raw[i+1]}")
    done
    get_pk_index
}

function get_pk_index {
    primary_key_index=0
    for i in "${!columns_name[@]}"; do
        if [[ "${columns_name[$i]}" == "$primary_key" ]]; then
            primary_key_index="$i"
            return
        fi
    done
}

function validate_type {

        value=$1
        col_type=$2
        col_name=$3
        case "$col_type" in
            int)
                if ! [[ "$value" =~ ^[0-9]+$ ]]; then
                    zenity --error --text="Error: Column '$col_name' requires an INTEGER value!"
                    return 1
                fi
                ;;
            float)
                if ! [[ "$value" =~ ^[0-9]+(\.[0-9]+)?$ ]]; then
                    zenity --error --text="Error: Column '$col_name' requires a FLOAT value!"
                    return 1
                fi
                ;;
            varchar)
                if ! [[ "$value" =~ ^[a-zA-Z][a-zA-Z0-9]+$ ]]; then
                    zenity --error --text="Error: Column '$col_name' requires a STRING value!"
                    return 1
                fi
                ;;
                *)
                        zenity --error --text="Error: Unknown data type for column '$col_name' !"
                        return 1
                ;;
        esac
    return 0
}

function select_from_table {
        table_name=$(zenity --entry --title="select from table" --text="Enter the table name" --width=400 --height=150)

        if [[ -z "$table_name" ]]; then
                zenity --error --text="You must write a table name"
                return
        fi

        if [[ -f "$DBMS/$current_DB/$table_name" ]]; then
                table_metadata "$table_name"
                value=$(zenity --entry --title="select from Table" --text="Ente the value to select the row." --width=300 --height=150)
                if [[ -z "$value" ]]; then 
                        zenity --error --text="You must write the value to select."
                        return
                fi

        
                if grep -q "$value" "$DBMS/$current_DB/$table_name"; then
                        line=$(sed -n "/$value/ p" "$DBMS/$current_DB/$table_name")
                        zenity_command="zenity --list --title=\"$table_name\""
                        for col in "${columns_name[@]}"; do
                                zenity_command+=" --column=\"$col\""
                        done
                        row=($(echo "$line" | awk -F';' '{for (i=1; i<=NF; i++) print $i}'))
                        for e in "${row[@]}"; do
                                zenity_command+=" \"$e\""
                        done
			zenity_comand+=" --width=300 --height=250"
                        eval "$zenity_command"
                else 
                zenity --error --text="this value not Exist"

                fi
        fi   
}
function select_all_table {

        table_name=$(zenity --entry --title="Delete from Table" --text="Enter the table name" --width=400 --height=150)

        if [[ -z "$table_name" ]]; then
                zenity --error --text="You must write a table name"
                return
        fi

        if [[ -f "$DBMS/$current_DB/$table_name" ]]; then
                table_metadata "$table_name"
                zenity_command="zenity --list --title="'$tablee_name'""
                for col in "${columns_name[@]}"; do
                        zenity_command+=" --column='$col'"
                done
		lines=$(tail -n +2 "$DBMS/$current_DB/$table_name")
		raw=($(echo "$lines" | awk -F';' '{for (i=1; i<=NF; i++) print $i}'))
                for e in "${raw[@]}"; do
			zenity_command+=" \"$e\""
		done
		zenity_command+=" --width=300 --height=300"

                eval "$zenity_command"

        else
                zenity --error --text="'$tablename' is not Exist !!"

        fi

}
function delete_from_table {

	table_name=$(zenity --entry --title="Delete from Table" --text="Enter the table name" --width=400 --height=150)

        if [[ -z "$table_name" ]]; then
                zenity --error --text="You must write a table name"
                return
        fi

        if [[ ! -f "$DBMS/$current_DB/$table_name" ]]; then
		zenity --error --text="The value not found."
		return
	fi
	value=$(zenity --entry --title="Delete From Table" --text="Enter value to delete:" --width=400 --height=150)
    	if grep -q "$value" "$DBMS/$current_DB/$table_name"; then
		zenity --question --title="Confirm Deletion" --text="Are you sure you want to delete this raw ?"
		if [[ $? -eq 0 ]]; then
			sed -i "/$value/d" "$DBMS/$current_DB/$table_name"
			zenity --info --text="Row deleted."
        	else
                	zenity --info --text="Operation canceled !!."
        	fi
	else 
		zenity --error --text="the value is not Exist !!"
	fi
}

function insert_into_table {
        table_name=$(zenity --entry --title="Insert into Table" --text="Enter the table name " --width=400 --height=150)
        if [[ -z "$table_name" ]]; then
                zenity --error --text="You must whrite table name"
                return
        fi

        if [[ -f "$DBMS/$current_DB/$table_name" ]]; then
                table_metadata "$table_name"
                form_fields=()
                for col in "${columns_name[@]}"; do
                        form_fields+=("--add-entry=$col")
                done

                line=$(zenity --forms --title="Insert Data" --text="Enter the values:" "${form_fields[@]}" --separator=";" --width=300 --height=300)

		raw=($(echo "$line" | awk -F';' '{for (i=1; i<=NF; i++) print $i}'))
		if [[ -z "$raw" ]]; then
                        zenity --error --text="No data entered!"
                        return
                fi
		
		pk_value="${raw["$primary_key_index"]}"
		if grep -q "^$pk_value" "$DBMS/$current_DB/$table_name"; then
            		zenity --error --text="Primary Key '$pk_value' already exists!"
			return
        	fi
		for i in  "${!raw[@]}"; do 
			val="${raw[$i]}"
			if ! validate_type "$val" "${columns_type[$i]}" "${columns_name[$i]}"; then
				return 
			fi
			
		done
		echo "$line" >> "$DBMS/$current_DB/$table_name"
                zenity --info --text="Row inserted successfully."
        else
                zenity --error --text="'$table_name' is not Exist !!"           
        fi
} 
function update_table {
    table_name=$(zenity --entry --title="Update Table" --text="Enter the table name " --width=400 --height=150)
    if [[ -z "$table_name" ]]; then 
        zenity --error --text="You must write the table name"
        return
    fi

    if [[ -f "$DBMS/$current_DB/$table_name" ]]; then
        old_value=$(zenity --entry --title="Update Table" --text="Enter the value to update." --width=400 --height=150)
        if [[ -z "$old_value" ]]; then 
            zenity --error --text="You must write the value to update."
            return
        fi

        old_row=$(grep "$old_value;" "$DBMS/$current_DB/$table_name")
        if [[ -z "$old_row" ]]; then
            zenity --error --text="Value '$old_value' not found in table."
            return
        fi

        old_row_array=($(echo "$old_row" | awk -F';' '{for (i=1; i<=NF; i++) print $i}'))

        table_metadata "$table_name" 
        old_pk_value="${old_row_array[$primary_key_index]}"


        form_fields=()
        for col in "${columns_name[@]}"; do
            form_fields+=("--add-entry=$col")
        done

        values=$(zenity --forms --title="Update Data" --text="Enter the new values:" "${form_fields[@]}" --separator=";" --width=500 --height=400)

        
        row=($(echo "$values" | awk -F';' '{for (i=1; i<=NF; i++) print $i}'))
        pk_value="${row[$primary_key_index]}"

        if [[ "$old_pk_value" != "$pk_value" ]] && grep -q "^$pk_value;" "$DBMS/$current_DB/$table_name"; then
            zenity --error --text="Primary Key '$pk_value' already exists!"
            return
        fi

        safe_old_row=$(echo "$old_row" | sed 's|[\/&]|\\&|g')

	safe_values=$(echo "$values" | sed 's|[\/&]|\\&|g')

	sed -i "s|$safe_old_row|$safe_values|" "$DBMS/$current_DB/$table_name" 

        zenity --info --text="Row updated successfully."

    else 
        zenity --error --text="'$table_name' does not exist!"
    fi
}
table_menu
