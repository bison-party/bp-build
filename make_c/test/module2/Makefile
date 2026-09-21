GIT_TOP := $(shell git rev-parse --show-toplevel)

C_SRC_NAMES := f1 f2
S_SRC_NAMES := 
C_TEST_SRC_NAMES := t

DEPS := $(GIT_TOP)/make_c/test/module1
CFLAGS := -Wall -Wextra -Wpedantic -Werror

include $(GIT_TOP)/colors.mk
include $(GIT_TOP)/make_c/module.mk
