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
lib_dir=
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

# Set required utils
if [ -a "$utils_dir/$LIBDW" ]; then
    $CP $utils_dir/libdw* $lib_dir
    $LN $lib_dir/libdw-0.153.so $lib_dir/libdw.so.1
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

$MV $dep_script_dir/result $result_dir/dep_test.result
$MV $dep_script_dir/log.csv $log_dir/dep_test.log

# Remove utils
if [ -a "$lib_dir/$LIBDW" ]; then
	$RM $lib_dir/libdw*
fi
