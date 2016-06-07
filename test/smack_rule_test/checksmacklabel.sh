#!/bin/bash

result_dir="/usr/share/security-config/result"
log_dir="/usr/share/security-config/log"
result_file=$result_dir"/checksmacklabel.result"
log_file=$log_dir"/checksmacklabel.log"
exception_file="/usr/share/security-config/test/smack_rule_test/smacklabel_exception.list"

function CHECK_EXCEPTION
{
	while read exception_line
	do
		filtered_label=$(/bin/echo $label | /bin/grep $exception_line)
		if [ -n "$filtered_label" ]
		then
			return 1
		fi
	done < <(/bin/cat $exception_file ) 
	return 0
}


function CHECK_RULE_ACCESS
{
	if [ "${label:8:1}"  != '_' ] && [ "${label:8:1}"  != '*' ] && [ "${label:8:1}"  != '^' ] &&
		 [ "${label:8:6}"  != 'System' ] && [ "${label:8:11}"  != 'System::Run' ] && [ "${label:8:11}"  != 'System::Log' ] &&
	   [ "${label:8:14}"  != 'System::Shared' ] && [ "${label:8:4}"  != 'User' ] && [ "${label:8:10}"  != 'User::Home' ] &&
	   [ "${label:8:17}"  != 'User::App::Shared' ] && [ "${label:8:9}"  != 'User::Pkg' ]
	then
		CHECK_EXCEPTION
		if [ "$?" == 0 ]
		then
			/bin/echo "ACCESS label,$line2" >> $log_file
		fi
	fi
}

function CHECK_RULE_EXECUTE
{
	if [ "${label:9:1}"  != '_' ] && [ "${label:9:1}"  != '^' ] &&
	   [ "${label:9:6}"  != 'System' ] && [ "${label:9:4}"  != 'User' ] && [ "${label:9:9}"  != 'User::App' ]
	then
		CHECK_EXCEPTION
		if [ "$?" == 0 ]
		then
			/bin/echo "EXECUTE label,$line2" >> $log_file
		fi
	fi
}

function LABEL_CHECK
{    
	/usr/bin/chsmack $1/* | while read line2 
	do
		label=$(/bin/echo $line2 | /usr/bin/rev | /usr/bin/cut -f1 -d " " | /usr/bin/rev)
		if [ "${label:0:6}" == 'access' ]
		then
			CHECK_RULE_ACCESS
		elif [ "${label:0:7}" == 'execute' ] 
		then
			CHECK_RULE_EXECUTE
			label=$(/bin/echo $line2 | /usr/bin/rev | /usr/bin/cut -f2 -d " " | /usr/bin/rev)
			CHECK_RULE_ACCESS
		elif [ "${label:0:9}" == 'transmute' ] 
		then
			label=$(/bin/echo $line2 | /usr/bin/rev | /usr/bin/cut -f2 -d " " | /usr/bin/rev)
			if [ "${label:0:6}" == 'access' ]
			then
				CHECK_RULE_ACCESS
			elif [ "${label:0:7}" == 'execute' ] 
			then
				CHECK_RULE_EXECUTE
				label=$(/bin/echo $line2 | /usr/bin/rev | /usr/bin/cut -f3 -d " " | /usr/bin/rev)
				CHECK_RULE_ACCESS	
			fi	     
		fi
	done
}

function SMACK_LABEL_CHECK
{
	/usr/bin/find / -type d 2>/dev/null | while read line  # Remove error print
	do
		LABEL_CHECK $line 
	done
}

if [ ! -d $log_dir ]; then
    /bin/mkdir $log_dir
fi
if [ ! -d $result_dir ]; then
    /bin/mkdir $result_dir
fi

if [ -e $result_file ]
then
	/bin/rm $result_file
fi
if [ -e $log_file ]
then
	/bin/rm $log_file
fi

/bin/echo "SMACK LABEL CHECK STARTED!"

SMACK_LABEL_CHECK 

if [ ! -e $log_file ]
then
	/bin/echo "1" >> $result_file
else
	/bin/echo "0" >> $result_file
fi

/bin/echo "SMACK LABEL CHECK FINISHED!"
