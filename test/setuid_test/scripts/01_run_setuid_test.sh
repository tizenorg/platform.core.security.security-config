#!/bin/sh
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
input_file="$script_dir/setuid.list"
result_file="$script_dir/test_result.csv"
exception_list="$script_dir/scripts/exception.list"
is_exception=
setuid_cnt=

function testSetuid {
	echoI "Check setuid"
	find / -perm -4000 -print > $input_file
	while read line; do
		echoI "Check $line"
		is_exception="false"
		while read line2; do
			if [ "$line" = "$line2" ]; then
				is_exception="true"
			fi
		done < $exception_list
		if [ "$is_exception" = "true" ]; then
			ls_ret=`ls -l $line`
			echoS "$ls_ret, OK - Exception"
		else
			ls_ret=`ls -l $line`
			permissions=`echo $ls_ret | cut -d " " -f1`
			user=`echo $ls_ret | cut -d " " -f3`
			group=`echo $ls_ret | cut -d " " -f4`
			echoE "$ls_ret, NOK"
			echo "$line, $permissions, $user, $group" >>$result_file
			setuid_cnt=$((setuid_cnt+1))
		fi
	done < $input_file
}

#=========================================================
# [00] Delete previous result
#=========================================================
rm $result_file
touch $result_file
echo "#FILE, #PERM, #USER, #GROUP" >>$result_file

#=========================================================
# [01] Run Test
#=========================================================
echoI "Test setuid"

testSetuid
if [ "$setuid_cnt" == "" ]; then
	echo "================================================================"
    echo "NO UNPROPER SUID SET"
    echo "================================================================"
    echo ""
else
	echo "================================================================"
	echo "UNPROPER SUID SET: $setuid_cnt"
	echo "================================================================"
	echo ""
fi
fnPrintSDone
