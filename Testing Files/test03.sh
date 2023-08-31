#!/bin/dash
# 
# Tests pigs-log
#
#####################################################################
# Compares against reference implementation
# Arguments:
#   Test Number, Test Description
# Outputs:
#   Pass/Fail msg based on results
#####################################################################
run_test_against_ref () {
    TEST_NUM="$1"
    DESCRIPTION="$2"
    if
        diff "$OUR_OUT" "$REF_OUT" > /dev/null &&
        diff "$OUR_ERR" "$REF_ERR" > /dev/null &&
        [ "$OUR_EXIT" -eq "$REF_EXIT" ]
    then
        echo "Test 03_$TEST_NUM ($DESCRIPTION) - Passed"
    else
        echo "Test 03_$TEST_NUM ($DESCRIPTION) - Failed"
        echo '------------------------------'
        diff "$OUR_OUT" "$REF_OUT" > /dev/null
        if 
            [ "$?" -eq 1 ]
        then
            echo "  - Stdout diff:"
            echo "+ Reference:"
            cat "$REF_OUT"
            echo "+ Implementation:"
            cat "$OUR_OUT" 
            echo '------------------------------'
        fi
        diff "$OUR_ERR" "$REF_ERR" > /dev/null
        if 
            [ "$?" -eq 1 ]
        then
            echo "  - Stderr diff:"
            echo "+ Reference:"
            cat "$REF_ERR"
            echo "+ Implementation:"
            cat "$OUR_ERR"
            echo '------------------------------'
        fi
        echo "  - Reference exit status: $REF_EXIT"
        echo "  - Implementation exit status: $OUR_EXIT"
        echo '------------------------------'
    fi
}
#####################################################################
# Set up temp directories
REF_DIR=$(mktemp -d)
REF_OUT=$(mktemp)
REF_ERR=$(mktemp)

OUR_DIR=$(mktemp -d)
OUR_OUT=$(mktemp)
OUR_ERR=$(mktemp)

PATH="$PATH:$(dirname "$(realpath "$0")")"  # modifies PATH to include curr dir
trap 'rm -rf "$REF_DIR" "$OUR_DIR"' EXIT 
#####################################################################
# Test 1: no repo 'pigs-log'
cd "$REF_DIR" || exit
2041 pigs-log > "$REF_OUT" 2> "$REF_ERR"
REF_EXIT=$?                                 

cd "$OUR_DIR" || exit
pigs-log > "$OUR_OUT" 2> "$OUR_ERR"
OUR_EXIT=$?                                 

run_test_against_ref 1 "no repo 'pigs-log'"
#####################################################################
# Create .pig repo
cd "$REF_DIR" || exit
2041 pigs-init > "$REF_OUT" 2> "$REF_ERR"
ls -d .pig >> "$REF_OUT" 2> "$REF_ERR"      
cd "$OUR_DIR" || exit
pigs-init > "$OUR_OUT" 2> "$OUR_ERR"
ls -d .pig >> "$OUR_OUT" 2> "$OUR_ERR" 
#####################################################################
# Test 2: wrong num args 'pigs-log'
cd "$REF_DIR" || exit
2041 pigs-log a > "$REF_OUT" 2> "$REF_ERR"
REF_EXIT=$?                                 

cd "$OUR_DIR" || exit
pigs-log a > "$OUR_OUT" 2> "$OUR_ERR"
OUR_EXIT=$?                                 

run_test_against_ref 2 "wrong num args 'pigs-log'"
#####################################################################
# Test 3: empty log 'pigs-log'
cd "$REF_DIR" || exit
2041 pigs-log > "$REF_OUT" 2> "$REF_ERR"
REF_EXIT=$?                                 

cd "$OUR_DIR" || exit
pigs-log > "$OUR_OUT" 2> "$OUR_ERR"
OUR_EXIT=$?                                 

run_test_against_ref 3 "empty log 'pigs-log'"
#####################################################################
# Test 4: successful 'pigs-log'
cd "$REF_DIR" || exit
touch a
2041 pigs-commit -a -m "first commit" > /dev/null
touch b
2041 pigs-commit -m "second commit" > /dev/null
2041 pigs-log > "$REF_OUT" 2> "$REF_ERR"
REF_EXIT=$?                                 

cd "$OUR_DIR" || exit
touch a
pigs-commit -a -m "first commit" > /dev/null
touch b
pigs-commit -m "second commit" > /dev/null
pigs-log > "$OUR_OUT" 2> "$OUR_ERR"
OUR_EXIT=$?                                 

run_test_against_ref 4 "successful 'pigs-log'"
