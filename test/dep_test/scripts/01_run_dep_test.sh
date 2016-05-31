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
input_file="$script_dir/elf.list"
result_file="$script_dir/test_result.csv"
file_ret=
grep_ret=
fail_cnt=
tmp_file="$script_dir/tmp.list"
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
		$script_dir/../utils/file $line | $GREP "ELF" | $CUT -d ":" -f 1 >> $input_file
	done < $tmp_file
	$RM $tmp_file
}

function testDEP {
	echoI "Check STACK Flag"
	while read line; do
		grep_ret=""
		echoI "Check $line"
		grep_ret=`$script_dir/../utils/readelf -l $line | $GREP "STACK" | $GREP "RWE"`

    	if [ ! "$grep_ret" ]; then
			echoS "$line, OK"
        	echo "$line"",OK" >> $result_file
		else
			echoE "$line, NOK"
			echo "$line"",NOK" >> $result_file
			fail_cnt=$((fail_cnt+1))
    	fi
	done < $input_file
}

#=========================================================
# [01] Delete previous result
#=========================================================
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
if [ "$fail_cnt" == "" ]; then
	echo "NO STACK RWE"
else
	echo "STACK RWE: $fail_cnt"
fi
echo "================================================================"
echo ""
fnPrintSDone
