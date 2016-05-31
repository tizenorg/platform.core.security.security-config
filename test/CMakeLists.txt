MESSAGE("ARCH = ${ARCH}")
IF("${ARCH}" STREQUAL "arm")
	SET(UTILDIR "util_target_32")
ELSEIF("${ARCH}" STREQUAL "aarch64")
	SET(UTILDIR "util_target_64")
ELSEIF("${ARCH}" STREQUAL "i386")
	SET(UTILDIR "util_emul")
ENDIF()

#INSTALL UTIL FOR ASLR/DEP TEST
file(GLOB TESTUTILS "${CMAKE_SOURCE_DIR}/test/dep_test/${UTILDIR}/*")
INSTALL(FILES ${TESTUTILS} DESTINATION /usr/share/security-config/test/utils/)

ADD_SUBDIRECTORY(aslr_test)
ADD_SUBDIRECTORY(dep_test)
ADD_SUBDIRECTORY(setuid_test)
ADD_SUBDIRECTORY(path_check_test)
ADD_SUBDIRECTORY(capability_test)
ADD_SUBDIRECTORY(smack_rule_test)
ADD_SUBDIRECTORY(root_test)

