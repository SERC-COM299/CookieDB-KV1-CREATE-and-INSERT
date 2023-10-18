#!/bin/bash
#
# Grading tests for Exercise 1
#
# set -e

# declare which files to use
QUERYFILE=11-Exercise1.sql
FEEDBACK_FILE=exercise1.md

NUMBER_OF_TASKS_IN_EXERCISE=2

# import common functions and var
. ./"`dirname \"$0\"`"/common.sh

test_database_created () {
    # arguments
    # $1 task number

    task=$1

    feedback_msg="Task $task Create Database: "

    # check certain conditions before running test
    _check_query_file_exists "$feedback_msg"

    result=$(sqlcmd -S 127.0.0.1 -U sa -P $DBPASS -Q "SELECT NAME FROM sys.sysdatabases")

    if [[ $result == *"$DBNAME"* ]]; then
        echo "Database successfully created"
        echo "pass"
        feedback_msg=$PASS_CHAR"$feedback_msg Database successfully created. Test pass."
        status=0
    else
        echo "Database not found"
        feedback_msg=$FAIL_CHAR"$feedback_msg Database not found. Test fail."
        status=1
    fi

    _write_feedback_msg_to_file "$feedback_msg"
    exit $status
}

test_table_created () {
    # arguments
    # $1 task number
    # $2 table name

    task=$1
    table=$2

    feedback_msg="Task $task Create Table: "

    # check certain conditions before running test
    _check_query_file_exists "$feedback_msg"
    _check_database_exists "$feedback_msg"

    QUERY="SELECT TABLE_NAME FROM $DBNAME.INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE = 'BASE TABLE'"
    result=$(sqlcmd -S 127.0.0.1 -U sa -P $DBPASS -Q "$QUERY")

    if [[ $result == *"$table"* ]]; then
        echo "Table \"$table\" successfully created"
        echo "pass"
        feedback_msg=$PASS_CHAR"$feedback_msg \"$table\" successfully created. Test pass."
        status=0
    else
        echo "\"$table\" table not found"
        feedback_msg=$FAIL_CHAR"$feedback_msg \"$table\" table not found. Test fail."
        status=1
    fi

    _write_feedback_msg_to_file "$feedback_msg"
    exit $status
}

test_column_exists() {
    # arguments
    # $1 task number
    # $2 table name
    # $3 column name

    task=$1
    table=$2
    expected=$3

    feedback_msg="Task $task Create Table - Columns: "

    # check certain conditions before running test
    _check_query_file_exists "$feedback_msg"
    _check_database_exists "$feedback_msg"
    _check_table_exists $table "$feedback_msg"

    QUERY="USE $DBNAME SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = '$table' AND TABLE_SCHEMA='dbo'"
    result=$(sqlcmd -S 127.0.0.1 -U sa -P $DBPASS -Q "$QUERY")

    if [[ $result == *"$expected"* ]]; then
        echo "$expected successfully added"
        echo "pass"
        feedback_msg=$PASS_CHAR"$feedback_msg \"$expected\" successfully added. Test pass."
        status=0
    else
        echo "$expected column not found in table. Test fail."
        feedback_msg=$FAIL_CHAR"$feedback_msg \"$expected\" column not found in table. Test fail."
        status=1
    fi

    _write_feedback_msg_to_file "$feedback_msg"
    exit $status
}

test_column_not_exists() {
    # arguments
    # $1 task number
    # $2 table name
    # $3 column name

    task=$1
    table=$2
    expected=$3

    feedback_msg="Task $task Create Table - Columns: "

    # check certain conditions before running test
    _check_query_file_exists "$feedback_msg"
    _check_database_exists "$feedback_msg"
    _check_table_exists $table "$feedback_msg"

    QUERY="USE $DBNAME SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = '$table' AND TABLE_SCHEMA='dbo'"
    result=$(sqlcmd -S 127.0.0.1 -U sa -P $DBPASS -Q "$QUERY")

    if [[ $result != *"$expected"* ]]; then
        echo "$expected successfully removed"
        echo "pass"
        feedback_msg=$PASS_CHAR"$feedback_msg \"$expected\" successfully removed. Test pass."
        status=0
    else
        echo "$expected column found in table. Test fail."
        feedback_msg=$FAIL_CHAR"$feedback_msg \"$expected\" column found in table. Test fail."
        status=1
    fi

    _write_feedback_msg_to_file "$feedback_msg"
    exit $status
}

test_column_type() {
    # arguments
    # $1 task number
    # $2 table name
    # $3 column name
    # $4 column data type (array - first item best choice, but other answers possible)

    task=$1
    table=$2
    column=$3
    shift
    shift
    shift
    expected=("$@")

    feedback_msg="Task $task Create Table - Columns: "

    # check certain conditions before running test
    _check_query_file_exists "$feedback_msg"
    _check_database_exists "$feedback_msg"
    _check_table_exists $table "$feedback_msg"

    QUERY="USE $DBNAME SELECT DATA_TYPE FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = '$table' AND COLUMN_NAME = '$column'"
    result=$(sqlcmd -S 127.0.0.1 -U sa -P $DBPASS -Q "$QUERY" | tail -n 3 | head -n 1 | xargs)

    # check data type $3 for $2 column for table $1
    if [[ $(is_value_in_array "$result" "${expected[@]}") == "true" ]]; then
        echo "$column of suitable data type"
        echo "pass"
        feedback_msg=$PASS_CHAR"$feedback_msg \"$column\" of suitable data type. Test pass."
        if [[ $result != *"${expected[0]}"* ]]; then
            feedback_msg="$feedback_msg (However, \"$result\" might not be the best data type. Is there a better data type that could be used?)"
        fi
        status=0
    else
        echo "$column not of suitable data type"
        feedback_msg=$FAIL_CHAR"$feedback_msg \"$column\" not of suitable data type. Test fail."
        status=1

        echo "    expected: ${expected[@]}"
        echo "    result: $result"
    fi

    _write_feedback_msg_to_file "$feedback_msg"
    exit $status
}

test_number_columns() {
    # arguments
    # $1 task number
    # $2 table name
    # $3 number of columns expected

    task=$1
    table=$2
    expected=$3

    feedback_msg="Task $task Create Table - Columns: "

    # check certain conditions before running test
    _check_query_file_exists "$feedback_msg"
    _check_database_exists "$feedback_msg"
    _check_table_exists $table "$feedback_msg"

    QUERY="USE $DBNAME SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = '$table' AND TABLE_SCHEMA='dbo'"
    result=$(sqlcmd -S 127.0.0.1 -U sa -P $DBPASS -Q "$QUERY")

    # check number of columns
    if [[ $result == *"($expected rows affected)"* ]]; then
        echo "no extra columns added"
        echo "pass"
        feedback_msg=$PASS_CHAR"$feedback_msg No extra columns added. Test pass."
        status=0
    else
        echo "wrong number of columns in table"
        feedback_msg=$FAIL_CHAR"$feedback_msg Wrong number of columns in table. Test fail."
        status=1
    fi

    _write_feedback_msg_to_file "$feedback_msg"
    exit $status
}

test_column_allowsnull() {
    # arguments
    # $1 task number
    # $2 table name
    # $3 column name

    task=$1
    table=$2
    column=$3

    feedback_msg="Task $task Create Table - Columns: "

    # check certain conditions before running test
    _check_query_file_exists "$feedback_msg"
    _check_database_exists "$feedback_msg"
    _check_table_exists $table "$feedback_msg"

    QUERY="USE $DBNAME SELECT COLUMNPROPERTY( OBJECT_ID('dbo.$table'),'$column','AllowsNull')"
    result=$(sqlcmd -S 127.0.0.1 -U sa -P $DBPASS -Q "$QUERY" | head -n 4 | tail -n 1)

    # check number of columns
    if [[ $result == *"1"* ]]; then
        echo "$column allows NULL values"
        echo "pass"
        feedback_msg=$PASS_CHAR"$feedback_msg \"$column\" allows NULL values. Test pass."
        status=0
    else
        echo "$column NULL type incorrectly set"
        feedback_msg=$FAIL_CHAR"$feedback_msg \"$column\" NULL type incorrectly set. Test fail."
        status=1
    fi

    _write_feedback_msg_to_file "$feedback_msg"
    exit $status
}

test_table_pk() {
    # arguments
    # $1 task number
    # $2 table name
    # $3 column name

    task=$1
    table=$2
    column=$3

    feedback_msg="Task $task Create Table - Columns: "

    # check certain conditions before running test
    _check_query_file_exists "$feedback_msg"
    _check_database_exists "$feedback_msg"
    _check_table_exists $table "$feedback_msg"

    QUERY="USE $DBNAME SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu ON tc.CONSTRAINT_NAME = ccu.Constraint_name WHERE tc.TABLE_NAME = '$table' AND tc.CONSTRAINT_TYPE = 'Primary Key'"
    result=$(sqlcmd -S 127.0.0.1 -U sa -P $DBPASS -Q "$QUERY" | head -n 4 | tail -n 1)

    # check PK
    if [[ $result == "$column"* ]]; then
        echo "PK of $table is $column"
        echo "pass"
        feedback_msg=$PASS_CHAR"$feedback_msg PK of \"$table\" is \"$column\". Test pass."
        status=0
    else
        echo "Incorrect PK in $table"
        feedback_msg=$FAIL_CHAR"$feedback_msg Incorrect PK in \"$table\". Test fail."
        status=1
    fi

    _write_feedback_msg_to_file "$feedback_msg"
    exit $status
}

test_column_fk () {
    # test if a column is a FK
    # arguments
    # $1 task number
    # $1 table name
    # $2 column name

    task=$1
    table=$2
    column=$3

    feedback_msg="Task $task Create Table - Columns: "

    # check certain conditions before running test
    _check_query_file_exists "$feedback_msg"
    _check_database_exists "$feedback_msg"
    _check_table_exists $table "$feedback_msg"

    QUERY="USE $DBNAME SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu ON tc.CONSTRAINT_NAME = ccu.Constraint_name WHERE tc.TABLE_NAME = '$table' AND tc.CONSTRAINT_TYPE = 'Foreign Key'"
    result=$(sqlcmd -S 127.0.0.1 -U sa -P $DBPASS -Q "$QUERY")

    # check FK
    if [[ $result == *"$column"* ]]; then
        echo "$column assigned as FK"
        echo "pass"
        feedback_msg=$PASS_CHAR"$feedback_msg \"$column\" is assigned as FK. Test pass."
        status=0
    else
        echo "Incorrect FK in $table"
        feedback_msg=$FAIL_CHAR"$feedback_msg Incorrect FK in \"$table\". Test fail."
        status=1
    fi

    _write_feedback_msg_to_file "$feedback_msg"
    exit $status
}

test_number_fks() {
    # test number of FK in table
    # arguments
    # $1 task number
    # $1 table name
    # $2 number of columns expected

    task=$1
    table=$2
    expected=$3

    feedback_msg="Task $task Create Table - Columns: "

    # check certain conditions before running test
    _check_query_file_exists "$feedback_msg"
    _check_database_exists "$feedback_msg"
    _check_table_exists $table "$feedback_msg"

    QUERY="USE $DBNAME SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu ON tc.CONSTRAINT_NAME = ccu.Constraint_name WHERE tc.TABLE_NAME = '$table' AND tc.CONSTRAINT_TYPE = 'Foreign Key'"
    result=$(sqlcmd -S 127.0.0.1 -U sa -P $DBPASS -Q "$QUERY")

    # check number of columns
    if [[ $result == *"($expected rows affected)"* ]]; then
        echo "correct number of FK in table"
        echo "pass"
        feedback_msg=$PASS_CHAR"$feedback_msg Correct number of FK constraints in \"$table\". Test pass."
        status=0
    else
        echo "wrong number of FK constraints in table"
        feedback_msg=$FAIL_CHAR"$feedback_msg Wrong number of FK constraints in \"$table\". Test fail."
        status=1
    fi

    _write_feedback_msg_to_file "$feedback_msg"
    exit $status
}

test_column_constraint () {
    # test if a column is a constraint type
    # arguments
    # $1 task number
    # $2 table name
    # $3 constraint type
    # $4 column name

    task=$1
    table=$2
    constraint_type="$3"
    column=$4

    feedback_msg="Task $task Create Table - Columns: "

    # check certain conditions before running test
    _check_query_file_exists "$feedback_msg"
    _check_database_exists "$feedback_msg"
    _check_table_exists $table "$feedback_msg"

    QUERY="USE $DBNAME SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu ON tc.CONSTRAINT_NAME = ccu.Constraint_name WHERE tc.TABLE_NAME = '$table' AND tc.CONSTRAINT_TYPE = \"$constraint_type\""
    result=$(sqlcmd -S 127.0.0.1 -U sa -P $DBPASS -Q "$QUERY")

    # check FK
    if [[ $result == *"$column"* ]]; then
        echo "$column assigned as $constraint_type"
        echo "pass"
        feedback_msg=$PASS_CHAR"$feedback_msg \"$column\" is assigned as $constraint_type. Test pass."
        status=0
    else
        echo "Incorrect $constraint_type in $table"
        feedback_msg=$FAIL_CHAR"$feedback_msg Incorrect $constraint_type in \"$table\". Test fail."
        status=1
    fi

    _write_feedback_msg_to_file "$feedback_msg"
    exit $status
}

test_number_constraints() {
    # test number of constraint in table
    # arguments
    # $1 task number
    # $2 table name
    # $3 constraint type
    # $4 number of columns expected

    task=$1
    table=$2
    constraint_type="$3"
    expected=$4

    feedback_msg="Task $task Create Table - Columns: "

    # check certain conditions before running test
    _check_query_file_exists "$feedback_msg"
    _check_database_exists "$feedback_msg"
    _check_table_exists $table "$feedback_msg"

    QUERY="USE $DBNAME SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu ON tc.CONSTRAINT_NAME = ccu.Constraint_name WHERE tc.TABLE_NAME = '$table' AND tc.CONSTRAINT_TYPE = \"$constraint_type\""
    result=$(sqlcmd -S 127.0.0.1 -U sa -P $DBPASS -Q "$QUERY" | tail -n 1)

    # check number of columns
    if [[ $result == *"($expected rows affected)"* ]]; then
        echo "correct number of ${constraint_type}s in table"
        echo "pass"
        feedback_msg=$PASS_CHAR"$feedback_msg Correct number of ${constraint_type} constraints in \"$table\". Test pass."
        status=0
    else
        echo "wrong number of ${constraint_type} constraints in table"
        feedback_msg=$FAIL_CHAR"$feedback_msg Wrong number of ${constraint_type} constraints in \"$table\". Test fail."
        status=1
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
