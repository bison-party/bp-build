######################################## CONFIG_HDR Inputs #########################################

# MODULE1_OFFSET
#  		An integer which shifts the output of the `do_add` function.
#  		Default value = 0.


######################################## CONFIG_MK Inputs ##########################################

# None

####################################################################################################

ifdef CONFIG_MK
include $(CONFIG_MK)
endif

GIT_TOP := $(shell git rev-parse --show-toplevel)

C_SRC_NAMES := logic
S_SRC_NAMES := logic
C_TEST_SRC_NAMES := logic

INCS := $(GIT_TOP)/make-c/test-project/misc-hdrs

include $(GIT_TOP)/colors.mk
include $(GIT_TOP)/make-c/module.mk
