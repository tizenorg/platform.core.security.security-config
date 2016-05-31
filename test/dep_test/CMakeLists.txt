CMAKE_MINIMUM_REQUIRED(VERSION 2.6)

FILE(GLOB SHELL_SCRIPT *.sh)
INSTALL(FILES
		${SHELL_SCRIPT}
		README
        DESTINATION
        /usr/share/security-config/test/dep_test
)

INSTALL(DIRECTORY 
		${CMAKE_SOURCE_DIR}/test/dep_test/scripts 
		DESTINATION 
		/usr/share/security-config/test/dep_test
)