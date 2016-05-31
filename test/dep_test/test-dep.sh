#!/bin/bash
#=========================================================
# [Includes]
#=========================================================
. "/usr/share/security-config/test/utils/_sh_util_lib"
#=========================================================
# Script Begin
#=========================================================
echoI "Script Begin"
LIBDW="libdw-0.153.so"
# Set required utils
if [ -a "$utils_dir/$LIBDW" ]; then
    $CP $utils_dir/libdw* /usr/lib/
    $LN /usr/lib/libdw-0.153.so /usr/lib/libdw.so.1
fi

# Run test
source $dep_script_dir/scripts/01_run_dep_test.sh

# Move result files
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

$MV $dep_script_dir/result $result_dir/dep_result
$MV $dep_script_dir/log.csv $log_dir/dep_log.csv

# Remove utils
if [ -a "/usr/bin/$LIBDW" ]; then
	$RM /usr/lib/libdw*
fi
