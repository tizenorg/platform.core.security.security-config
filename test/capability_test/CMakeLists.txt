CMAKE_MINIMUM_REQUIRED(VERSION 2.6)

FILE(GLOB SHELL_SCRIPT *.sh)
INSTALL(FILES
          ${SHELL_SCRIPT}
          root_daemon_list
          cap_mac_exception_list
          DESTINATION
          /usr/share/security-config/test/capability_test
)
