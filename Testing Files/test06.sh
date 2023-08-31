#!/bin/dash
# 
# Tests pigs-status
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
        echo "Test 06_$TEST_NUM ($DESCRIPTION) - Passed"
    else
        echo "Test 06_$TEST_NUM ($DESCRIPTION) - Failed"
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
# Test 1: no repo 'pigs-status'
cd "$REF_DIR" || exit
2041 pigs-status > "$REF_OUT" 2> "$REF_ERR"
REF_EXIT=$?                                 # check exit status

cd "$OUR_DIR" || exit
pigs-status > "$OUR_OUT" 2> "$OUR_ERR"
OUR_EXIT=$?                                 # check exit status

run_test_against_ref 1 "no repo 'pigs-status'"
#####################################################################
# Create .pig repo
cd "$REF_DIR" || exit
2041 pigs-init > "$REF_OUT" 2> "$REF_ERR"
ls -d .pig >> "$REF_OUT" 2> "$REF_ERR"      
cd "$OUR_DIR" || exit
pigs-init > "$OUR_OUT" 2> "$OUR_ERR"
ls -d .pig >> "$OUR_OUT" 2> "$OUR_ERR" 
#####################################################################
# Test 2: wrong num args 'pigs-status'
cd "$REF_DIR" || exit
2041 pigs-status a > "$REF_OUT" 2> "$REF_ERR"
REF_EXIT=$?                                 

cd "$OUR_DIR" || exit
pigs-status a > "$OUR_OUT" 2> "$OUR_ERR"
OUR_EXIT=$?                                 

run_test_against_ref 2 "wrong num args 'pigs-status'"
#####################################################################
# Test 3: file changed, different changes staged for commit 'pigs-status'
cd "$REF_DIR" || exit
touch a
2041 pigs-add a
2041 pigs-commit -m "committed" > /dev/null
seq 1 7 >a
2041 pigs-add a
seq 8 10 >a
2041 pigs-status > "$REF_OUT" 2> "$REF_ERR"
REF_EXIT=$?                                 

cd "$OUR_DIR" || exit
touch a
pigs-add a
pigs-commit -m "committed" > /dev/null
seq 1 7 >a
pigs-add a
seq 8 10 >a
pigs-status > "$OUR_OUT" 2> "$OUR_ERR"
OUR_EXIT=$?                                 

MSG="file changed, different changes staged for commit 'pigs-status'"
run_test_against_ref 3 "$MSG"
#####################################################################
# Test 4: folder structure after file changed 'pigs-status'
cd "$OUR_DIR" || exit
if
    [ -e 'a' ] &&
    [ -e '.pig/index/a' ] &&
    [ -e '.pig/logs/staged/a' ] &&
    [ -e '.pig/logs/unstaged/a' ]
then
    echo "Test 06_4 (folder structure file changed 'pigs-status') - Passed"
else
    echo "Test 06_4 (folder structure after deletion 'pigs-status') - Failed"
fi
#####################################################################
# Test 5: file changed, changes not staged for commit 'pigs-status'
cd "$REF_DIR" || exit
touch b
2041 pigs-add b
2041 pigs-commit -m "committed" > /dev/null
seq 8 10 >b
2041 pigs-status > "$REF_OUT" 2> "$REF_ERR"
REF_EXIT=$?                                 

cd "$OUR_DIR" || exit
touch b
pigs-add b
pigs-commit -m "committed" > /dev/null
seq 8 10 >b
pigs-status > "$OUR_OUT" 2> "$OUR_ERR"
OUR_EXIT=$?                                 

MSG="file changed, changes not staged for commit 'pigs-status'"
run_test_against_ref 5 "$MSG"
#####################################################################
# Test 6: same as repo 'pigs-status'
cd "$REF_DIR" || exit
touch c
2041 pigs-add c
2041 pigs-commit -m "committed" > /dev/null
2041 pigs-status > "$REF_OUT" 2> "$REF_ERR"
REF_EXIT=$?                                 

cd "$OUR_DIR" || exit
touch c
pigs-add c
pigs-commit -m "committed" > /dev/null
pigs-status > "$OUR_OUT" 2> "$OUR_ERR"
OUR_EXIT=$?                                 

run_test_against_ref 6 "same as repo'pigs-status'"
#####################################################################
# Fix current files for testing
cd "$REF_DIR" || exit
2041 pigs-rm --force a > "$REF_OUT" 2> "$REF_ERR"
2041 pigs-rm --force b > "$REF_OUT" 2> "$REF_ERR"
2041 pigs-rm --force c > "$REF_OUT" 2> "$REF_ERR"
2041 pigs-commit -m "fixed repo for testing" > "$REF_OUT" 2> "$REF_ERR"

cd "$OUR_DIR" || exit
pigs-rm --force a > "$REF_OUT" 2> "$REF_ERR"
pigs-rm --force b > "$REF_OUT" 2> "$REF_ERR"
pigs-rm --force c > "$REF_OUT" 2> "$REF_ERR"
pigs-commit -m "fixed repo for testing" > "$REF_OUT" 2> "$REF_ERR"
#####################################################################
# Test 7: added to index 'pigs-status'
cd "$REF_DIR" || exit
touch c
2041 pigs-add c
2041 pigs-status > "$REF_OUT" 2> "$REF_ERR"
REF_EXIT=$?                                 

cd "$OUR_DIR" || exit
touch c
pigs-add c
pigs-status > "$OUR_OUT" 2> "$OUR_ERR"
OUR_EXIT=$?                                 

run_test_against_ref 7 "added to index 'pigs-status'"
#####################################################################
# Test 8: folder structure after file added 'pigs-status'
cd "$OUR_DIR" || exit
if
    [ -e 'c' ] &&
    [ -e '.pig/index/c' ] &&
    [ -e '.pig/logs/unstaged/c' ]
then
    echo "Test 06_8 (folder structure file added 'pigs-status') - Passed"
else
    echo "Test 06_8 (folder structure after added 'pigs-status') - Failed"
fi
#####################################################################
# Test 9: simple untracked 'pigs-status'
cd "$REF_DIR" || exit
2041 pigs-rm --cached c
2041 pigs-status > "$REF_OUT" 2> "$REF_ERR"
REF_EXIT=$?                                 

cd "$OUR_DIR" || exit
pigs-rm --cached c
pigs-status > "$OUR_OUT" 2> "$OUR_ERR"
OUR_EXIT=$?                                 

run_test_against_ref 9 "simple untracked 'pigs-status'"
#####################################################################
# Test 10: extended untracked 'pigs-status'
cd "$REF_DIR" || exit
touch b
2041 pigs-add b
2041 pigs-commit -m "committed" > /dev/null
2041 pigs-rm --cached b
2041 pigs-status > "$REF_OUT" 2> "$REF_ERR"
REF_EXIT=$?                                 

cd "$OUR_DIR" || exit
touch b
pigs-add b
pigs-commit -m "committed" > /dev/null
pigs-rm --cached b
pigs-status > "$OUR_OUT" 2> "$OUR_ERR"
OUR_EXIT=$?                                 

run_test_against_ref 10 "extended untracked 'pigs-status'"
#####################################################################
# Fix current files for testing
cd "$REF_DIR" || exit
2041 pigs-rm --force b > "$REF_OUT" 2> "$REF_ERR"
rm b
2041 pigs-rm --force c > "$REF_OUT" 2> "$REF_ERR"
rm c
2041 pigs-commit -m "fixed repo for testing" > "$REF_OUT" 2> "$REF_ERR"

cd "$OUR_DIR" || exit
pigs-rm --force b > "$REF_OUT" 2> "$REF_ERR"
rm b
pigs-rm --force c > "$REF_OUT" 2> "$REF_ERR"
rm c
pigs-commit -m "fixed repo for testing" > "$REF_OUT" 2> "$REF_ERR"
#####################################################################
# Test 11: added to index, file deleted 'pigs-status'
cd "$REF_DIR" || exit
touch a
2041 pigs-add a
rm a
2041 pigs-status > "$REF_OUT" 2> "$REF_ERR"
REF_EXIT=$?                                 

cd "$OUR_DIR" || exit
touch a
pigs-add a
rm a
pigs-status > "$OUR_OUT" 2> "$OUR_ERR"
OUR_EXIT=$?                                 

run_test_against_ref 11 "added to index, file deleted 'pigs-status'"
#####################################################################
# Test 12: file deleted, deleted from index 'pigs-status'
cd "$REF_DIR" || exit
2041 pigs-rm --force a
2041 pigs-status > "$REF_OUT" 2> "$REF_ERR"
REF_EXIT=$?                                 

cd "$OUR_DIR" || exit
pigs-rm --force a
pigs-status > "$OUR_OUT" 2> "$OUR_ERR"
OUR_EXIT=$?                                 

run_test_against_ref 12 "file deleted, deleted from index 'pigs-status'"
#####################################################################
# Test 13: folder structure after file deleted 'pigs-status'
cd "$OUR_DIR" || exit
if
    [ ! -e 'a' ] &&
    [ ! -e '.pig/index/a' ] &&
    [ -e '.pig/logs/unstaged/a' ]
then
    echo "Test 06_13 (folder structure after deleted 'pigs-status') - Passed"
else
    echo "Test 06_13 (folder structure after deleted 'pigs-status') - Failed"
fi
