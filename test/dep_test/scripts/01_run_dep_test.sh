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
input_file="$script_dir/elf.list"
result_file="$script_dir/test_result.csv"
file_ret=
grep_ret=
fail_cnt=
tmp_file="$script_dir/tmp.list"
function makeInput {
	rm $tmp_file
	touch $tmp_file
	rm $input_file
	touch $input_file
	# Find executable and .so*
	find / -type f -perm +111 > $tmp_file
	find / -name *.so >> $tmp_file
	# Remove proc sys dev tmp run
	sed -i '/^\/proc\//d' $tmp_file
	sed -i '/^\/sys\//d' $tmp_file
	sed -i '/^\/dev\//d' $tmp_file
	sed -i '/^\/tmp\//d' $tmp_file
	sed -i '/^\/run\//d' $tmp_file
	# Remove *.mo, *.png, *.sh, *.log, *.xml, *.conf, *.mp3, *.mpg, *.wmv, *.gif, *.avi, *.txt, *.socket, *.service file
	sed -i '/\.mo$/d' $tmp_file
	sed -i '/\.png$/d' $tmp_file
	sed -i '/\.sh$/d' $tmp_file
	sed -i '/\.log$/d' $tmp_file
	sed -i '/\.xml$/d' $tmp_file
	sed -i '/\.conf$/d' $tmp_file
	sed -i '/\.mp3$/d' $tmp_file
	sed -i '/\.mpg$/d' $tmp_file
	sed -i '/\.wmv$/d' $tmp_file
	sed -i '/\.gif$/d' $tmp_file
	sed -i '/\.avi$/d' $tmp_file
	sed -i '/\.txt$/d' $tmp_file
	sed -i '/\.socket$/d' $tmp_file
	sed -i '/\.service$/d' $tmp_file

	while read line; do
		$script_dir/../utils/file $line | grep "ELF" | cut -d ":" -f 1 >> $input_file
	done < $tmp_file
	rm $tmp_file
}

function testDEP {
	echoI "Check STACK Flag"
	while read line; do
		grep_ret=""
		echoI "Check $line"	
		grep_ret=`$script_dir/../utils/readelf -l $line | grep "STACK" | grep "RWE"`

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
rm $result_file
touch $result_file

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
