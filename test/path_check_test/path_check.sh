#!/bin/bash
cmd_list_path="/usr/share/security-config/output/path_check_test/cmd_list"
result_file="/usr/share/security-config/output/path_check_test/path_check_result.csv"
script_file_list="/usr/share/security-config/output/path_check_test/script_file_list"

retval1=-1
retval2=-1

# Get all commands
function generate_cmd_list 
{
	/bin/find -L /bin /sbin -type f >> $cmd_list_path
}

# check whether this is one of characters in string varialbe or not
# args : $1 = file name, $2 = line number to be checked
function check_string
{
	retval2=0
	tempval=0
	while read line1
	do
		numofquot=$(echo "$line1" | grep -o "\"" | wc -w)
		numofquot_mod=$(/bin/expr $numofquot % 2)
		if [ $numofquot_mod -eq 1 ]
		then

		tempval=$(/bin/expr $tempval + 1)
		num1=$(echo "$line1" | /bin/cut -d ":" -f1)
		if [ $num1 -gt $2 ]
		then
			tempval_mod=$(/bin/expr $tempval % 2)
			if [ $tempval_mod -eq 0 ] # check modula value
			then
				retval2=1
			fi
			break			
		fi

		fi
	done < <(/bin/grep -n --line-buffered  '\"' $1 )		
}

# check whether this is one of prefix related lines or not
# args : $1 = file name, $2 = cmd name, $3 = filtered line
function check_prefix
{
	retval1=0
	while read prefix_str
	do
		script_filtered_line_withprefix=$(/bin/grep -n --line-buffered  "\$$prefix_str""/$2" $1 | /bin/grep -v "#" )
		if [ "$script_filtered_withprefix" = "$3" ]
		then
			retval1=1
			break
		fi
	done < <( bin/grep -e "\$*=/usr/bin" -e "\$*=/bin" -e "\$*=/usr/sbin" -e "\$*=/sbin" $1 | /bin/cut -d "=" -f1 )
}

# Read all cmds from the saved file, and try to check whether there are commands using relative path
# args : $1 = file name
function PATH_CHECK
{
	/bin/cat $cmd_list_path | while read cmd_list_line # read command per line
	do
		command_except_path=$(/bin/echo "$cmd_list_line" | /bin/rev | /bin/cut -d "/" -f1 | /bin/rev)

		# Main Filter
		script_filtered_line=$(/bin/grep -n --line-buffered -e "$command_except_path " -e "[^a-z]$command_except_path$" $1  | /bin/grep -v -e "$cmd_list_line " -e "#" -e "[a-z]$command_except_path " -e "_$command_except_path " -e "-$command_except_path " -e ":$command_except_path" -e "\.$command_except_path " -e "\".*$command_except_path.*\".*" -e "$cmd_list_line$" -e "\$$command_except_path " -e "\$$command_except_path$" -e "for $command_except_path " -e "\.$command_except_path$" -e "_$command_except_path$" -e "-$command_except_path$")

		if [ "$script_filtered_line" != "" ]
		then
			check_prefix "$1" "$command_except_path" "$script_filtered_line" # prefix check
			if [ "$retval1" -eq 0 ]
			then
				while read line_filtered
				do
					line_num=$(/bin/echo $line_filtered | /bin/cut -d ":" -f1)
					check_string $1 $line_num # string check
					if [ "$retval2" -eq 0 ]
					then
						/bin/echo "file name = $1 , cmd = $cmd_list_line" >> $result_file 
						/bin/echo "line = " $line_filtered >> $result_file
						/bin/echo "" >> $result_file			
					fi					 
				done < <(/bin/echo "$script_filtered_line") # read each line
			fi			
		fi

	done	
}

function CHECK
{
	/bin/find / -type f -exec /bin/file {} \; 2>/dev/null | /bin/grep "shell script" | /bin/cut -d ":" -f1 | while read script_file_line
	do
		PATH_CHECK $script_file_line
	done
}

if [ -e "$result_file" ]
then
	/bin/rm $result_file
fi
if [ -e "$cmd_list_path" ]
then
	/bin/rm $cmd_list_path
fi

/bin/echo "PATH CHECK TEST STARTED!"
generate_cmd_list 
CHECK

/bin/echo "PATH CHECK FINISHED!"
/bin/echo "Results can be found in path_check_result.csv"


