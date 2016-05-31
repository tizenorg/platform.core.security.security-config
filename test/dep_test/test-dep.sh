#!/bin/bash
#=========================================================
# [First of All] Get the directory path and name of this script
#=========================================================
script_path=$(readlink -f "$0")
script_dir=`dirname $script_path`
script_name=`basename $script_path`
#=========================================================
# [Includes]
#=========================================================
. "$script_dir/scripts/_sh_util_lib"
#=========================================================
# Script Begin
#=========================================================
echoI "Script Begin"

if [ -a "$script_dir/../utils/libdw-0.153.so" ]; then
    /usr/bin/cp $script_dir/../utils/libdw* /usr/lib/
    /bin/ln /usr/lib/libdw-0.153.so /usr/lib/libdw.so.1
fi

source $script_dir/scripts/01_run_dep_test.sh

rm -rf $script_dir/output/
/bin/mkdir $script_dir/output
/bin/mv $script_dir/test_result.csv $script_dir/output/
rm /usr/lib/libdw*
