#!/bin/sh
#=========================================================
# [Includes]
#=========================================================
. "/usr/share/security-config/test/utils/_sh_util_lib"
#=========================================================
# Script Begin
#=========================================================
echoI "Script Begin"
#=========================================================
# [Variable]
#=========================================================
input_file="$dep_script_dir/elf.list"
log_file="$dep_script_dir/log.csv"
result_file="$dep_script_dir/result"
file_ret=
grep_ret=
fail_cnt=
tmp_file="$dep_script_dir/tmp.list"
exception_list="$dep_script_dir/scripts/exception.list"
function makeInput {
	$RM $tmp_file
	$TOUCH $tmp_file
	$RM $input_file
	$TOUCH $input_file
	# Find executable and .so*
	$FIND / -type f -perm +111 > $tmp_file
	$FIND / -name *.so >> $tmp_file
	# Remove proc sys dev tmp run
	$SED -i '/^\/proc\//d' $tmp_file
	$SED -i '/^\/sys\//d' $tmp_file
	$SED -i '/^\/dev\//d' $tmp_file
	$SED -i '/^\/tmp\//d' $tmp_file
	$SED -i '/^\/run\//d' $tmp_file
	# Remove *.mo, *.png, *.sh, *.log, *.xml, *.conf, *.mp3, *.mpg, *.wmv, *.gif, *.avi, *.txt, *.socket, *.service file
	$SED -i '/\.mo$/d' $tmp_file
	$SED -i '/\.png$/d' $tmp_file
	$SED -i '/\.sh$/d' $tmp_file
	$SED -i '/\.log$/d' $tmp_file
	$SED -i '/\.xml$/d' $tmp_file
	$SED -i '/\.conf$/d' $tmp_file
	$SED -i '/\.mp3$/d' $tmp_file
	$SED -i '/\.mpg$/d' $tmp_file
	$SED -i '/\.wmv$/d' $tmp_file
	$SED -i '/\.gif$/d' $tmp_file
	$SED -i '/\.avi$/d' $tmp_file
	$SED -i '/\.txt$/d' $tmp_file
	$SED -i '/\.socket$/d' $tmp_file
	$SED -i '/\.service$/d' $tmp_file

	while read line; do
		$FILE $line | $GREP "ELF" | $CUT -d ":" -f 1 >> $input_file
	done < $tmp_file
	$RM $tmp_file
}

function testDEP {
	echoI "Check STACK Flag"
	while read line; do
		grep_ret=""
		echoI "Check $line"
		grep_ret=`$READELF -l $line | $GREP "STACK" | $GREP "RWE"`

    	if [ ! "$grep_ret" ]; then
			echoS "$line, OK"
        	echo "$line"",OK" >> $log_file
		else
			is_exception="false"
			while read line2; do
				if [ "$line" = "$line2" ]; then
					is_exception="true"
				fi
			done < $exception_list
			if [ "$is_exception" = "true" ]; then
				echoS "$line"", OK - Not a target of DEP test"
				echo "$line"",OK - Not a target of DEP test" >> $log_file
			else
				echoE "$line, NOK"
				echo "$line"",NOK" >> $log_file
				fail_cnt=$((fail_cnt+1))
			fi
    	fi
	done < $input_file
	$RM $input_file
}

#=========================================================
# [01] Delete previous result
#=========================================================
$RM $log_file
$TOUCH $log_file
$RM $result_file
$TOUCH $result_file

#=========================================================
# [02] Make List
#=========================================================
echoI "Make List"
makeInput
fnPrintSDone

#=========================================================
# [01] Run Test
#=========================================================
echoI "Test DEP"

testDEP
echo "================================================================"
if [ $((fail_cnt)) -lt 0 ]; then
	echo "NO STACK RWE"
	echo "YES" > $result_file
else
	echo "STACK RWE: $((fail_cnt))"
	echo "NO" > $result_file
fi
echo "================================================================"
echo ""
fnPrintSDone
