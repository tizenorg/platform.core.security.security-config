CMAKE_MINIMUM_REQUIRED(VERSION 2.6)

FILE(GLOB SHELL_SCRIPT *.sh)
INSTALL(FILES
          ${SHELL_SCRIPT}
          path_exception.list
          DESTINATION
          /usr/share/security-config/test/path_check_test
)

