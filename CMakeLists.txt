CMAKE_MINIMUM_REQUIRED(VERSION 2.6)
PROJECT(security-config C)

SET(PREFIX ${CMAKE_INSTALL_PREFIX})

SET(VERSION 1.0)

SET(VERSION_MAJOR 0)
SET(VERSION "${VERSION_MAJOR}.0.2")

INSTALL(FILES ${CMAKE_SOURCE_DIR}/config/group_id_setting DESTINATION /usr/share/security-config)

INSTALL(FILES
    ${CMAKE_SOURCE_DIR}/packaging/security-config.manifest
    DESTINATION
    /usr/share
)
