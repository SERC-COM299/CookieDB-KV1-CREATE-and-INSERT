#!/bin/bash
#
# Grading tests for Exercise 3
#
# set -e

# declare which files to use
QUERYFILE=exercise3.sql
FEEDBACK_FILE=exercise3.md

NUMBER_OF_TASKS_IN_EXERCISE=3

# import common functions and var
. ./"`dirname \"$0\"`"/common.sh

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
