#!/bin/bash

outputfile='/usr/share/security-config/output/smack_rule_test/checksmacklabel.csv'

function CHECK_RULE_ACCESS
{
	if [ "${label:8:1}"  != '_' ] && [ "${label:8:1}"  != '*' ] && [ "${label:8:1}"  != '^' ] &&
		 [ "${label:8:6}"  != 'System' ] && [ "${label:8:11}"  != 'System::Run' ] && [ "${label:8:11}"  != 'System::Log' ] &&
	   [ "${label:8:13}"  != 'System::Shared' ] && [ "${label:8:4}"  != 'User' ] && [ "${label:8:10}"  != 'User::Home' ] &&
	   [ "${label:8:17}"  != 'User::App::Shared' ] && [ "${label:8:9}"  != 'User::Pkg' ]
	then
		/bin/echo "ACCESS label,$line2" >> $outputfile
  fi
}

function CHECK_RULE_EXECUTE
{
	if [ "${label:9:1}"  != '_' ] && [ "${label:9:1}"  != '^' ] &&
	   [ "${label:9:6}"  != 'System' ] && [ "${label:9:4}"  != 'User' ] && [ "${label:9:9}"  != 'User::App' ]
	then
		/bin/echo "EXECUTE label,$line2" >> $outputfile
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
/bin/echo "SMACK LABEL CHECK STARTED!"

/usr/bin/touch $outputfile
/bin/echo "Wrong Smack Label Lists" > $outputfile

SMACK_LABEL_CHECK 

/bin/echo "Generated checksmacklabel.csv / SMACK LABEL CHECK FINISHED!"
