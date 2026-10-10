######################################## CONFIG_HDR Inputs #########################################

# None

######################################## CONFIG_MK Inputs ##########################################

# MODULE2_INCLUDE_MAIN
# 		When defined, `main.c` is compiled.

####################################################################################################

ifdef CONFIG_MK
include $(CONFIG_MK)
endif

GIT_TOP := $(shell git rev-parse --show-toplevel)

C_SRC_NAMES := f1 f2

ifdef MODULE2_INCLUDE_MAIN
C_SRC_NAMES += main
endif

S_SRC_NAMES := 
C_TEST_SRC_NAMES := t

DEPS := $(GIT_TOP)/make_c/test_project/module1
CFLAGS := -Wall -Wextra -Wpedantic -Werror

include $(GIT_TOP)/colors.mk
include $(GIT_TOP)/make_c/module.mk
