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

# Set required utils
libdw_lib=`$FIND $utils_dir -name libdw*`
if [ "$libdw_lib" != "" ]; then
	$MV $libdw_lib $utils_dir/"$LIBDW"
    $CP $utils_dir/$LIBDW $lib_dir
    $LN $lib_dir/$LIBDW $lib_dir/libdw.so.1
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
