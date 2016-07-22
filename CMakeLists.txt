CMAKE_MINIMUM_REQUIRED(VERSION 2.6)
PROJECT(security-config C)

SET(PREFIX ${CMAKE_INSTALL_PREFIX})

SET(VERSION 1.0)

SET(VERSION_MAJOR 0)
SET(VERSION "${VERSION_MAJOR}.0.2")

INSTALL(FILES ${CMAKE_SOURCE_DIR}/config/group_id_setting DESTINATION /usr/share/security-config)
INSTALL(FILES ${CMAKE_SOURCE_DIR}/labeling/set_label DESTINATION /usr/share/security-config)
INSTALL(FILES ${CMAKE_SOURCE_DIR}/config/set_capability DESTINATION /usr/share/security-config)
INSTALL(FILES ${CMAKE_SOURCE_DIR}/config/security-config.conf DESTINATION /usr/lib/tmpfiles.d/)
INSTALL(FILES ${CMAKE_SOURCE_DIR}/config/90_user-content-permissions.post DESTINATION ${SYSCONF_INSTALL_DIR}/gumd/useradd.d)
INSTALL(FILES ${CMAKE_SOURCE_DIR}/config/91_user-dbspace-permissions.post DESTINATION ${SYSCONF_INSTALL_DIR}/gumd/useradd.d)

IF("${PROFILE}" STREQUAL "mobile" OR "${PROFILE}" STREQUAL "wearable")
INSTALL(FILES ${CMAKE_SOURCE_DIR}/smack/onlycap DESTINATION /etc/smack)
INSTALL(FILES ${CMAKE_SOURCE_DIR}/smack/smack_default_labeling DESTINATION /usr/share/security-config)
ENDIF()

INSTALL(FILES
    ${CMAKE_SOURCE_DIR}/packaging/security-config.manifest
    DESTINATION
    /usr/share
)

ADD_SUBDIRECTORY(test)
IF("${PROFILE}" STREQUAL "mobile" OR "${PROFILE}" STREQUAL "wearable")
ADD_SUBDIRECTORY(systemd)
ENDIF()
