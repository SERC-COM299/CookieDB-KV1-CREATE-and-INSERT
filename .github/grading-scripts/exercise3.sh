#!/bin/bash
#
# Grading tests for Exercise 3
#
# set -e

# declare which files to use
QUERYFILE=13-Exercise3.sql
FEEDBACK_FILE=exercise3.md

NUMBER_OF_TASKS_IN_EXERCISE=2

# import common functions and var
. ./"`dirname \"$0\"`"/common.sh

test_table_contents_query () {

    table=Products

    feedback_msg="Task 1 Return Table Contents: "

    _check_query_file_exists "$feedback_msg"
    _check_database_exists "$feedback_msg"
    _check_table_exists $table "$feedback_msg"
    _check_query_file_runs "$feedback_msg"

    query="SELECT * FROM dbo.$table"
    result=$(sqlcmd -S 127.0.0.1 -U sa -P $DBPASS -d $DBNAME -i "$QUERYFILE" | head -n 11)
    expected=$(sqlcmd -S 127.0.0.1 -U sa -P $DBPASS -d $DBNAME -Q "$query")

    # check file generates expected query
    if [[ $result == *"$expected"* ]]; then
        echo "Query found that shows table contents"
        echo "pass"
        feedback_msg=$PASS_CHAR"$feedback_msg Query found that shows table contents. Test pass."
        status=0
    else
        echo "Query in $QUERYFILE does not show table contents as expected."
        echo "Are the columns in the same order as given in the instructions?"
        feedback_msg=$FAIL_CHAR"$feedback_msg Query in $QUERYFILE does not show table contents as expected. Test fail."
        feedback_msg+="  \n$TABSPACE Are the columns in the same order as given in the instructions?"
        status=1
    fi

    _write_feedback_msg_to_file "$feedback_msg"
    exit $status
}

test_table_contents_query_ordered () {

    table=Products

    feedback_msg="Task 2 Return Table Contents Numerically Ordered: "

    _check_query_file_exists "$feedback_msg"
    _check_database_exists "$feedback_msg"
    _check_table_exists $table "$feedback_msg"
    _check_query_file_runs "$feedback_msg"

    query="SELECT cookieID, cookieName, description, price FROM dbo.$table ORDER BY $table.price"
    result=$(sqlcmd -S 127.0.0.1 -U sa -P $DBPASS -d $DBNAME -i "$QUERYFILE" | tail -n 10)
    expected=$(sqlcmd -S 127.0.0.1 -U sa -P $DBPASS -d $DBNAME -Q "$query")

    # check file generates expected query
    if [[ $result == *"$expected"* ]]; then
        echo "Query found that shows table contents in numerical order"
        echo "pass"
        feedback_msg=$PASS_CHAR"$feedback_msg Query found that shows table contents in alphabetical order. Test pass."
        status=0
    else
        echo "Query in $QUERYFILE does not show table contents as expected."
        echo "Are the columns in the same order as given in the instructions?"
        echo "Are the results ordered numerically by last name?"
        feedback_msg=$FAIL_CHAR"$feedback_msg Query in $QUERYFILE does not show table contents as expected. Test fail."
        feedback_msg+="  \n$TABSPACE Are the columns in the same order as given in the instructions?"
        feedback_msg+="  \n$TABSPACE Are the results ordered numerically by last name?"
        status=1
    fi

    _write_feedback_msg_to_file "$feedback_msg"
    exit $status
}

"$@"
