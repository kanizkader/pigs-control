#!/bin/dash
# 
# Tests pigs-add
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
        echo "Test 01_$TEST_NUM ($DESCRIPTION) - Passed"
    else
        echo "Test 01_$TEST_NUM ($DESCRIPTION) - Failed"
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
# Test 1: no repo 'pigs-add'

cd "$REF_DIR" || exit
2041 pigs-add > "$REF_OUT" 2> "$REF_ERR"
REF_EXIT=$?                                 

cd "$OUR_DIR" || exit
pigs-add > "$OUR_OUT" 2> "$OUR_ERR"
OUR_EXIT=$?                                 

run_test_against_ref 1 "no repo 'pigs-add'"
#####################################################################
# Create .pig repo
cd "$REF_DIR" || exit
2041 pigs-init > "$REF_OUT" 2> "$REF_ERR"
ls -d .pig >> "$REF_OUT" 2> "$REF_ERR"      
cd "$OUR_DIR" || exit
pigs-init > "$OUR_OUT" 2> "$OUR_ERR"
ls -d .pig >> "$OUR_OUT" 2> "$OUR_ERR"      
#####################################################################
# Test 2: incorrect args 'pigs-add'

cd "$REF_DIR" || exit
2041 pigs-add > "$REF_OUT" 2> "$REF_ERR"
REF_EXIT=$?                                 

cd "$OUR_DIR" || exit
pigs-add > "$OUR_OUT" 2> "$OUR_ERR"
OUR_EXIT=$?                                 

run_test_against_ref 2 "incorrect args 'pigs-add'"
#####################################################################
# Test 3: invalid filename 'pigs-add'

cd "$REF_DIR" || exit
2041 pigs-add '*.txt' > "$REF_OUT" 2> "$REF_ERR"
REF_EXIT=$?                                 

cd "$OUR_DIR" || exit
pigs-add '*.txt' > "$OUR_OUT" 2> "$OUR_ERR"
OUR_EXIT=$?                                 

run_test_against_ref 3 "invalid filename 'pigs-add'"
#####################################################################
# Test 4: filename doesn't exist 'pigs-add'

cd "$REF_DIR" || exit
2041 pigs-add 'a.txt' > "$REF_OUT" 2> "$REF_ERR"
REF_EXIT=$?                                 

cd "$OUR_DIR" || exit
pigs-add 'a.txt' > "$OUR_OUT" 2> "$OUR_ERR"
OUR_EXIT=$?                                 

run_test_against_ref 4 "filename doesn't exist 'pigs-add'"
#####################################################################
# Test 5: successful one arg 'pigs-add'

cd "$REF_DIR" || exit
touch a.txt
2041 pigs-add 'a.txt' > "$REF_OUT" 2> "$REF_ERR"
REF_EXIT=$?                                 

cd "$OUR_DIR" || exit
touch a.txt
pigs-add 'a.txt' > "$OUR_OUT" 2> "$OUR_ERR"
OUR_EXIT=$?                                 

run_test_against_ref 5 "successful one arg 'pigs-add'"
#####################################################################
# Test 6: successful multiple arg 'pigs-add'

cd "$REF_DIR" || exit
touch b.txt c d
seq 1 7 >a.txt
2041 pigs-add 'a.txt' 'b.txt' 'c' 'd' > "$REF_OUT" 2> "$REF_ERR"
REF_EXIT=$?                                 

cd "$OUR_DIR" || exit
touch b.txt c d
seq 1 7 >a.txt
pigs-add 'a.txt' 'b.txt' 'c' 'd' > "$OUR_OUT" 2> "$OUR_ERR"
OUR_EXIT=$?                                 

run_test_against_ref 6 "successful multiple args 'pigs-add'"
#####################################################################
# Test 7: folder structure 'pigs-add'
cd "$OUR_DIR" || exit
if
    [ -d '.pig/index' ] &&
    [ -e '.pig/index/a.txt' ] &&
    [ -e '.pig/index/b.txt' ] &&
    [ -e '.pig/index/c' ] &&
    [ -e '.pig/index/d' ] &&
    [ -e '.pig/logs/unstaged/a.txt' ] &&
    [ -e '.pig/logs/unstaged/b.txt' ] &&
    [ -e '.pig/logs/unstaged/c' ] &&
    [ -e '.pig/logs/unstaged/d' ] &&
    [ ! -e '.pig/logs/staged/a.txt' ] &&
    [ ! -e '.pig/logs/staged/b.txt' ] &&
    [ ! -e '.pig/logs/staged/c' ] &&
    [ ! -e '.pig/logs/staged/d' ]
then
    echo "Test 01_7 (folder structure 'pigs-add') - Passed"
else
    echo "Test 01_7 (folder structure 'pigs-add') - Failed"
fi
