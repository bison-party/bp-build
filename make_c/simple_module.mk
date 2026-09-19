
# Simple Module 
#
# Expected Directory Structure:
#
# $(MOD_NAME)/
#   include/
#     $(MOD_NAME)/
#       test/
#         test_header_1.h
#         test_header_2.h
#         ...
#       header_1.h
#       header_2.h
#       ...
#   src/
#     c_src_1.c
#     c_src_2.c
#     ...
#     s_src_1.S
#     s_src_2.S
#     ...
#   test/
#     test_src_1.c
#     test_src_2.c
#     ...
#   Makefile (includes simple_module.mk)
#
# Some things to note:
# * The module name of a simple module is inferred from its directory name.
# * When sources are compiled, their names are mangled to prevent collision of object files. 
# A `src/file.c`, `src/file.S`, and `test/file.c` can all be declared within a single module without
# any issues!
#
# Build Directory Structure:
#
# $(BUILD_DIR)/
#   $(MOD_NAME)/
#     dotds/
#       *.d
#     objs/ 
#       *.o 
#     lib$(MOD_NAME).a
#     libtest_$(MOD_NAME).a

# Module name is inferred!
MOD_NAME := $(notdir $(CURDIR))

####################################################################################################
#####                                         INPUTS                                            ####
####################################################################################################

# Source Inputs:
# 
# C_SRC_NAMES - Names of all `.c` source files that should be compiled from $(MOD_NAME)/src.
# S_SRC_NAMES - Names of all `.S` source files that should be compiled from $(MOD_NAME)/src.
# C_TEST_SRC_NAMES - Names of all `.c` source files that should be compiled from $(MOD_NAME)/test.
#
# VERY IMPORTANT: Omit file extensions when declaring these variables!
# It is understood that S_SRC_NAMES := my_src refers to $(MOD_NAME)/src/my_src.S.
# Extensions are inferred!

ifeq ($(C_SRC_NAMES)$(S_SRC_NAMES),)
$(error At least 1 `.c` or `.S` source file must be specified)
endif

SRC_DIR 	:= $(CURDIR)/src
C_SRCS  	:= $(patsubst %,$(SRC_DIR)/%.c,$(C_SRC_NAMES))
S_SRCS  	:= $(patsubst %,$(SRC_DIR)/%.S,$(S_SRC_NAMES))

ifeq ($(C_TEST_SRC_NAMES),)
$(error At least 1 `.c` test source file must be specified)
endif

TEST_DIR 	:= $(CURDIR)/test
C_TEST_SRCS := $(patsubst %,$(TEST_DIR)/%.c,$(C_TEST_SRC_NAMES))

# Target Inputs:
#
# BUILD_DIR - See build directory structure above!

ifeq ($(BUILD_DIR),)
$(error Build directory not specified)
endif

BUILD_MOD_DIR 	:= $(BUILD_DIR)/$(MOD_NAME)

OBJS_DIR 		:= $(BUILD_MOD_DIR)/objs
C_OBJS 			:= $(patsubst %,$(OBJS_DIR)/c_%.o,$(C_SRC_NAMES))
S_OBJS 			:= $(patsubst %,$(OBJS_DIR)/S_%.o,$(S_SRC_NAMES))
C_TEST_OBJS  	:= $(patsubst %,$(OBJS_DIR)/c_test_%.o,$(C_TEST_SRC_NAMES))

DOTDS_DIR 		:= $(BUILD_MOD_DIR)/dotds


####################################################################################################

# Ok, now what? Target information?
# Dependencies?

