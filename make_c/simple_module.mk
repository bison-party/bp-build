
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

C_PREFIX 		:= c_
S_PREFIX 		:= S_
C_TEST_PREFIX 	:= c_test_

####################################################################################################
#####                                         INPUTS                                            ####
####################################################################################################

###### VERY IMPORTANT ######
# A simple module has TWO different categories of inputs. If you specify inputs in the incorrect
# manner, this template may note work as expected!!!
#
# 1) Static Inputs
#  		A "Static Input" is an input which should not meant to change via command line arguments.
#  		The Makefile which includes this template should first specify the static inputs.
#  		Think the names of source files.
#  		These inputs are likely ALWAYS required to be specified, regardless of the target.
#
# 2) Dynamic Inputs
#  		A "Dynamic Input" is meant to be specified on the command line when the including Makefile
#  		is invoked. Think build directory.
#  		A "Dynamic Input" may be required for one target, but not for another.
#  		For example, a build directory should not be required for printing out usage instructions!
#
# The idea here is to make a distinction between when should be specified when invoking the 
# including Makefile, and what is actually just declared in the including Makefile.

######################################## Static Inputs #############################################

# C_SRC_NAMES
#  		Names of all `.c` source files that should be compiled from $(MOD_NAME)/src.
#
# S_SRC_NAMES
#  		Names of all `.S` source files that should be compiled from $(MOD_NAME)/src.
#
# C_TEST_SRC_NAMES
#  		Names of all `.c` source files that should be compiled from $(MOD_NAME)/test.
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

# DEPS
#  		A list of absolute paths to other modules which this module depends on.
#  		In this context a "module" does NOT need to be a simple module.
#  		A "module" in this context is just a directory with a Makefile which specifies target
#  		"includes". This target should print the path of all include directories inside the module
#  		and depended on by the module.
#
# INCS
#  		Similar to DEPS, but less structured, this is literally just a list of absolute paths to 
#  		directories that should be included.
#
# NOTE: The full list of include directories derived from DEPS and INCS is given when compiling
# ALL source files! (`.c`, `.S`, and test `.c` files)

# CFLAGS
#  		A list of C compile flags to be specified when compiling `.c` files and test `.c` files.
#  		While you could technically add -I flags here, it is recommended you instead use INCS 
#  		and DEPS above.
#
# SFLAGS
#  		A list of S compile flags to be specified when compiling `.S` files.


####################################### Dynamic Inputs #############################################

# BUILD_DIR - See build directory structure above!

ifeq ($(BUILD_DIR),)
$(error Build directory not specified)
endif

BUILD_MOD_DIR 	:= $(BUILD_DIR)/$(MOD_NAME)

OBJS_DIR 		:= $(BUILD_MOD_DIR)/objs
C_OBJS 			:= $(patsubst %,$(OBJS_DIR)/$(C_PREFIX)%.o,$(C_SRC_NAMES))
S_OBJS 			:= $(patsubst %,$(OBJS_DIR)/$(S_PREFIX)%.o,$(S_SRC_NAMES))
C_TEST_OBJS  	:= $(patsubst %,$(OBJS_DIR)/$(C_TEST_PREFIX)%.o,$(C_TEST_SRC_NAMES))

DOTDS_DIR 		:= $(BUILD_MOD_DIR)/dotds
C_DOTDS 		:= $(patsubst %,$(DOTDS_DIR)/$(C_PREFIX)%.d,$(C_SRC_NAMES))
S_DOTDS 		:= $(patsubst %,$(DOTDS_DIR)/$(S_PREFIX)%.d,$(S_SRC_NAMES))
C_TEST_DOTDS  	:= $(patsubst %,$(OBJS_DIR)/$(C_TEST_PREFIX)%.d,$(C_TEST_SRC_NAMES))

# EXTRA_CFLAGS
#  		If for some reason you want to add more flags when building, use this instead of 
#  		overriding CFLAGS. 
#
# EXTRA_SFLAGS
#  		Just like EXTRA_CFLAGS, but for compiling the assembly files.
#

#################################### Dynamic/Static Inputs #########################################

# NOTE: These are inputs which really don't fall into one of the above categories nicely.
# Declare them however you feel appropriate!

# COMPILER
#  		The Compiler to use for C compilation and assembling!
# ARCHIVER
#  		The Archiver to use!

COMPILER ?= gcc
ARCHIVER ?= ar

# NOTE: I don't use the builtins AR or CC here because I don't like how those are always defined.

####################################################################################################

