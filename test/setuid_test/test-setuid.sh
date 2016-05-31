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

source $script_dir/scripts/01_run_setuid_test.sh

$RM -rf $script_dir/output
$MKDIR $script_dir/output
$MV $script_dir/test_result.csv $script_dir/output/
