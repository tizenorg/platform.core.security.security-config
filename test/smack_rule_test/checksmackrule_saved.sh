#!/bin/bash

result_dir="/usr/share/security-config/result"
log_dir="/usr/share/security-config/log"
SMACK_RULE_APPLY_PATH1='/opt/var/security-manager/rules/*'
SMACK_RULE_APPLY_PATH2='/etc/smack/accesses.d/*'
dbpath='/opt/dbspace/.security-manager.db'
result_file=$result_dir"/checksmackrule_saved.result"
log_file=$log_dir"/checksmackrule_saved.log"
exception_file="/usr/share/security-config/test/smack_rule_test/smackrule_exception_saved.list"

function EXCEPTION_CHECK
{
	while read exception_line
	do
		if [ "$1,$2,$3" == "$exception_line" ]
		then
			return 1
		fi
	done < <(/bin/cat $exception_file ) 
	return 0
}

function RULE_CHECK
{
    # System ~PKG~ rwxat
    if [ "$1" == "System" ] && [[ "$2" == *"::Pkg::"* ]]
    then
        if [ "$3" == "rwxat-" ]
        then
            return 0
        fi    
    # System ~PKG~::RO rwxat
    elif [ "$1" == "System" ] && [[ "$2" == *"::Pkg::"*"::RO" ]]
    then
        if [ "$3" == "rwxat-" ]
        then
            return 0
        fi 
    # System ~PKG~::SharedRO rwxat
    elif [ "$1" == "System" ] && [[ "$2" == *"::Pkg::"*"::SharedRO" ]]
    then
        if [ "$3" == "rwxat-" ]
        then
            return 0
        fi 
    # User ~PKG~ rwxat
    elif [ "$1" == "User" ] && [[ "$2" == *"::Pkg::"* ]]
    then
        if [ "$3" == "rwxat-" ]
        then
            return 0
        fi 
    # User ~PKG~::RO rwxat
    elif [ "$1" == "User" ] && [[ "$2" == *"::Pkg::"*"::RO" ]]
    then
        if [ "$3" == "rwxat-" ]
        then
            return 0
        fi 
    # User ~PKG~::SharedRO rwxat
    elif [ "$1" == "User" ] && [[ "$2" == *"::Pkg::"*"::SharedRO" ]]
    then
        if [ "$3" == "rwxat-" ]
        then
            return 0
        fi 
    # System User::App::Shared rwxat
    elif [ "$1" == "System" ] && [[ "$2" == "User::App::Shared" ]]
    then
        if [ "$3" == "rwxat-" ]
        then
            return 0
        fi 
    # System ~APP~ rwx
    elif [ "$1" == "System" ] && [[ "$2" == *"::App::"* ]]
    then
        if [ "$3" == "rwx---" ]
        then
            return 0
        fi            
    # ~APP~ System wx
    elif [[ "$1" == *"::App::"* ]] && [ "$2" == "System" ]
    then
        if [ "$3" == "-wx---" ]
        then
            return 0
        fi          
    # ~APP~ System::Shared rxl
    elif [[ "$1" == *"::App::"* ]] && [ "$2" == "System::Shared" ]
    then
        if [ "$3" == "r-x--l" ]
        then
            return 0
        fi   
    # ~APP~ System::Run rwxat
    elif [[ "$1" == *"::App::"* ]] && [ "$2" == "System::Run" ]
    then
        if [ "$3" == "rwxat-" ]
        then
            return 0
        fi   
    # ~APP~ System::Log rwxa
    elif [[ "$1" == *"::App::"* ]] && [ "$2" == "System::Log" ]
    then
        if [ "$3" == "rwxa--" ]
        then
            return 0
        fi  
    # ~APP~ _ l
    elif [[ "$1" == *"::App::"* ]] && [ "$2" == "_" ]
    then
        if [ "$3" == "-----l" ]
        then
            return 0
        fi  
    # ~APP~ User::App::Shared rwxat
    elif [[ "$1" == *"::App::"* ]] && [ "$2" == "User::App::Shared" ]
    then
        if [ "$3" == "rwxat-" ]
        then
            return 0
        fi
    # User User::App::Shared rwxat
    elif [ "$1" == "User" ] && [[ "$2" == "User::App::Shared" ]]
    then
        if [ "$3" == "rwxat-" ]
        then
            return 0
        fi 
    # User ~APP~ rwx
    elif [ "$1" == "User" ] && [[ "$2" == *"App"* ]]
    then
        if [ "$3" == "rwx---" ]
        then
            return 0
        fi  
    # ~APP~ User wx
    elif [[ "$1" == *"::App::"* ]] && [ "$2" == "User" ]
    then
        if [ "$3" == "-wx---" ]
        then
            return 0
        fi     
    # ~APP~ User::Home rxl
    elif [[ "$1" == *"::App::"* ]] && [ "$2" == "User::Home" ]
    then
        if [ "$3" == "r-x--l" ]
        then
            return 0
        fi  
    # SharedRO
    # ~App~ ~Pkg~::SharedRO rwxat : same app and pkg
    # App ~Pkg~::SharedRO rx : diffrent app and pkg
    elif [[ "$1" == *"::App::"* ]] && [[ "$2" == *"::Pkg::"*"::SharedRO" ]]
    then
        pkgname=$(/bin/echo $2 | /usr/bin/cut -f 5 -d ":")
        appname=$(/bin/echo $1 | /usr/bin/cut -f 5 -d ":")
        pkgname_db=$(/usr/bin/sqlite3 $dbpath "select DISTINCT pkg_name from app_pkg_view where app_name='$appname';")
        
        if [ "$pkgname" == "$pkgname_db" ]
        then
            if [ "$3" == "rwxat-" ]
            then
                return 0
            fi
        else
            if [ "$3" == "r-x---" ]
            then
                return 0
            fi
        fi 
    # ~APP~ ~PKG~::RO rxl
    elif [[ "$1" == *"::App::"* ]] && [[ "$2" == *"::Pkg::"*"::RO" ]]
    then
        pkgname=$(/bin/echo $2 | /usr/bin/cut -f 5 -d ":")
        appname=$(/bin/echo $1 | /usr/bin/cut -f 5 -d ":")
        pkgname_db=$(/usr/bin/sqlite3 $dbpath "select DISTINCT pkg_name from app_pkg_view where app_name='$appname';")
        
        if [ "$pkgname" == "$pkgname_db" ]
        then
            if [ "$3" == "r-x--l" ]
            then
                return 0
            fi
        fi      
    # ~APP~ ~PKG~ rwxat
    elif [[ "$1" == *"::App::"* ]] && [[ "$2" == *"::Pkg::"* ]]
    then
        pkgname=$(/bin/echo $2 | /usr/bin/cut -f 5 -d ":")
        appname=$(/bin/echo $1 | /usr/bin/cut -f 5 -d ":")
        pkgname_db=$(/usr/bin/sqlite3 $dbpath "select DISTINCT pkg_name from app_pkg_view where app_name='$appname';")
        
        if [ "$pkgname" == "$pkgname_db" ]
        then
            if [ "$3" == "rwxat-" ]
            then
                return 0
            fi
        fi 
    #~APP~ ~AUTHOR~ rwxat
    elif [[ "$1" == *"::App::"* ]] && [[ "$2" == *"Author"* ]]
    then
        authorID=$(/bin/echo $2 | /usr/bin/cut -f 5 -d ":")
        appname=$(/bin/echo $1 | /usr/bin/cut -f 5 -d ":")
        authorID_db=$(/usr/bin/sqlite3 $dbpath "select DISTINCT author_id from app_pkg_view where app_name='$appname';")
        
        if [ "$authorID" == "$authorID_db" ]
        then
            if [ "$3" == "rwxat-" ]
            then
                return 0
            fi
        fi  
    # User ~AUTHOR~ rwxat
    elif [ "$1" == "User" ] && [[ "$2" == *"Author"* ]]
    then
        if [ "$3" == "rwxat-" ]
        then
            return 0
        fi  
    # System ~AUTHOR~ rwxat
    elif [ "$1" == "System" ] && [[ "$2" == *"Author"* ]]
    then
        if [ "$3" == "rwxat-" ]
        then
            return 0
        fi  
    # From here, default 3-Domain Rule Check
    # _ System rwxa
    elif [ "$1" == "^" ] && [[ "$2" == "System" ]]
    then
        if [ "$3" == "rwxa--" ]
        then
            return 0
        fi  
    # ^ System::Log rwxa
    elif [ "$1" == "^" ] && [[ "$2" == "System::Log" ]]
    then
        if [ "$3" == "rwxa--" ]
        then
            return 0
        fi  
    # ^ System::Run rwxat
    elif [ "$1" == "^" ] && [[ "$2" == "System::Run" ]]
    then
        if [ "$3" == "rwxat-" ]
        then
            return 0
        fi  
    # _ System wx
    elif [ "$1" == "_" ] && [[ "$2" == "System" ]]
    then
        if [ "$3" == "-wx---" ]
        then
            return 0
        fi 
    # _ System::Run rwxat
    elif [ "$1" == "_" ] && [[ "$2" == "System::Run" ]]
    then
        if [ "$3" == "rwxat-" ]
        then
            return 0
        fi 
    # System System::Log rwxa
    elif [ "$1" == "System" ] && [[ "$2" == "System::Log" ]]
    then
        if [ "$3" == "rwxa--" ]
        then
            return 0
        fi 
    # System System::Run rwxat
    elif [ "$1" == "System" ] && [[ "$2" == "System::Run" ]]
    then
        if [ "$3" == "rwxat-" ]
        then
            return 0
        fi 
    # System System::Shared rwxat
    elif [ "$1" == "System" ] && [[ "$2" == "System::Shared" ]]
    then
        if [ "$3" == "rwxat-" ]
        then
            return 0
        fi 
    # System User rwx
    elif [ "$1" == "System" ] && [[ "$2" == "User" ]]
    then
        if [ "$3" == "rwx---" ]
        then
            return 0
        fi 
    # System User::Home rwxat
    elif [ "$1" == "System" ] && [[ "$2" == "User::Home" ]]
    then
        if [ "$3" == "rwxat-" ]
        then
            return 0
        fi 
    # System _ rxl
    elif [ "$1" == "System" ] && [[ "$2" == "_" ]]
    then
        if [ "$3" == "r-x--l" ]
        then
            return 0
        fi 
    # User _ rxl
    elif [ "$1" == "User" ] && [[ "$2" == "_" ]]
    then
        if [ "$3" == "rw---l" ]
        then
            return 0
        fi 
    # User System wx
    elif [ "$1" == "User" ] && [[ "$2" == "System" ]]
    then
        if [ "$3" == "-wx---" ]
        then
            return 0
        fi 
    # User System::Run rwxat
    elif [ "$1" == "User" ] && [[ "$2" == "System::Run" ]]
    then
        if [ "$3" == "rwxat-" ]
        then
            return 0
        fi 
    # User System::Log rwxa
    elif [ "$1" == "User" ] && [[ "$2" == "System::Log" ]]
    then
        if [ "$3" == "rwxa--" ]
        then
            return 0
        fi 
    # User System::Shared rxl
    elif [ "$1" == "User" ] && [[ "$2" == "System::Shared" ]]
    then
        if [ "$3" == "r-x--l" ]
        then
            return 0
        fi 
    # User User::Home rwxat
    elif [ "$1" == "User" ] && [[ "$2" == "User::Home" ]]
    then
        if [ "$3" == "rwxat-" ]
        then
            return 0
        fi 
    # app <-> app rwxat cross package
    elif [[ "$1" == *"::App::"* ]] && [[ "$2" == *"::App::"* ]]
    then
        appname1=$(/bin/echo $1 | /usr/bin/cut -f 5 -d ":")
        appname2=$(/bin/echo $2 | /usr/bin/cut -f 5 -d ":")
        pkgname1=$(/usr/bin/sqlite3 $dbpath "select DISTINCT pkg_name from app_pkg_view where app_name='$appname1';")
        pkgname2=$(/usr/bin/sqlite3 $dbpath "select DISTINCT pkg_name from app_pkg_view where app_name='$appname2';")
        if [ "$pkgname1" == "$pkgname2" ] && [ "$3" == "rwxat-" ]
        then
            return 0
        fi 
    fi

    EXCEPTION_CHECK $1 $2 $3

    if [ "$?" == 0 ]
    then
        /bin/echo "$1,$2,$3" >> $log_file
    fi
}

function RULE_CHECK_APPLY_PATH
{
    cat $SMACK_RULE_APPLY_PATH1 $SMACK_RULE_APPLY_PATH2 | while read line    
    do
        subject=$(/bin/echo $line | /usr/bin/cut -f 1 -d " ")
        object=$(/bin/echo $line | /usr/bin/cut -f 2 -d " ")
        rule=$(/bin/echo $line | /usr/bin/cut -f 3 -d " ")

        RULE_CHECK $subject $object $rule    
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

/bin/echo "SMACK RULE CHECK STARTED!"

RULE_CHECK_APPLY_PATH

if [ ! -e $log_file ]
then
	/bin/echo "1" >> $result_file
else
	/bin/echo "0" >> $result_file
fi

/bin/echo "SMACK RULE CHECK FINISHED! "
