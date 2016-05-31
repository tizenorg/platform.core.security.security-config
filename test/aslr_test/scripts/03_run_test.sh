#!/bin/sh
#=========================================================
# [First of All] Get the directory path and name of this script
#=========================================================
script_path=$(/usr/bin/readlink -f "$0")
script_dir=`/usr/bin/dirname $script_path`
script_name=`/usr/bin/basename $script_path`
#=========================================================
# Script Begin
#=========================================================
echoI "Script Begin"
#=========================================================
# [Variable]
#=========================================================
input_file="$script_dir/sorted_input.list"
result_file="$script_dir/test_result.csv"
exception_file="$script_dir/scripts/exception.list"
file_ret=
grep_ret=
fail_cnt=
total_cnt=
is_exception=
function testSystemDASLR {
	echoI "Check whether the executable is ASLR applied or not"
	while read line; do
		echoI "$line"
		file_ret=""
		grep_ret=""
    	file_ret=`$script_dir/../utils/file $line`
		grep_ret=`echo $file_ret | $GREP -i "executable" | $GREP "ELF" | $GREP -v "script"`

		total_cnt=$((total_cnt+1))

    	if [ ! "$grep_ret" ]; then
			echoS "$line, OK"
        	echo "$line"",OK" >> $result_file
		else
			is_exception="false"
			while read line2; do
		        if [ "$line" = "$line2" ]; then
					is_exception="true"
				fi
			done < $exception_file
			if [ "$is_exception" = "true" ]; then
				echoS "$line"", OK - Not a target of ASLR test"
				echo "$line"",OK - Not a target of ASLR test" >> $result_file
			else
				echoE "$line, NOK"
                echo "$line"",NOK" >> $result_file
                fail_cnt=$((fail_cnt+1))
			fi
    	fi
	done < $input_file
}

#=========================================================
# [01] Delete previous result
#=========================================================
$RM $result_file
$TOUCH $result_file

#=========================================================
# [01] Delete previous result
#=========================================================
echoI "Test Systemd ASLR"
testSystemDASLR
fnPrintSDone
echo "================================================================"
echo "TOTAL: $total_cnt, NOT APPLIED: $fail_cnt"
echo "================================================================"
echo ""
fnPrintSDone
