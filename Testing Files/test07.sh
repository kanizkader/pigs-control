#!/bin/dash
# 
# Tests pigs-branch & pigs-checkout
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
        echo "Test 07_$TEST_NUM ($DESCRIPTION) - Passed"
    else
        echo "Test 07_$TEST_NUM ($DESCRIPTION) - Failed"
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
# Test 1: no repo 'pigs-branch'
cd "$REF_DIR" || exit
2041 pigs-branch > "$REF_OUT" 2> "$REF_ERR"
REF_EXIT=$?                                 # check exit status

cd "$OUR_DIR" || exit
pigs-branch > "$OUR_OUT" 2> "$OUR_ERR"
OUR_EXIT=$?                                 # check exit status

run_test_against_ref 1 "no repo 'pigs-branch'"
#####################################################################
# Test 2: no repo 'pigs-checkout'
cd "$REF_DIR" || exit
2041 pigs-checkout > "$REF_OUT" 2> "$REF_ERR"
REF_EXIT=$?                                 # check exit status

cd "$OUR_DIR" || exit
pigs-checkout > "$OUR_OUT" 2> "$OUR_ERR"
OUR_EXIT=$?                                 # check exit status

run_test_against_ref 2 "no repo 'pigs-checkout'"
#####################################################################
# Create .pig repo
cd "$REF_DIR" || exit
2041 pigs-init > "$REF_OUT" 2> "$REF_ERR"
ls -d .pig >> "$REF_OUT" 2> "$REF_ERR"      
cd "$OUR_DIR" || exit
pigs-init > "$OUR_OUT" 2> "$OUR_ERR"
ls -d .pig >> "$OUR_OUT" 2> "$OUR_ERR" 
#####################################################################
# Test 3: empty commit log 'pigs-branch'
cd "$REF_DIR" || exit
2041 pigs-branch 1 2 a.txt > "$REF_OUT" 2> "$REF_ERR"
REF_EXIT=$?                                 

cd "$OUR_DIR" || exit
pigs-branch 1 2 a.txt > "$OUR_OUT" 2> "$OUR_ERR"
OUR_EXIT=$?                                 

run_test_against_ref 3 "empty commit log 'pigs-branch'"
#####################################################################
# Test 4: empty commit log 'pigs-checkout'
cd "$REF_DIR" || exit
2041 pigs-checkout 1 2 > "$REF_OUT" 2> "$REF_ERR"
REF_EXIT=$?                                 

cd "$OUR_DIR" || exit
pigs-checkout 1 2 > "$OUR_OUT" 2> "$OUR_ERR"
OUR_EXIT=$?                                 

run_test_against_ref 4 "empty commit log 'pigs-checkout'"
#####################################################################
# make initial commit
cd "$REF_DIR" || exit
touch a
2041 pigs-add a
2041 pigs-commit -m "committed" > /dev/null
REF_EXIT=$?                                 

cd "$OUR_DIR" || exit
touch a
pigs-add a
pigs-commit -m "committed" > /dev/null
OUR_EXIT=$?    
#####################################################################
# Test 5: wrong num args 'pigs-branch'
cd "$REF_DIR" || exit
2041 pigs-branch 1 2 a.txt > "$REF_OUT" 2> "$REF_ERR"
REF_EXIT=$?                                 

cd "$OUR_DIR" || exit
pigs-branch 1 2 a.txt > "$OUR_OUT" 2> "$OUR_ERR"
OUR_EXIT=$?                                 

run_test_against_ref 5 "wrong num args 'pigs-branch'"
#####################################################################
# Test 6: wrong num args 'pigs-checkout'
cd "$REF_DIR" || exit
2041 pigs-checkout 1 2 > "$REF_OUT" 2> "$REF_ERR"
REF_EXIT=$?                                 

cd "$OUR_DIR" || exit
pigs-checkout 1 2 > "$OUR_OUT" 2> "$OUR_ERR"
OUR_EXIT=$?                                 

run_test_against_ref 6 "wrong num args 'pigs-checkout'"
#####################################################################
# Test 7: list of branches before creating 'pigs-branch'
cd "$REF_DIR" || exit
2041 pigs-branch > "$REF_OUT" 2> "$REF_ERR"
REF_EXIT=$?                                 

cd "$OUR_DIR" || exit
pigs-branch > "$OUR_OUT" 2> "$OUR_ERR"
OUR_EXIT=$?                                 

run_test_against_ref 7 "list of branches before creating 'pigs-branch'"
#####################################################################
# Test 8: unsuccessful create branch 'pigs-branch'
cd "$REF_DIR" || exit
2041 pigs-branch 'master'> "$REF_OUT" 2> "$REF_ERR"
REF_EXIT=$?                                 

cd "$OUR_DIR" || exit
pigs-branch 'master'> "$OUR_OUT" 2> "$OUR_ERR"
OUR_EXIT=$?                                 

run_test_against_ref 8 "unsuccessful create branch 'pigs-branch'"
#####################################################################
# Test 9: successful create branch 'pigs-branch'
cd "$REF_DIR" || exit
2041 pigs-branch 'dev'> "$REF_OUT" 2> "$REF_ERR"
REF_EXIT=$?                                 

cd "$OUR_DIR" || exit
pigs-branch 'dev'> "$OUR_OUT" 2> "$OUR_ERR"
OUR_EXIT=$?                                 

run_test_against_ref 9 "successful create branch 'pigs-branch'"
#####################################################################
# Test 10: folder structure after branch creation 'pigs-branch'
cd "$OUR_DIR" || exit
if
    [ -e '.pig/branches/dev' ]
then
    echo "Test 07_10 (folder structure after creation 'pigs-branch') - Passed"
else
    echo "Test 07_10 (folder structure after creation 'pigs-branch') - Failed"
fi
#####################################################################
# Test 11: branch doesn't exist 'pigs-checkout'
cd "$REF_DIR" || exit
2041 pigs-checkout 1 > "$REF_OUT" 2> "$REF_ERR"
REF_EXIT=$?                                 

cd "$OUR_DIR" || exit
pigs-checkout 1 > "$OUR_OUT" 2> "$OUR_ERR"
OUR_EXIT=$?                                 

run_test_against_ref 11 "branch doesn't exist 'pigs-checkout'"
#####################################################################
# Test 12: already in branch 'pigs-checkout'
cd "$REF_DIR" || exit
2041 pigs-checkout 'master' > "$REF_OUT" 2> "$REF_ERR"
REF_EXIT=$?                                 

cd "$OUR_DIR" || exit
pigs-checkout 'master' > "$OUR_OUT" 2> "$OUR_ERR"
OUR_EXIT=$?                                 

run_test_against_ref 12 "already in branch 'pigs-checkout'"
#####################################################################
# Test 13: successful checkout 'pigs-checkout'
cd "$REF_DIR" || exit
2041 pigs-checkout 'dev' > "$REF_OUT" 2> "$REF_ERR"
REF_EXIT=$?                                 

cd "$OUR_DIR" || exit
pigs-checkout 'dev' > "$OUR_OUT" 2> "$OUR_ERR"
OUR_EXIT=$?                                 

run_test_against_ref 13 "successful checkout 'pigs-checkout'"
#####################################################################
# Test 14: unsuccessful delete while in branch 'pigs-branch'
cd "$REF_DIR" || exit
2041 pigs-branch -d 'dev' > "$REF_OUT" 2> "$REF_ERR"
REF_EXIT=$?                                 

cd "$OUR_DIR" || exit
pigs-branch -d 'dev' > "$OUR_OUT" 2> "$OUR_ERR"
OUR_EXIT=$?                                 

run_test_against_ref 14 "unsuccessful delete while in branch 'pigs-branch'"
#####################################################################
# Test 15: unsuccessful delete master 'pigs-branch'
cd "$REF_DIR" || exit
2041 pigs-branch -d 'master' > "$REF_OUT" 2> "$REF_ERR"
REF_EXIT=$?                                 

cd "$OUR_DIR" || exit
pigs-branch -d 'master' > "$OUR_OUT" 2> "$OUR_ERR"
OUR_EXIT=$?                                 

run_test_against_ref 15 "unsuccessful delete master 'pigs-branch'"
#####################################################################
# checkout into master
cd "$REF_DIR" || exit
2041 pigs-checkout 'master' > "$REF_OUT" 2> "$REF_ERR"

cd "$OUR_DIR" || exit
pigs-checkout 'master' > "$OUR_OUT" 2> "$OUR_ERR"
#####################################################################
# Test 16: successful delete 'pigs-branch'
cd "$REF_DIR" || exit
2041 pigs-branch -d 'dev' > "$REF_OUT" 2> "$REF_ERR"
REF_EXIT=$?                                 

cd "$OUR_DIR" || exit
pigs-branch -d 'dev' > "$OUR_OUT" 2> "$OUR_ERR"
OUR_EXIT=$?                                 

run_test_against_ref 16 "successful delete 'pigs-branch'"
