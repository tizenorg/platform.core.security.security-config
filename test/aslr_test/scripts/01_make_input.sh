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
tmp_file="$script_dir/tmp.list"
input_file="$script_dir/all_systemd_executable.list"

function makeInput {
	rm $input_file
	touch $input_file
	touch $tmp_file
	find /usr/lib/systemd/ -name *.service | xargs grep "ExecStart" | grep -v "#ExecStart" > $tmp_file
	sed -i 's/  / /g' $tmp_file
	sed -i 's/ = /=/g' $tmp_file
	sed -i 's/\-\//\//g' $tmp_file
	cat $tmp_file | cut -d "=" -f 2 | cut -d " " -f 1 > $input_file
	rm $tmp_file
}

#=========================================================
# [01] Make input
#=========================================================
who_am_i=`whoami`
if [ $who_am_i != "root" ]
then
	ret=-2
	echoE "Not a root user."
	fnFinishThisScript $ret
fi
echoI "Make Input Sum"
makeInput
fnPrintSDone
