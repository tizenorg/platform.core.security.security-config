CMAKE_MINIMUM_REQUIRED(VERSION 2.6)

FILE(GLOB SHELL_SCRIPT *.sh)
INSTALL(FILES
          ${SHELL_SCRIPT}
		smacklabel_exception.list
		smackrule_exception.list
          DESTINATION
          /usr/share/security-config/test/smack_rule_test
)

