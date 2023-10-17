#!/bin/bash
#
# place: . ./"`dirname \"$0\"`"/common.sh
# in grading test scripts

# setup vars because ENV vars not passed through by autograding
DBPASS='Pa$$w0rd1234'
FEEDBACKFILE_DIR=.github/temp/
DATADIR=.github/data/
EXPECTED_RESULTS_DIR=.github/expected-results/

DBNAME=#enter DB name here

PASS_CHAR=":white_check_mark: "
FAIL_CHAR=":x: "

# use 'em' character to generate spaces
TABSPACE="  "

# make sure temp dir exists
mkdir -p $FEEDBACKFILE_DIR

# if answers exist, replace query file with answer query
if [ -f "answers/$QUERYFILE" ]; then
    QUERYFILE=answers/$QUERYFILE
fi

_check_query_file_exists () {
    # internal function to exit test if query file missing
    # arguments
    # $1 feedback message
    if [ ! -f "$QUERYFILE" ]; then
        echo "$QUERYFILE missing."
        feedback_msg=$FAIL_CHAR"$1""$QUERYFILE missing. Test fail."
        _write_feedback_msg_to_file "$feedback_msg"
        exit 1
    fi
}

_check_database_exists () {
    # internal function to exit test if database missing
    # arguments
    # $1 feedback message
    sqlcmd -S 127.0.0.1 -U sa -P $DBPASS -d $DBNAME -Q "SELECT 1" -b -o /dev/null
    ret=$?
    if [ $ret -ne 0 ]; then
        echo "Database not found"
        feedback_msg=$FAIL_CHAR"$1""Cannot find database \"$DBNAME\". Test fail."
        _write_feedback_msg_to_file "$feedback_msg"
        exit 1
    fi
}

_check_table_exists () {
    # arguments
    # $1 table name
    # $2 feedback message
    table=$1

    query="SELECT TABLE_NAME FROM $DBNAME.INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE = 'BASE TABLE' AND TABLE_NAME = '$table'"
    result=$(sqlcmd -S 127.0.0.1 -U sa -P $DBPASS -Q "$query" | tail -n 1 | cut -c 2)
    if [ $result -eq 0 ]; then
        echo "Table not found"
        feedback_msg=$FAIL_CHAR"$2""Cannot find table \"$table\". Test fail."
        _write_feedback_msg_to_file "$feedback_msg"
        exit 1
    fi
}

_check_procedure_exists () {
    # arguments
    # $1 procedure name
    # $2 feedback message
    procedure=$1
    feedback_msg=$2

    query="SELECT 1 FROM sys.procedures WHERE Name = '$procedure'"
    result=$(sqlcmd -S 127.0.0.1 -U sa -P $DBPASS -d $DBNAME -Q "$query" | tail -n 1 | cut -c 2)
    if [ $result -eq 0 ]; then
        echo "Procedure not found"
        feedback_msg=$FAIL_CHAR"$2""Cannot find procedure \"$procedure\". Test fail."
        _write_feedback_msg_to_file "$feedback_msg"
        exit 1
    fi
}

_check_query_file_runs () {
    # internal function to exit test if query file runs with errors
    # arguments
    # $1 feedback message
    sqlcmd -S 127.0.0.1 -U sa -P $DBPASS -d master -i "$QUERYFILE" -b -o /dev/null
    ret=$?
    if [ $ret -ne 0 ]; then
        echo "Error running query file."
        feedback_msg=$FAIL_CHAR"$1 Error running $QUERYFILE query file. Test fail."
        _write_feedback_msg_to_file "$feedback_msg"
        exit 1
    fi
}

_test_query () {
    # generic test query results
    # arguments
    # $1 pass name of array of tables  #TODO: test
    # $2 feedback message start
    # $3 feedback message pass
    # $4 feedback message fail
    # $5 results file or query
    # $6 offset lines for multiple queries in file

    tables_var_name=$1[@]
    tables=("${!tables_var_name}")

    feedback_msg=$2

    # check certain conditions before running test
    _check_query_file_exists "$feedback_msg"
    _check_database_exists "$feedback_msg"
    for table in ${tables[@]}; do _check_table_exists $table "$feedback_msg"; done

    feedback_msg_pass=$3
    feedback_msg_fail=$4
    expected_result=$5
    task_offset="$6"

    # check if task_offset points to a file. if not, use to trim query result
    if [[ -f "${QUERYFILE%.*}-Task$task_offset.sql" ]]; then
        result=$(sqlcmd -S 127.0.0.1 -U sa -P $DBPASS -d $DBNAME -i "${QUERYFILE%.*}-Task$task_offset.sql" | sed '/Changed database context to/d')
    else
        _check_query_file_runs "$feedback_msg"
        result=$(sqlcmd -S 127.0.0.1 -U sa -P $DBPASS -d $DBNAME -i "$QUERYFILE" | sed '/Changed database context to/d' | eval $task_offset)
    fi

    if [[ -f $EXPECTED_RESULTS_DIR$expected_result ]]; then
        expected_full=$(<$EXPECTED_RESULTS_DIR$expected_result)
        expected_column_headings=$(head -n 1 $EXPECTED_RESULTS_DIR$expected_result)
        expected_num_rows=$(tail -n 1 $EXPECTED_RESULTS_DIR$expected_result)
    else
        query=$expected_result
        expected_full=$(sqlcmd -S 127.0.0.1 -U sa -P $DBPASS -d $DBNAME -Q "$query")
        expected_column_headings=$(sqlcmd -S 127.0.0.1 -U sa -P $DBPASS -d $DBNAME -Q "$query" | head -n 1)
        expected_num_rows=$(sqlcmd -S 127.0.0.1 -U sa -P $DBPASS -d $DBNAME -Q "$query"| tail -n 1)
    fi

    # check file generates expected query
    if [[ $result == *"$expected_full"* ]]; then
        echo "$feedback_msg_pass"
        echo "pass"
        feedback_msg=$PASS_CHAR"$feedback_msg $feedback_msg_pass. Test pass."
        status=0
    else
        echo "Query in $QUERYFILE does not show results as expected."
        feedback_msg=$FAIL_CHAR"$feedback_msg Query in $QUERYFILE does not show results as expected. Test fail."

        if [[ $result != *"$expected_column_headings"* ]]; then
            echo "    Column headings are incorrect. Are the columns in the same order as asked in the task?"
            feedback_msg+="  \n$TABSPACE Column headings are incorrect. Are the columns in the same order as asked in the task?"
        fi

        if [[ $result != *"$expected_num_rows"* ]]; then
            echo "    Incorrect number of rows returned."
            feedback_msg+="  \n$TABSPACE Query does not return the correct number of results."
        fi

        echo "    $feedback_msg_fail"
        feedback_msg+="  \n$TABSPACE $feedback_msg_fail"
        status=1
    fi

    _write_feedback_msg_to_file "$feedback_msg"
    exit $status
}

_test_procedure_query () {
    # generic test for stored procedure
    # check against expected result file
    # arguments
    # $1 query to run
    # $2 expected result filename

    # procedure_name
    # procedure_params
    
    # feedback_msg=$1
    query=$1
    expected_result=$2

    result=$(sqlcmd -S 127.0.0.1 -U sa -P $DBPASS -d $DBNAME -Q "$query")

    if [[ -f $EXPECTED_RESULTS_DIR$expected_result ]]; then
        expected_full=$(<$EXPECTED_RESULTS_DIR$expected_result)
        expected_column_headings=$(head -n 1 $EXPECTED_RESULTS_DIR$expected_result)
        expected_num_rows=$(tail -n 1 $EXPECTED_RESULTS_DIR$expected_result)
    else
        echo "Error. Cannot find expected result file."
        exit 1
    fi

    # check file generates expected query
    if [[ $result == *"$expected_full"* ]]; then
        echo "\"$query\" result as expected."
        # echo "pass"
        # feedback_msg=$PASS_CHAR"$feedback_msg $feedback_msg_pass. Test pass."
        status=0
    else
        echo "\"$query\" result not as expected. Fail."
        # feedback_msg=$FAIL_CHAR"$feedback_msg \"$procedure_name\" procedure does not show results as expected. Test fail."
        # feedback_msg=$FAIL_CHAR"$feedback_msg \"$query\" does not show results as expected. Test fail."
        error_msg="\`$query\` does not show results as expected."

        if [[ $result != *"$expected_column_headings"* ]]; then
            echo "    Column headings are incorrect. Are the columns in the same order as asked in the task?"
            error_msg+="  \n$TABSPACE Column headings are incorrect. Are the columns in the same order as asked in the task?"
        fi

        if [[ $result != *"$expected_num_rows"* ]]; then
            echo "    Incorrect number of rows returned."
            error_msg+="  \n$TABSPACE Procedure does not return the correct number of results."
        fi

        status=1
    fi

    # exit $status
}

_write_feedback_msg_to_file () {
    # internal function to write feedback message to feedback file
    # arguments
    # $1 feedback message
    printf "$feedback_msg  \n" >> $FEEDBACKFILE_DIR$FEEDBACK_FILE
}

run_query_file () {

    feedback_msg="Run query file: "

    _check_query_file_exists "$feedback_msg"

    sqlcmd -S 127.0.0.1 -U sa -P $DBPASS -d master -i "$QUERYFILE"
    if [ $? -eq 0 ]; then
        echo "Query file run."
        feedback_msg=$PASS_CHAR"$feedback_msg $QUERYFILE query file runs. Test pass."
        status=0
    else
        echo "Error running query file."
        feedback_msg=$FAIL_CHAR"$feedback_msg Error running $QUERYFILE query file. Test fail."
        status=1
    fi

    _write_feedback_msg_to_file "$feedback_msg"
    exit $status
}

split_query_file () {
    # function that splits tasks into seperate query files.

    # find task block comment line numbers
    line_numbers=($(grep -n -F "/******" $QUERYFILE | cut -d ':' -f 1))

    # check if number of tasks set
    if [ -z "$NUMBER_OF_TASKS_IN_EXERCISE" ]; then
        NUMBER_OF_TASKS_IN_EXERCISE=$((${#line_numbers[@]} - 1))
        # echo $NUMBER_OF_TASKS_IN_EXERCISE
    elif [[ ${#line_numbers[@]} != $(($NUMBER_OF_TASKS_IN_EXERCISE + 1)) ]]; then
        echo "Error finding task comment blocks"
        exit 1
    fi

    for task in $(seq $NUMBER_OF_TASKS_IN_EXERCISE); do
        if [[ $task == $NUMBER_OF_TASKS_IN_EXERCISE ]]; then
            cat $QUERYFILE | tail -n +${line_numbers[$task]} > "${QUERYFILE%.*}-Task$task.sql"
        else
            cat $QUERYFILE | head -n $(( "${line_numbers[$task + 1]}" - 1 )) | tail -n +${line_numbers[$task]} > "${QUERYFILE%.*}-Task$task.sql"
        fi
    done
}
