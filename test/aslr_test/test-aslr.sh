#!/bin/bash
#=========================================================
# [Includes]
#=========================================================
. "/usr/share/security-config/test/utils/_sh_util_lib"
#=========================================================
# Script Begin
#=========================================================
echoI "Script Begin"

# Rename utils
file_cmd=`$FIND $utils_dir -name file.*`
readelf_cmd=`$FIND $utils_dir -name readelf.*`
if [ "$file_cmd" != "" ]; then
	$MV $file_cmd $utils_dir/file
fi
if [ "$readelf_cmd" != "" ]; then
	$MV $readelf_cmd $utils_dir/readelf
fi

source $aslr_script_dir/scripts/run_aslr_test.sh

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
$MV $aslr_script_dir/log.csv $log_dir/aslr_test.log
$MV $aslr_script_dir/result $result_dir/aslr_test.result

