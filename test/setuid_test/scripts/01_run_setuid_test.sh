#!/bin/sh
#=========================================================
# Script Begin
#=========================================================
echoI "Script Begin"
#=========================================================
# [Variable]
#=========================================================
input_file="$suid_script_dir/setuid.list"
exception_list="$suid_script_dir/scripts/exception.list"
is_exception=
setuid_cnt=
result_file="$suid_script_dir/result"
log_file="$suid_script_dir/log.csv"
function testSetuid {
	echoI "Check setuid"
	$FIND / -perm -4000 -print > $input_file
	while read line; do
		echoI "Check $line"
		is_exception="false"
		while read line2; do
			if [ "$line" = "$line2" ]; then
				is_exception="true"
			fi
		done < $exception_list
		if [ "$is_exception" = "true" ]; then
			ls_ret=`$LS -l $line`
			echoS "$ls_ret, OK - Exception"
		else
			ls_ret=`$LS -l $line`
			permissions=`echo $ls_ret | $CUT -d " " -f1`
			user=`echo $ls_ret | $CUT -d " " -f3`
			group=`echo $ls_ret | $CUT -d " " -f4`
			echoE "$ls_ret, NOK"
			echo "$line, $permissions, $user, $group" >>$log_file
			setuid_cnt=$((setuid_cnt+1))
		fi
	done < $input_file
	$RM $input_file
}

#=========================================================
# [00] Delete previous result
#=========================================================
$RM $log_file
$TOUCH $log_file
$RM $result_file
$TOUCH $result_file
echo "#FILE, #PERM, #USER, #GROUP" >>$log_file

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
	echo "O" > $result_file
else
	echo "================================================================"
	echo "UNPROPER SUID SET: $setuid_cnt"
	echo "================================================================"
	echo ""
	echo "X" > $result_file
fi
fnPrintSDone
