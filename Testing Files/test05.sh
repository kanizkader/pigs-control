#!/bin/dash
# 
# Tests pigs-rm
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
        echo "Test 05_$TEST_NUM ($DESCRIPTION) - Passed"
    else
        echo "Test 05_$TEST_NUM ($DESCRIPTION) - Failed"
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
# Test 1: no repo 'pigs-rm'
cd "$REF_DIR" || exit
2041 pigs-rm > "$REF_OUT" 2> "$REF_ERR"
REF_EXIT=$?                                 # check exit status

cd "$OUR_DIR" || exit
pigs-rm > "$OUR_OUT" 2> "$OUR_ERR"
OUR_EXIT=$?                                 # check exit status

run_test_against_ref 1 "no repo 'pigs-rm'"
#####################################################################
# Create .pig repo
cd "$REF_DIR" || exit
2041 pigs-init > "$REF_OUT" 2> "$REF_ERR"
ls -d .pig >> "$REF_OUT" 2> "$REF_ERR"      
cd "$OUR_DIR" || exit
pigs-init > "$OUR_OUT" 2> "$OUR_ERR"
ls -d .pig >> "$OUR_OUT" 2> "$OUR_ERR" 
#####################################################################
# Test 2: wrong num args 'pigs-rm'
cd "$REF_DIR" || exit
2041 pigs-rm > "$REF_OUT" 2> "$REF_ERR"
REF_EXIT=$?                                 

cd "$OUR_DIR" || exit
pigs-rm > "$OUR_OUT" 2> "$OUR_ERR"
OUR_EXIT=$?                                 

run_test_against_ref 2 "wrong num args 'pigs-rm'"
#####################################################################
# Test 3: not in repo 'pigs-rm'
cd "$REF_DIR" || exit
2041 pigs-rm a > "$REF_OUT" 2> "$REF_ERR"
REF_EXIT=$?                                 

cd "$OUR_DIR" || exit
pigs-rm a > "$OUR_OUT" 2> "$OUR_ERR"
OUR_EXIT=$?                                 

run_test_against_ref 3 "not in repo 'pigs-rm'"
#####################################################################
# Test 4: unsuccessful staged changes in index 'pigs-rm'
cd "$REF_DIR" || exit
touch a
2041 pigs-add a
2041 pigs-rm a > "$REF_OUT" 2> "$REF_ERR"
REF_EXIT=$?     

cd "$OUR_DIR" || exit
touch a
pigs-add a
pigs-rm a > "$OUR_OUT" 2> "$OUR_ERR"
OUR_EXIT=$?                                 

run_test_against_ref 4 "unsuccessful staged changes in index 'pigs-rm'"
#####################################################################
# Test 5: folder structure after staged 'pigs-rm'
cd "$OUR_DIR" || exit
if
    [ -e '.pig/logs/unstaged/a' ] &&
    [ -e '.pig/index/a' ]
then
    echo "Test 05_5 (folder structure after staged 'pigs-rm') - Passed"
else
    echo "Test 05_5 (folder structure after staged 'pigs-rm') - Failed"
fi
#####################################################################
# Test 6: unsuccessful diff between repo vs working dir 'pigs-rm'
cd "$REF_DIR" || exit
2041 pigs-commit -m a > /dev/null
seq 1 7 >a
2041 pigs-rm a > "$REF_OUT" 2> "$REF_ERR"
REF_EXIT=$?     

cd "$OUR_DIR" || exit
pigs-commit -m a > /dev/null
seq 1 7 >a
pigs-rm a > "$OUR_OUT" 2> "$OUR_ERR"
OUR_EXIT=$?      

MSG="unsuccessful diff between repo vs working dir 'pigs-rm'"
run_test_against_ref 6 "$MSG"
#####################################################################
# Test 7: unsuccessful diff between repo vs working dir vs index 'pigs-rm'
cd "$REF_DIR" || exit
touch b
2041 pigs-add b
2041 pigs-commit -m b > /dev/null
seq 1 7 >b
2041 pigs-add b
seq 8 10 >b
2041 pigs-rm b > "$REF_OUT" 2> "$REF_ERR"
REF_EXIT=$?     

cd "$OUR_DIR" || exit
touch b
pigs-add b
pigs-commit -m b > /dev/null
seq 1 7 >b
pigs-add b
seq 8 10 >b
pigs-rm b > "$OUR_OUT" 2> "$OUR_ERR"
OUR_EXIT=$?                                 

MSG="unsuccessful diff between repo vs working dir vs index 'pigs-rm'"
run_test_against_ref 7 "$MSG"
#####################################################################
# Test 8: successful without cached or force 'pigs-rm'
cd "$REF_DIR" || exit
touch c
2041 pigs-add c
2041 pigs-commit -m "committed" > /dev/null
2041 pigs-rm c > "$REF_OUT" 2> "$REF_ERR"
REF_EXIT=$?                                 

cd "$OUR_DIR" || exit
touch c
pigs-add c
pigs-commit -m "committed" > /dev/null
pigs-rm c > "$OUR_OUT" 2> "$OUR_ERR"
OUR_EXIT=$?                                 

run_test_against_ref 8 "successful without cached or force 'pigs-rm'"
#####################################################################
# Test 9: folder structure after deletions 'pigs-rm'
cd "$OUR_DIR" || exit
if
    [ ! -e 'c' ] &&
    [ ! -e '.pig/index/c' ]
then
    echo "Test 05_9 (folder structure after deletion 'pigs-rm') - Passed"
else
    echo "Test 05_9 (folder structure after deletion 'pigs-rm') - Failed"
fi
#####################################################################
# Test 10: successful with cached 'pigs-rm'
cd "$REF_DIR" || exit
touch c
2041 pigs-add c
2041 pigs-commit -m "committed" > /dev/null
2041 pigs-rm --cached c > "$REF_OUT" 2> "$REF_ERR"
REF_EXIT=$?                                 

cd "$OUR_DIR" || exit
touch c
pigs-add c
pigs-commit -m "committed" > /dev/null
pigs-rm --cached c > "$OUR_OUT" 2> "$OUR_ERR"
OUR_EXIT=$?                                 

run_test_against_ref 10 "successful with cached 'pigs-rm'"
#####################################################################
# Test 11: folder structure after cached deletions 'pigs-rm'
cd "$OUR_DIR" || exit
if
    [ -e 'c' ] &&
    [ ! -e '.pig/index/c' ]
then
    echo "Test 05_11 (folder structure after deletion 'pigs-rm') - Passed"
else
    echo "Test 05_11 (folder structure after deletion 'pigs-rm') - Failed"
fi
#####################################################################
# Test 12: unsuccessful diff repo vs working dir vs index 'pigs-rm --cached'
cd "$REF_DIR" || exit
touch c
2041 pigs-add c
2041 pigs-commit -m "committed" > /dev/null
2041 pigs-rm --cached c > "$REF_OUT" 2> "$REF_ERR"
REF_EXIT=$?                                 

cd "$OUR_DIR" || exit
touch c
pigs-add c
pigs-commit -m "committed" > /dev/null
pigs-rm --cached c > "$OUR_OUT" 2> "$OUR_ERR"
OUR_EXIT=$?   

MSG="unsuccessful diff repo vs working dir vs index 'pigs-rm --cached --force'"
run_test_against_ref 12 "$MSG"
#####################################################################
# Test 13: successful diff repo vs working dir vs index 
# 'pigs-rm --cached --force'

cd "$REF_DIR" || exit
touch d
2041 pigs-add d
2041 pigs-commit -m "committed" > /dev/null
2041 pigs-rm --force --cached d > "$REF_OUT" 2> "$REF_ERR"
REF_EXIT=$?                                 

cd "$OUR_DIR" || exit
touch d
pigs-add d
pigs-commit -m "committed" > /dev/null
pigs-rm --force --cached d > "$OUR_OUT" 2> "$OUR_ERR"
OUR_EXIT=$?                                 

MSG="successful diff repo vs working dir vs index 'pigs-rm --cached --force'"
run_test_against_ref 13 "$MSG"
#####################################################################
# Test 14: successful diff repo vs working dir vs index 
# 'pigs-rm --force'

cd "$REF_DIR" || exit
touch d
2041 pigs-add d
2041 pigs-commit -m "committed" > /dev/null
2041 pigs-rm --force d > "$REF_OUT" 2> "$REF_ERR"
REF_EXIT=$?                                 

cd "$OUR_DIR" || exit
touch d
pigs-add d
pigs-commit -m "committed" > /dev/null
pigs-rm --force d > "$OUR_OUT" 2> "$OUR_ERR"
OUR_EXIT=$?                                 

MSG="successful diff repo vs working dir vs index 'pigs-rm --force'"
run_test_against_ref 14 "$MSG"
#####################################################################
# Test 15: not in repo 'pigs-rm --force'
cd "$REF_DIR" || exit
2041 pigs-rm --force x > "$REF_OUT" 2> "$REF_ERR"
REF_EXIT=$?                                 

cd "$OUR_DIR" || exit
pigs-rm --force x > "$OUR_OUT" 2> "$OUR_ERR"
OUR_EXIT=$?                                 

run_test_against_ref 15 "not in repo 'pigs-rm --force'"
#####################################################################
# Test 16: not in repo 'pigs-rm --cached'
cd "$REF_DIR" || exit
2041 pigs-rm --cached x > "$REF_OUT" 2> "$REF_ERR"
REF_EXIT=$?                                 

cd "$OUR_DIR" || exit
pigs-rm --cached x > "$OUR_OUT" 2> "$OUR_ERR"
OUR_EXIT=$?                                 

run_test_against_ref 16 "not in repo 'pigs-rm --cached'"
#####################################################################
# Test 17: not in repo 'pigs-rm --force --cached'
cd "$REF_DIR" || exit
2041 pigs-rm --force --cached x > "$REF_OUT" 2> "$REF_ERR"
REF_EXIT=$?                                 

cd "$OUR_DIR" || exit
pigs-rm --force --cached x > "$OUR_OUT" 2> "$OUR_ERR"
OUR_EXIT=$?                                 

run_test_against_ref 17 "not in repo 'pigs-rm --force --cached'"
#####################################################################
# Test 18: folder structure after deletions 'pigs-rm'
cd "$OUR_DIR" || exit
if
    [ ! -e 'd' ] &&
    [ ! -e '.pig/index/d' ] &&
    [ -e '.pig/logs/staged/d' ] &&
    [ ! -e '.pig/logs/unstaged/d' ]
then
    echo "Test 05_18 (folder structure after deletion 'pigs-rm') - Passed"
else
    echo "Test 05_18 (folder structure after deletion 'pigs-rm') - Failed"
fi
