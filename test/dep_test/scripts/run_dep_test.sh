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
tmp2_file="$dep_script_dir/tmp2.list"
exception_list="$dep_script_dir/exception.list"
function makeInput {
	$RM $tmp_file
	$TOUCH $tmp_file
	$RM $tmp2_file
	$TOUCH $tmp2_file
	$RM $input_file
	$TOUCH $input_file
	# Find executable and .so*
	$FIND / -type f -perm +111 > $tmp2_file
	$FIND / -name *.so >> $tmp2_file
	$CAT $tmp2_file | $SORT | $UNIQ > $tmp_file
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
		$utils_dir/file $line | $GREP "ELF" | $CUT -d ":" -f 1 >> $input_file
	done < $tmp_file
	$RM $tmp_file
	$RM $tmp2_file
}

function testDEP {
	echoI "Check STACK Flag"
	while read line; do
		grep_ret=""
		echoI "Check $line"
		grep_ret=`$utils_dir/readelf -l $line | $GREP "STACK" | $GREP "RWE"`

    	if [ ! "$grep_ret" ]; then
			echoS "$line, OK"
		else
			is_exception="false"
			while read line2; do
				if [ "$line" = "$line2" ]; then
					is_exception="true"
				fi
			done < $exception_list
			if [ "$is_exception" = "true" ]; then
				echoS "$line"", OK - Not a target of DEP test"
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

LIBDW="libdw-0.153.so"
lib_dir=
# Rename utils
file_cmd=`$FIND $utils_dir -name file.*`
readelf_cmd=`$FIND $utils_dir -name readelf.*`
if [ "$file_cmd" != "" ]; then
    $MV $file_cmd $utils_dir/file
fi
if [ "$readelf_cmd" != "" ]; then
    $MV $readelf_cmd $utils_dir/readelf
fi

# Set lib_dir
if [ -d "/usr/lib64" ]; then
    lib_dir="/usr/lib64"
elif [ -d "/usr/lib" ]; then
    lib_dir="/usr/lib"
else
    echo "No proper lib dir"
    exit 1
fi
echo "lib_dir = $lib_dir"

arch_info=`$utils_dir/file $utils_dir/file`
if [[ $arch_info == *"aarch64"* ]]
then
	echo "aarch64!!"
	arch="aarch64"
elif [[ $arch_info == *"ARM"* ]]
then
	echo "arm!!"
	arch="arm"
elif [[ $arch_info == *"x86-64"* ]]
then
	echo "x86_64!!"
	arch="x86_64"
elif [[ $arch_info == *"Intel"* ]]
then
	echo "i386!!"
	arch="i386"
fi

# Set required utils
libdw_lib=`$FIND $dep_script_dir -name utillib.$arch`
if [ "$libdw_lib" != "" ]; then
    $MV $libdw_lib $dep_script_dir/"$LIBDW"
    $CP $dep_script_dir/$LIBDW $lib_dir
    $LN $lib_dir/$LIBDW $lib_dir/libdw.so.1
fi

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
if [ $((fail_cnt)) -lt 1 ]; then
	echo "NO STACK RWE"
	echo "YES" > $result_file
	$RM $log_file
else
	echo "STACK RWE: $((fail_cnt))"
	echo "NO" > $result_file
fi
echo "================================================================"
echo ""

if [ ! -d $log_dir ]; then
    echo "make log dir"
    $MKDIR $log_dir
else
    echo "log dir exist"
fi
if [ ! -d $result_dir ]; then
    echo "make result dir"
    $MKDIR $result_dir
else
    echo "result dir exist"
fi
if [ -a $dep_script_dir/log.csv ]; then
	$MV $dep_script_dir/log.csv $log_dir/dep_test.log
fi
$MV $dep_script_dir/result $result_dir/dep_test.result

if [ "$libdw_lib" != "" ]; then
	rm $lib_dir/libdw*
fi
fnPrintSDone
