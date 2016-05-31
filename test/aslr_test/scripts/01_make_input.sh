#!/bin/sh
#=========================================================
# [First of All] Get the directory path and name of this script
#=========================================================
script_path=$(/usr/bin/readlink -f "$0")
script_dir=`/usr/bin/dirname $script_path`
script_name=`/usr/bin/basename $script_path`
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
	$RM $input_file
	$TOUCH $input_file
	$TOUCH $tmp_file
	$FIND /usr/lib/systemd/ -name *.service | $XARGS $GREP "ExecStart" | $GREP -v "#ExecStart" > $tmp_file
	$SED -i 's/  / /g' $tmp_file
	$SED -i 's/ = /=/g' $tmp_file
	$SED -i 's/\-\//\//g' $tmp_file
	$CAT $tmp_file | $CUT -d "=" -f 2 | $CUT -d " " -f 1 > $input_file
	$RM $tmp_file
}

#=========================================================
# [01] Make input
#=========================================================
who_am_i=`$WHOAMI`
if [ $who_am_i != "root" ]
then
	ret=-2
	echoE "Not a root user."
	fnFinishThisScript $ret
fi
echoI "Make Input Sum"
makeInput
fnPrintSDone
