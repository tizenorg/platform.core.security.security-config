#!/bin/bash
#=========================================================
# [First of All] Get the directory path and name of this script
#=========================================================
script_path=$(readlink -f "$0")
script_dir=`dirname $script_path`
script_name=`basename $script_path`
#=========================================================
# Script Begin
#=========================================================
echoI "Script Begin"
#=========================================================
# [Variable]
#=========================================================
input_file="$script_dir/all_systemd_executable.list"
result_name="$script_dir/test_result.list"
tmp_file="$script_dir/tmp.list"
sorted_input_file="$script_dir/sorted_input.list"
file_ret=
grep_ret=
success_cnt=
fail_cnt=
total_cnt=

function sortInput {

	#sdb pull /opt/usr/tc/aslr/$input_file
	$SORT $input_file > $tmp_file
	$CAT $tmp_file | $UNIQ > $sorted_input_file
	$RM $tmp_file
	$RM $input_file
}

#=========================================================
# [01] Sort Input
#=========================================================
echoI "sort Input"
sortInput
fnPrintSDone
