#!/bin/bash
#
# Grading tests for Exercise 2
#
# set -e

# declare which files to use
QUERYFILE=12-Exercise2.sql
FEEDBACK_FILE=exercise2.md

NUMBER_OF_TASKS_IN_EXERCISE=1

# import common functions and var
. ./"`dirname \"$0\"`"/common.sh

test_table_number_rows () {
    # arguments
    # $1 task number
    # $2 table name
    # $3 number of rows expected

    task=$1
    table=$2
    num_rows=$3

    feedback_msg="Task $task Populate Table: "

    _check_query_file_exists "$feedback_msg"
    _check_database_exists "$feedback_msg"

    rows=$(sqlcmd -S 127.0.0.1 -U sa -P $DBPASS -d $DBNAME -Q "SELECT * FROM dbo.$table" | tail -n 1)
    if [[ $rows == "($num_rows rows affected)" ]]; then
        echo "Correct number of rows in table"
        echo "pass"
        feedback_msg=$PASS_CHAR"$feedback_msg Correct number of rows in table. Test pass."
        status=0
    else
        echo "\"$table\" has an incorrect number of rows"
        feedback_msg=$FAIL_CHAR"$feedback_msg \"$table\" has an incorrect number of rows. Test fail."
        status=1
    fi

    _write_feedback_msg_to_file "$feedback_msg"
    exit $status
}

test_table_row_populated () {
    # test values in table correct. test values read from csv file
    # arguments
    # $1 task number
    # $2 table
    # $3 row pk

    task=$1
    table=$2
    row_pk=$3

    r=()
    status=1

    # read data file into array
    mapfile -t data_array < $DATADIR$table.csv

    # get columns from first line
    IFS=',' read -r -a columns <<< ${data_array[0]}

    pk_column_name=${columns[0]}

    feedback_msg="Task $task Populate $table Table: Checking values for $pk_column_name = $row.  \n"

    _check_query_file_exists "$feedback_msg$TABSPACE$TABSPACE"
    _check_database_exists "$feedback_msg$TABSPACE$TABSPACE"
    _check_table_exists $table "$feedback_msg$TABSPACE$TABSPACE"

    for row in "${data_array[@]}"
    do
        row=${row//\'/} # strip quotes

        # read row into array
        IFS=',' read -r -a row_data <<< ${row}

        if [[ ${row_data[0]} == "$row_pk" ]]; then
            r=(${row_data[@]})
            status=0
            break
        fi
    done

    # check row PK found; programming error
    if [[ $status == 1 ]]; then
        echo "programmer error: row PK not found"
        exit 1
    fi

    echo "Checking values for $pk_column_name = $row_pk"

    rows=$(sqlcmd -S 127.0.0.1 -U sa -P $DBPASS -d $DBNAME -Q "SELECT $pk_column_name FROM dbo.$table WHERE $pk_column_name=\"$row_pk\"" | tail -n 1)
    if [[ $rows == "(0 rows affected)" ]]; then
        echo "$pk_column_name $row_pk not found"
        feedback_msg=$FAIL_CHAR"$feedback_msg""$TABSPACE$TABSPACE""$pk_column_name $row_pk not found. Test fail."
        _write_feedback_msg_to_file "$feedback_msg"
        exit 1
    fi

    # check each value in row
    i=0
    for c in ${columns[@]}; do
        QUERY="SELECT $c FROM dbo.$table WHERE $pk_column_name=\"$row_pk\""
        result=$(sqlcmd -S 127.0.0.1 -U sa -P $DBPASS -d $DBNAME -Q "$QUERY" | head -n 3 | tail -n 1 | xargs)
        expected=${r[$i]}

        if [[ $result == $expected ]]; then
            echo "    \"$c\" entered correctly: $result"
            feedback_msg+="$TABSPACE$TABSPACE\"$c\" entered correctly: $result  \n"
        else
            echo "    Value of \"$c\" entered incorrectly"
            feedback_msg+="$TABSPACE$TABSPACEValue of \"$c\" entered incorrectly  \n"
            status=1
        fi
        ((++i))
    done

    # summary
    if [[ $status == 0 ]]; then
        echo "All values for $pk_column_name = $row_pk entered correctly"
        echo "pass"
        feedback_msg+=$TABSPACE"All values for $pk_column_name = $row_pk entered correctly. Test pass."
        feedback_msg=$PASS_CHAR"$feedback_msg"
    else
        echo "Some values entered incorrectly"
        feedback_msg+=$TABSPACE"Some values entered incorrectly. Test Fail."
        feedback_msg=$FAIL_CHAR"$feedback_msg"
    fi

    _write_feedback_msg_to_file "$feedback_msg"
    exit $status
}

test_function () {
    # test function for specific test
    # arguments
    # $1 param
    # $2 param

    feedback_msg="Task 1: "

    # check certain conditions before running test
    _check_query_file_exists "$feedback_msg"
    _check_database_exists "$feedback_msg"
    _check_query_file_runs "$feedback_msg"

    # run test code here
    $test=0
    # replace $test with test condition in if
    if [[ $test ]]; then
        echo "Feedback in workflow log"
        echo "pass"
        feedback_msg=$PASS_CHAR"$feedback_msg Feedback in PR comment. Test pass."
        status=0
    else
        echo "Feedback in workflow log"
        feedback_msg=$FAIL_CHAR"$feedback_msg Feedback in PR comment. Test fail."
        status=1
    fi

    _write_feedback_msg_to_file "$feedback_msg"
    exit $status
}

"$@"
