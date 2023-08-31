#!/bin/dash
# 
# Tests pigs-init
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
        echo "Test 00_$TEST_NUM ($DESCRIPTION) - Passed"
    else
        echo "Test 00_$TEST_NUM ($DESCRIPTION) - Failed"
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
# Test 1: successful 'pigs-init'

cd "$REF_DIR" || exit
2041 pigs-init > "$REF_OUT" 2> "$REF_ERR"
REF_EXIT=$?                                 # check exit status
ls -d .pig >> "$REF_OUT" 2> "$REF_ERR"      # check if file exists

cd "$OUR_DIR" || exit
pigs-init > "$OUR_OUT" 2> "$OUR_ERR"
OUR_EXIT=$?                                 # check exit status
ls -d .pig >> "$OUR_OUT" 2> "$OUR_ERR"      # check if file exists

run_test_against_ref 1 "successful 'pigs-init'"
#####################################################################
# Test 2: unsuccessful 'pigs-init'

cd "$REF_DIR" || exit
2041 pigs-init > "$REF_OUT" 2> "$REF_ERR"
REF_EXIT=$?                                 # check exit status
ls -d .pig >> "$REF_OUT" 2> "$REF_ERR"      # check if file exists

cd "$OUR_DIR" || exit
pigs-init > "$OUR_OUT" 2> "$OUR_ERR"
OUR_EXIT=$?                                 # check exit status
ls -d .pig >> "$OUR_OUT" 2> "$OUR_ERR"      # check if file exists

run_test_against_ref 2 "unsuccessful 'pigs-init'"
#####################################################################
# Test 3: folder structure 'pigs-init'
cd "$OUR_DIR" || exit
if
    [ -d '.pig/index' ] &&
    [ -d '.pig/logs' ] &&
    [ -d '.pig/logs/unstaged' ] &&
    [ -d '.pig/logs/staged' ] &&
    [ -d '.pig/logs/history' ] &&
    [ -d '.pig/logs/tmp_deleted' ] &&
    [ -e '.pig/logs/commits' ] &&
    [ -d '.pig/branches' ] &&
    [ -d '.pig/branches/master' ] &&
    [ -e '.pig/curr_branch' ]
then
    echo "Test 00_3 (folder structure 'pigs-init') - Passed"
else
    echo "Test 00_3 (folder structure 'pigs-init') - Failed"
fi
