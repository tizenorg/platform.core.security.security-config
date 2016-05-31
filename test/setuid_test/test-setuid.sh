#!/bin/bash
#=========================================================
# [Includes]
#=========================================================
. "/usr/share/security-config/test/utils/_sh_util_lib"
#=========================================================
# Script Begin
#=========================================================
echoI "Script Begin"

source $suid_script_dir/scripts/01_run_setuid_test.sh

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
$MV $suid_script_dir/log.csv $log_dir/setuid_log.csv
$MV $suid_script_dir/result $result_dir/setuid_result
