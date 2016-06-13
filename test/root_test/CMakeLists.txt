CMAKE_MINIMUM_REQUIRED(VERSION 2.6)

FILE(GLOB SHELL_SCRIPT *.sh)
IF("${ARCH}" STREQUAL "arm")
	IF("${PROFILE}" STREQUAL "mobile")
		FILE(GLOB LIST "${CMAKE_SOURCE_DIR}/test/root_test/list/target/mobile/*")
	ELSEIF("${PROFILE}" STREQUAL "wearable")
		FILE(GLOB LIST "${CMAKE_SOURCE_DIR}/test/root_test/list/target/wearable/*")
	ENDIF()
ELSEIF("${ARCH}" STREQUAL "i386")
	IF("${PROFILE}" STREQUAL "mobile")
		FILE(GLOB LIST "${CMAKE_SOURCE_DIR}/test/root_test/list/emul/mobile/*")
	ELSEIF("${PROFILE}" STREQUAL "wearable")
		FILE(GLOB LIST "${CMAKE_SOURCE_DIR}/test/root_test/list/emul/wearable/*")
	ENDIF()
ENDIF()
INSTALL(FILES
		${SHELL_SCRIPT}
       		${LIST} 
	DESTINATION
        /usr/share/security-config/test/root_test
)
