CMAKE_MINIMUM_REQUIRED(VERSION 2.6)

FILE(GLOB SHELL_SCRIPT *.sh)
INSTALL(FILES
          ${SHELL_SCRIPT}
          DESTINATION
          /usr/share/security-config/test/smack_rule_test
)

