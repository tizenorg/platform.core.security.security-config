CMAKE_MINIMUM_REQUIRED(VERSION 2.6)

MESSAGE("ARCH = ${ARCH}")                                                                          
IF("${ARCH}" STREQUAL "arm")
    SET(UTILDIR "util_target_32")
ELSEIF("${ARCH}" STREQUAL "aarch64")
    SET(UTILDIR "util_target_64")
ELSEIF("${ARCH}" STREQUAL "i386")
    SET(UTILDIR "util_emul")
ENDIF()

#INSTALL UTIL FOR ASLR/DEP TEST
file(GLOB TESTUTILS "${CMAKE_SOURCE_DIR}/test/utils/${UTILDIR}/*")
INSTALL(FILES
	_sh_util_lib
	${TESTUTILS}
	DESTINATION
	/usr/share/security-config/test/utils
)
