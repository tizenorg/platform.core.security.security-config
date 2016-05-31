CMAKE_MINIMUM_REQUIRED(VERSION 2.6)

FILE(GLOB SHELL_SCRIPT *.sh)
INSTALL(FILES
		${SHELL_SCRIPT}
		root_daemon_list
		non_daemon_list
        non_root_list
		exception_list
        DESTINATION
        /usr/share/security-config/test/root_test
)

