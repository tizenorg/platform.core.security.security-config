#!/bin/bash

PATH="/usr/bin:/bin:/usr/sbin:/sbin"
utl_path="/usr/share/security-config/test/utils"
result_file="/usr/share/security-config/result/path_check.result"
log_file="/usr/share/security-config/log/path_check.log"
exception_file="/usr/share/security-config/test/path_check_test/path_exception.list"
script_list_path="/usr/share/security-config/log/script_file_list"

# Check whether this file is one of exception lists.
# args : $1 = file path
function CHECK_EXCEPTION
{
	while read exception_file_path
	do
		filtered_file_path=$(echo $1 | grep $exception_file_path)
		if [ -n "$filtered_file_path" ]
		then
			return 1
		fi
	done < <(cat $exception_file ) 
	return 0
}

# Read all scripts in the system, and check whether "PATH" is set with /usr/bin, /bin, /usr/sbin, /sbin.
# args : $1 = file path
function PATH_CHECK
{
	filtered_line=$(grep "PATH=" $1 | grep "[^a-z A-Z]/bin" | grep "[^a-z A-Z]/sbin" | grep "/usr/bin" | grep "/usr/sbin")
	if [ "$filtered_line" == "" ]
	then
		CHECK_EXCEPTION $1 # exception check
		if [ "$?" == 0 ]
		then
			echo $1 >> $log_file
		fi
	fi
}

# Main Check function : find shell scripts in the system.
function CHECK
{
	# check only for /usr /opt /etc 
	#find /opt /usr /etc -type f -exec $utl_path/file {} \; 2>/dev/null | grep "shell script" | cut -d ":" -f1 >> $script_list_path
	find / -type f -executable 2>/dev/null | xargs $utl_path/file | grep "shell script" | cut -d ":" -f1 >> $script_list_path

	while read script_file_line
	do
		PATH_CHECK $script_file_line		
	done < <(cat $script_list_path)
}

# Rename file util
file_cmd=`find $utl_path -name file.*`
if [ "$file_cmd" != "" ]; then
	/bin/mv $file_cmd $utl_path/file
fi

if [ -e "$log_file" ]
then
	rm $log_file
fi
if [ -e "$result_file" ]
then
	rm $result_file
fi

CHECK

if [ ! -e $log_file ]
then
	echo "YES" > $result_file
else
	echo "NO" > $result_file
fi

if [ -e "$script_list_path" ]
then
	rm $script_list_path
fi

/bin/echo "PATH CHECK FINISHED!"
