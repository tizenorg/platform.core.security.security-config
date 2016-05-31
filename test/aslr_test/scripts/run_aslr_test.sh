#!/bin/sh
#=========================================================
# [Includes]
#=========================================================
. "/usr/share/security-config/test/utils/_sh_util_lib"
#=========================================================
# Script Begin
#=========================================================
echoI "Script Begin"
#=========================================================
# [Variable]
#=========================================================
tmp_list="$aslr_script_dir/tmp.list"
all_systemd_executable_list="$aslr_script_dir/all_systemd_executable.list"
sorted_all_systemd_executable_list="$aslr_script_dir/sorted_all_systemd_executable.list"
exception_file="$aslr_script_dir/scripts/exception.list"
file_ret=
grep_ret=
fail_cnt=
total_cnt=
result_file="$aslr_script_dir/result"
log_file="$aslr_script_dir/log.csv"
is_exception=

function makeInput {
	$RM $all_systemd_executable_list
	$TOUCH $all_systemd_executable_list
	$TOUCH $tmp_list
	$FIND /usr/lib/systemd/ -name *.service | $XARGS $GREP "ExecStart" | $GREP -v "#ExecStart" > $tmp_list
	$SED -i 's/  / /g' $tmp_list
	$SED -i 's/ = /=/g' $tmp_list
	$SED -i 's/\-\//\//g' $tmp_list
	$CAT $tmp_list | $CUT -d "=" -f 2 | $CUT -d " " -f 1 > $all_systemd_executable_list
	$RM $tmp_list
}

function sortInput {

    #sdb pull /opt/usr/tc/aslr/$all_systemd_executable_list
    $SORT $all_systemd_executable_list > $tmp_list
    $CAT $tmp_list | $UNIQ > $sorted_all_systemd_executable_list
    $RM $tmp_list
    $RM $all_systemd_executable_list
}

function testSystemDASLR {
    echoI "Check whether the executable is ASLR applied or not"
    while read line; do
        echoI "$line"
        file_ret=""
        grep_ret=""
        file_ret=`$utils_dir/file $line`
        grep_ret=`echo $file_ret | $GREP -i "executable" | $GREP "ELF" | $GREP -v "script"`

        total_cnt=$((total_cnt+1))

        if [ ! "$grep_ret" ]; then
            echoS "$line, OK"
            echo "$line"",OK" >> $log_file
        else
            is_exception="false"
            while read line2; do
                if [ "$line" = "$line2" ]; then
                    is_exception="true"
                fi
            done < $exception_file
            if [ "$is_exception" = "true" ]; then
                echoS "$line"", OK - Not a target of ASLR test"
                echo "$line"",OK - Not a target of ASLR test" >> $log_file
            else
                echoE "$line, NOK"
                echo "$line"",NOK" >> $log_file
                fail_cnt=$((fail_cnt+1))
            fi
        fi
    done < $sorted_all_systemd_executable_list
	$RM $sorted_all_systemd_executable_list
}
#=========================================================
# [00] Remove previous result
#=========================================================

$RM $result_file
$TOUCH $result_file
$RM $log_file
$TOUCH $log_file

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

echoI "Make Input"
makeInput

echoI "Sort Input"
sortInput

echoI "Test Systemd ASLR"
testSystemDASLR

if [ $fail_cnt -lt 1 ]; then
    echo "YES" > $result_file
else
    echo "NO" > $result_file
fi
echo "================================================================"
echo "TOTAL: $total_cnt, NOT APPLIED: $fail_cnt"
echo "================================================================"
echo ""

fnPrintSDone
