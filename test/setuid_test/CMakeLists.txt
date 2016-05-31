CMAKE_MINIMUM_REQUIRED(VERSION 2.6)

INSTALL(DIRECTORY
	${CMAKE_SOURCE_DIR}/test/setuid_test
	DESTINATION
	/usr/share/security-config/test/
)
