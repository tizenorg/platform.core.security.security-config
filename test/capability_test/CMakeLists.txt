CMAKE_MINIMUM_REQUIRED(VERSION 2.6)

FILE(GLOB SHELL_SCRIPT *.sh)

IF("${ARCH}" STREQUAL "arm")
	IF("${PROFILE}" STREQUAL "mobile")
		FILE(GLOB ROOT_DAEMON_LIST "${CMAKE_SOURCE_DIR}/test/capability_test/list/target/mobile/root_daemon_list")
		FILE(GLOB CAP_MAC_EXCEPTION_LIST "${CMAKE_SOURCE_DIR}/test/capability_test/list/target/mobile/cap_mac_exception_list")
	ELSEIF("${PROFILE}" STREQUAL "wearable")
		FILE(GLOB ROOT_DAEMON_LIST "${CMAKE_SOURCE_DIR}/test/capability_test/list/target/wearable/root_daemon_list")
		FILE(GLOB CAP_MAC_EXCEPTION_LIST "${CMAKE_SOURCE_DIR}/test/capability_test/list/target/wearable/cap_mac_exception_list")
	ENDIF()
ELSEIF("${ARCH}" STREQUAL "aarch64")
	IF("${PROFILE}" STREQUAL "mobile")
		FILE(GLOB ROOT_DAEMON_LIST "${CMAKE_SOURCE_DIR}/test/capability_test/list/target/mobile/root_daemon_list")
		FILE(GLOB CAP_MAC_EXCEPTION_LIST "${CMAKE_SOURCE_DIR}/test/capability_test/list/target/mobile/cap_mac_exception_list")
	ENDIF()
ELSEIF("${ARCH}" STREQUAL "i386")
	IF("${PROFILE}" STREQUAL "mobile")
		FILE(GLOB ROOT_DAEMON_LIST "${CMAKE_SOURCE_DIR}/test/capability_test/list/emul/mobile/root_daemon_list")
		FILE(GLOB CAP_MAC_EXCEPTION_LIST "${CMAKE_SOURCE_DIR}/test/capability_test/list/emul/mobile/cap_mac_exception_list")
	ELSEIF("${PROFILE}" STREQUAL "wearable")
		FILE(GLOB ROOT_DAEMON_LIST "${CMAKE_SOURCE_DIR}/test/capability_test/list/emul/wearable/root_daemon_list")
		FILE(GLOB CAP_MAC_EXCEPTION_LIST "${CMAKE_SOURCE_DIR}/test/capability_test/list/emul/wearable/cap_mac_exception_list")
	ENDIF()
ELSEIF("${ARCH}" STREQUAL "x86_64")
	IF("${PROFILE}" STREQUAL "mobile")
		FILE(GLOB ROOT_DAEMON_LIST "${CMAKE_SOURCE_DIR}/test/capability_test/list/emul/mobile/root_daemon_list")
		FILE(GLOB CAP_MAC_EXCEPTION_LIST "${CMAKE_SOURCE_DIR}/test/capability_test/list/emul/mobile/cap_mac_exception_list")
	ENDIF()
ENDIF()

INSTALL(FILES
	${SHELL_SCRIPT}
	${ROOT_DAEMON_LIST}
	${CAP_MAC_EXCEPTION_LIST}
	DESTINATION
	/usr/share/security-config/test/capability_test
)
