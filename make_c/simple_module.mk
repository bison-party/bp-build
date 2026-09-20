
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

# NOTE: In the "Inputs" sections below I organize definitions in a way I find intuitive.
# The comments are what define the actual expected inputs.
# For example, `INC_DIR` below is not an input, but `C_SRC_NAMES` is!

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

# DESIGN NOTE:
# There have been build tools I've designed which allow for specifying headers individually.
# The idea being that configuration files could conditionally select which headers
# to specify in the including Makefile.
# In the design here though, I have decided against going down this path.
# Header files are never copied out of their original include directories and modules always
# give access to ALL headers in their include directory.

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

# BUILD_DIR 
#  		See build directory structure above!

# EXTRA_CFLAGS
#  		If for some reason you want to add more flags when building, use this instead of 
#  		overriding CFLAGS. 
#
# EXTRA_SFLAGS
#  		Just like EXTRA_CFLAGS, but for compiling the assembly files.

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
#####                                        TARGETS                                            ####
####################################################################################################


################################## Basic Module Organization #######################################

# Module name is inferred!
MOD_NAME := $(notdir $(CURDIR))

INC_DIR 	:= $(CURDIR)/include
SRC_DIR		:= $(CURDIR)/src
TEST_DIR 	:= $(CURDIR)/test

.PHONY: construct
construct:
	mkdir -p $(INC_DIR)/$(MOD_NAME)/test
	mkdir -p $(SRC_DIR)
	mkdir -p $(TEST_DIR)

C_SRCS  	:= $(patsubst %,$(SRC_DIR)/%.c,$(C_SRC_NAMES))
S_SRCS  	:= $(patsubst %,$(SRC_DIR)/%.S,$(S_SRC_NAMES))
C_TEST_SRCS := $(patsubst %,$(TEST_DIR)/%.c,$(C_TEST_SRC_NAMES))

######################################## Flag Resolution ###########################################

# Getting include directory paths from dependencies is a slow operation.
# This is the list of targets that need these paths.
DEPS_RES_TARGETS 	:= includes clangd dotds objs

ifneq ($(filter $(DEPS_RES_TARGETS),$(MAKECMDGOALS)),) 
DEPS_INCS 		:= $(foreach dep,$(DEPS),$(shell $(MAKE) --no-print-directory -C $(dep) includes))
endif

ALL_INCS  		:= $(INC_DIR) $(DEPS_INCS) $(INCS)

.PHONY: includes
includes:
	@echo "$(ALL_INCS)"

ALL_INCS_FLAGS 	:= $(addprefix -I,$(ALL_INCS))

ALL_CFLAGS := $(CFLAGS) $(EXTRA_CFLAGS) $(ALL_INCS_FLAGS)
ALL_SFLAGS := $(SFLAGS) $(EXTRA_SFLAGS) $(ALL_INCS_FLAGS)

CLANGD := $(CURDIR)/.clangd
$(CLANGD):
	echo "CompileFlags:" > $@
	echo "  Compiler: $(COMPILER)" >> $@
	echo "  Add:" >> $@
	$(foreach f,$(ALL_CFLAGS),echo "    - $(f)" >> $@;)

.PHONY: clangd clangd.clean
clangd: $(CLANGD)
clangd.clean:
	rm -f $(CLANGD)

########################################## Compilation #############################################

C_PREFIX 		:= c_
S_PREFIX 		:= S_
C_TEST_PREFIX 	:= c_test_

BUILD_MOD_DIR 	:= $(BUILD_DIR)/$(MOD_NAME)

# List of targets which require BUILD_DIR be specified!
BUILD_DIR_TARGETS := clean dotds test_dotds

ifneq ($(filter $(BUILD_DIR_TARGETS),$(MAKECMDGOALS)),) 
ifeq ($(BUILD_DIR),)
$(error BUILD_DIR must be specified for requested target(s))
endif
endif

.PHONY: clean
clean: 
	rm -rf $(BUILD_MOD_DIR)

### .d files

DOTDS_DIR 		:= $(BUILD_MOD_DIR)/dotds
OBJS_DIR 		:= $(BUILD_MOD_DIR)/objs

C_DOTDS 		:= $(patsubst %,$(DOTDS_DIR)/$(C_PREFIX)%.d,$(C_SRC_NAMES))
S_DOTDS 		:= $(patsubst %,$(DOTDS_DIR)/$(S_PREFIX)%.d,$(S_SRC_NAMES))
C_TEST_DOTDS  	:= $(patsubst %,$(DOTDS_DIR)/$(C_TEST_PREFIX)%.d,$(C_TEST_SRC_NAMES))
ALL_DOTDS 		:= $(C_DOTDS) $(S_DOTDS) $(C_TEST_DOTDS)

$(DOTDS_DIR):
	mkdir -p $@

$(C_DOTDS): $(DOTDS_DIR)/$(C_PREFIX)%.d: $(SRC_DIR)/%.c | $(DOTDS_DIR)
	$(COMPILER) $(ALL_INCS_FLAGS) $< -MM -MT "$(OBJS_DIR)/$(C_PREFIX)$*.o" -MF $@

$(S_DOTDS): $(DOTDS_DIR)/$(S_PREFIX)%.d: $(SRC_DIR)/%.S | $(DOTDS_DIR)
	$(COMPILER) $(ALL_INCS_FLAGS) $< -MM -MT "$(OBJS_DIR)/$(S_PREFIX)$*.o" -MF $@

.PHONY: dotds
dotds: $(C_DOTDS) $(S_DOTDS)

# List of targets which require C_DOTDS and S_DOTDS be built and included!
DOTDS_TARGETS :=
ifneq ($(filter $(DOTDS_TARGETS),$(MAKECMDGOALS)),) 
include $(C_DOTDS) $(S_DOTDS)
endif

$(C_TEST_DOTDS): $(DOTDS_DIR)/$(C_TEST_PREFIX)%.d: $(TEST_DIR)/%.c | $(DOTDS_DIR)
	$(COMPILER) $(ALL_INCS_FLAGS) $< -MM -MT "$(OBJS_DIR)/$(C_TEST_PREFIX)$*.o" -MF $@

.PHONY: test_dotds
test_dotds: $(C_TEST_DOTDS)

# List of targets which require C_TEST_DOTDS be built and included!
TEST_DOTDS_TARGETS :=
ifneq ($(filter $(TEST_DOTDS_TARGETS),$(MAKECMDGOALS)),) 
include $(C_TEST_DOTDS)
endif

### .o files

C_OBJS 			:= $(patsubst %,$(OBJS_DIR)/$(C_PREFIX)%.o,$(C_SRC_NAMES))
S_OBJS 			:= $(patsubst %,$(OBJS_DIR)/$(S_PREFIX)%.o,$(S_SRC_NAMES))
C_TEST_OBJS  	:= $(patsubst %,$(OBJS_DIR)/$(C_TEST_PREFIX)%.o,$(C_TEST_SRC_NAMES))
ALL_OBJS 		:= $(C_OBJS) $(S_OBJS) $(C_TEST_OBJS)

ifneq ($(filter objs,$(MAKECMDGOALS)),)
ifeq ($(BUILD_DIR),)
$(error `objs` requires a build directory)
endif
include $(ALL_DOTDS)
endif

.PHONY: objs
objs: $(ALL_OBJS)



