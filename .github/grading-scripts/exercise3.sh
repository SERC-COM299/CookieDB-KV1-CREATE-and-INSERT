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
    # test to check query that returns all values in Products table
    # arguments
    # no args

    # tables=(Dispensers Rooms)
    tables=(Products)

    feedback_msg_head="Task 1 Return Products: "
    feedback_msg_pass="Query found that shows table contents. Test pass."
    feedback_msg_fail="Query in $QUERYFILE does not show table contents as expected. Test fail."

    expected_result="13-Exercise3-Task1-Result.txt"
    task_offset=1
    # task=1

    _test_query tables "$feedback_msg_head" "$feedback_msg_pass" "$feedback_msg_fail" "$expected_result" "$task_offset"
}

test_table_contents_query_ordered () {
    # test to check query that returns all values in Products table ordered by price
    # arguments
    # no args

    # tables=(Dispensers Rooms)
    tables=(Products)

    feedback_msg_head="Task 1 Return Products ordered by price: "
    feedback_msg_pass="Query found that shows table contents in numerical order. Test pass."
    feedback_msg_fail="Query in $QUERYFILE does not show table contents as expected. Test fail."

    expected_result="13-Exercise3-Task2-Result.txt"
    task_offset=2
    # task=1

    _test_query tables "$feedback_msg_head" "$feedback_msg_pass" "$feedback_msg_fail" "$expected_result" "$task_offset"
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
