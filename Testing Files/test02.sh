#!/bin/dash
# 
# Tests pigs-commit
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
        echo "Test 02_$TEST_NUM ($DESCRIPTION) - Passed"
    else
        echo "Test 02_$TEST_NUM ($DESCRIPTION) - Failed"
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
# Test 1: no repo 'pigs-commit'
cd "$REF_DIR" || exit
2041 pigs-commit > "$REF_OUT" 2> "$REF_ERR"
REF_EXIT=$?                                 

cd "$OUR_DIR" || exit
pigs-commit > "$OUR_OUT" 2> "$OUR_ERR"
OUR_EXIT=$?                                 

run_test_against_ref 1 "no repo 'pigs-commit'"
#####################################################################
# Create .pig repo
cd "$REF_DIR" || exit
2041 pigs-init > "$REF_OUT" 2> "$REF_ERR"
ls -d .pig >> "$REF_OUT" 2> "$REF_ERR"      
cd "$OUR_DIR" || exit
pigs-init > "$OUR_OUT" 2> "$OUR_ERR"
ls -d .pig >> "$OUR_OUT" 2> "$OUR_ERR" 
#####################################################################
# Test 2: simple wrong num args 'pigs-commit'
cd "$REF_DIR" || exit
2041 pigs-commit > "$REF_OUT" 2> "$REF_ERR"
REF_EXIT=$?                                 

cd "$OUR_DIR" || exit
pigs-commit > "$OUR_OUT" 2> "$OUR_ERR"
OUR_EXIT=$?                                 

run_test_against_ref 2 "simple wrong num args 'pigs-commit'"
#####################################################################
# Test 3: extended wrong num args 'pigs-commit'
cd "$REF_DIR" || exit
2041 pigs-commit a > "$REF_OUT" 2> "$REF_ERR"
REF_EXIT=$?                                 

cd "$OUR_DIR" || exit
pigs-commit a > "$OUR_OUT" 2> "$OUR_ERR"
OUR_EXIT=$?                                 

run_test_against_ref 3 "extended wrong num args 'pigs-commit'"
#####################################################################
# Test 4: nothing to commit 'pigs-commit -a -m'
cd "$REF_DIR" || exit
2041 pigs-commit -a -m hello > "$REF_OUT" 2> "$REF_ERR"
REF_EXIT=$?                                 

cd "$OUR_DIR" || exit
pigs-commit -a -m hello > "$OUR_OUT" 2> "$OUR_ERR"
OUR_EXIT=$?                                 

run_test_against_ref 4 "nothing to commit 'pigs-commit -a -m'"
#####################################################################
# Test 5: folder structure 'pigs-commit -a -m'
cd "$OUR_DIR" || exit
if
    [ ! -e '.pig/logs/staged/a' ] &&
    [ ! -e '.pig/logs/unstaged/a' ]

then
    echo "Test 02_5 (folder structure 'pigs-commit') - Passed"
else
    echo "Test 02_5 (folder structure 'pigs-commit') - Failed"
fi
#####################################################################
# add a to index
cd "$REF_DIR" || exit
touch a
2041 pigs-add 'a' > "$REF_OUT" 2> "$REF_ERR"

cd "$OUR_DIR" || exit
touch a
pigs-add 'a' > "$OUR_OUT" 2> "$OUR_ERR"
#####################################################################
# Test 6: folder structure after staged 'pigs-commit -a -m'
cd "$OUR_DIR" || exit
if
    [ ! -e '.pig/logs/staged/a' ] &&
    [ -e '.pig/logs/unstaged/a' ]

then
    echo "Test 02_6 (folder structure after staged 'pigs-commit') - Passed"
else
    echo "Test 02_6 (folder structure after staged 'pigs-commit') - Failed"
fi
#####################################################################
# Test 7: successful 'pigs-commit -m'
cd "$REF_DIR" || exit
2041 pigs-commit -m "first commit" > "$REF_OUT" 2> "$REF_ERR"
REF_EXIT=$?                                 

cd "$OUR_DIR" || exit
pigs-commit -m "first commit" > "$OUR_OUT" 2> "$OUR_ERR"
OUR_EXIT=$?                                 

run_test_against_ref 7 "successful changes 'pigs-commit -m'"
#####################################################################
# Test 8: folder structure after initial commit 'pigs-commit -a -m'
cd "$OUR_DIR" || exit
if
    [ -e '.pig/logs/staged/a' ] &&
    [ ! -e '.pig/logs/unstaged/a' ] &&
    [ -e '.pig/logs/history/commit_0/a' ]

then
    echo "Test 02_8 (folder structure after initial 'pigs-commit') - Passed"
else
    echo "Test 02_8 (folder structure after initial 'pigs-commit') - Failed"
fi
#####################################################################
# Test 9: unsuccessful 'pigs-commit -m -a'
cd "$REF_DIR" || exit
touch b c d
2041 pigs-commit -a -m "b c d written" > "$REF_OUT" 2> "$REF_ERR"
REF_EXIT=$?                                 

cd "$OUR_DIR" || exit
touch b c d
pigs-commit -a -m "b c d written" > "$OUR_OUT" 2> "$OUR_ERR"
OUR_EXIT=$?                                 

run_test_against_ref 9 "unsuccessful changes 'pigs-commit -m -a'"
#####################################################################
# Test 10: successful 'pigs-commit -m -a'
cd "$REF_DIR" || exit
seq 1 7 >a
2041 pigs-commit -a -m "a updated agin" > "$REF_OUT" 2> "$REF_ERR"
REF_EXIT=$?                                 

cd "$OUR_DIR" || exit
seq 1 7 >a
pigs-commit -a -m "a updated agin" > "$OUR_OUT" 2> "$OUR_ERR"
OUR_EXIT=$?                                 

run_test_against_ref 10 "successful 'pigs-commit -m -a'"
#####################################################################
# Test 11: successful edited file 'pigs-commit -m'
cd "$REF_DIR" || exit
seq 1 7 >b
2041 pigs-add b
2041 pigs-commit -m "added updated b" > "$REF_OUT" 2> "$REF_ERR"
REF_EXIT=$?                                 

cd "$OUR_DIR" || exit
seq 1 7 >b
pigs-add b
pigs-commit -m "added updated b" > "$OUR_OUT" 2> "$OUR_ERR"
OUR_EXIT=$?                                 

run_test_against_ref 11 "successful edited file 'pigs-commit -m'"
#####################################################################
# Test 12: folder structure after commits 'pigs-commit -a -m'
cd "$OUR_DIR" || exit
if
    [ -e '.pig/logs/staged/b' ] &&
    [ ! -e '.pig/logs/unstaged/b' ] &&
    [ -e '.pig/logs/history/commit_0/a' ] &&
    [ ! -e '.pig/logs/history/commit_0/b' ] &&
    [ -e '.pig/logs/history/commit_2/b' ]
then
    echo "Test 02_12 (folder structure after commits 'pigs-commit') - Passed"
else
    echo "Test 02_12 (folder structure after commits 'pigs-commit') - Failed"
fi
