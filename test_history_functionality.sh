#!/bin/bash

cp ~/.bash_history_backup ~/.bash_history_backup_BEFORE_TEST
main_script_path="/usr/local/bin/bash_history_backup.sh"

# Test helper functions
function create_test_file() {
    local filename=$1
    local lines=$2
    rm -f "$filename"
    for i in $(seq 1 $lines); do
        echo "Line $i" >> "$filename"
    done
}

function assert_history_length() {
    local expected=$1
    local actual=$(wc -l < ~/.bash_history)
    if [ "$actual" -eq "$expected" ]; then
        echo "Test passed: Expected $expected lines, found $actual lines"
    else
        echo "Test failed: Expected $expected lines, found $actual lines"
    fi
}

# Test cases

# Test 1: Restore when backup has more lines
create_test_file ~/.bash_history 10
create_test_file ~/.bash_history_backup 20
$main_script_path restore
assert_history_length 20

# Test 2: Restore when current history has more lines
create_test_file ~/.bash_history 30
create_test_file ~/.bash_history_backup 20
$main_script_path restore
assert_history_length 30

# Test 3: Backup command
create_test_file ~/.bash_history 40
$main_script_path backup
assert_history_length 40

backup_lines=$(wc -l < ~/.bash_history_backup)
if [ "$backup_lines" -eq 40 ]; then
    echo "Test passed: Backup has the same number of lines as the original file"
else
    echo "Test failed: Backup has a different number of lines than the original file"
fi

# Test 4: Restore when backup file does not exist
rm ~/.bash_history_backup
create_test_file ~/.bash_history 50
$main_script_path restore
assert_history_length 50

# Test 5: Restore when both files have the same number of lines
create_test_file ~/.bash_history 60
create_test_file ~/.bash_history_backup 60
$main_script_path restore
assert_history_length 60

# Test 6: Restore when backup file is empty
create_test_file ~/.bash_history 70
echo -n > ~/.bash_history_backup
$main_script_path restore
assert_history_length 70

# Test 7: Restore when current history is empty
echo -n > ~/.bash_history
create_test_file ~/.bash_history_backup 80
$main_script_path restore
assert_history_length 80




# Test 8: Start and stop the service
sudo systemctl restart bash_history_backup.service
sudo systemctl stop bash_history_backup.service

current_history_lines=$(wc -l < ~/.bash_history)
backup_history_lines=$(wc -l < ~/.bash_history_backup)

if [ "$backup_history_lines" -eq "$current_history_lines" ]; then
    echo "Test passed: Starting and stopping the service preserves history"
else
    echo "Test failed: Starting and stopping the service alters history"
fi

# and this resets the history again

sudo systemctl restart bash_history_backup.service
cp ~/.bash_history_backup_BEFORE_TEST ~/.bash_history_backup


# the true test... bring the original bash_history back
bash_history_backup.sh restore
