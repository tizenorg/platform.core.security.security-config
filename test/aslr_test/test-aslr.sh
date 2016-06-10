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
# [Variables]
#=========================================================
target_base_dir="/usr/share/security-config"
target_aslr_dir="$target_base_dir/test/aslr_test"
target_util_dir="$target_base_dir/test/utils"
target_log_dir="$target_base_dir/log"
target_result_dir="$target_base_dir/result"
#=========================================================
# Script Begin
#=========================================================
echoI "Script Begin"

sdb root on

sdb shell mkdir -p $target_aslr_dir

sdb push $script_dir/scripts/* $target_aslr_dir

sdb shell su -c $target_aslr_dir/run_aslr_test.sh

if [ ! -d $script_dir/log ]; then
	echo "make log dir"
	mkdir $script_dir/log
else
	echo "log dir exist"
fi
if [ ! -d $script_dir/result ]; then
	echo "make result dir"
	mkdir $script_dir/result
else
	echo "result dir exist"
fi

sdb pull $target_log_dir/aslr_test.log $script_dir/log
sdb pull $target_result_dir/aslr_test.result $script_dir/result

sdb shell rm -rf $target_aslr_dir
