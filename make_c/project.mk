
####################################################################################################
#####                                     EXPECTED USAGE                                        ####
####################################################################################################

# Like `module.mk`, `project.mk` is meant to be included.
#
# Unlike `module.mk`, it is not intended to be comprehensive! It will provide targets for 
# building and installing module. However, it will NOT provide any sort of linking targets.
#
# We would expect and including Makefile to look something like this:
#
# ```
# STATIC_INPUT_1 := my_input_1
# STATIC_INPUT_2 := my_input_2
# ...
# STATIC_INPUT_N := my_input_N
#
# include path/to/colors.mk
# include path/to/project.mk
#
# binary_1: prereqs
# 	recipe
#
# binary_2: prereqs
# 	recipe
# ...
# ```
#
# The intention is to keep `project.mk` both useful AND portable.
# How built libraries are ultimately used is entirely project specific!

####################################################################################################
#####                                 PRIMARY BUILD OUTPUTS                                     ####
####################################################################################################

# BUILD_DIR Generated Structure:
#
# $(BUILD_DIR)/
#  	mods/
#  	  <mod1>/
#  	    ... mod1 build outputs ...
#  	  <mod2>/
#  	    ...
#  	  ...
#  	  <modN>/
#  	    ...
#  	install/
#  	  lib<mod1>.a
#  	  libtest_<mod1>.a
#  	  lib<mod2>.a
#  	  libtest_<mod2>.a
#  	  ...
#  	  lib<modN>.a
#  	  libtest_<modN>.a
#  	

####################################################################################################
#####                                         INPUTS                                            ####
####################################################################################################

# `project.mk` uses the same "Static/Dynamic" inputs scheme outlined in `module.mk`.

######################################## Static Inputs #############################################

# MODULES
#  		A list of absolute paths to module which should all be built.
#  		NOTE: It is essential that module names in this list are UNIQUE!
#  	
# CFLAGS 
# 	 	C compiler flags to pass to all modules using the module specific EXTRA_CFLAGS dynamic input
#
# SFLAGS
#  		Assembler flags to pass to all modules using the module specific EXTRA_SFLAGS dynamic input.

####################################### Dynamic Inputs #############################################

# EXTRA_CFLAGS
#  		If for some reason you want to add more flags when building, use this instead of 
#  		overriding CFLAGS. 
#
# EXTRA_SFLAGS
#  		Just like EXTRA_CFLAGS, but for compiling the assembly files.
#
# NOTE: Kinda like with `module.mk` there is a distinction between flags and "extra flags".
# Static flags should be defined once and never overriden. This project NEEDs thos flags to
# work. "extra flags" are more flexible, maybe you want an extra warning enabled. These are not 
# imperative and can be different depending on the build. (Hence why they are dynamic)
# "extra flags" and "static flags" are ultimately concatenated and passed to modules using the 
# EXTRA_(C/S)FLAGS module dynamic input!

#################################### Dynamic/Static Inputs #########################################

# BUILD_DIR
#  		See BUILD_DIR benerated structure above.

BUILD_DIR ?= $(CURDIR)/build

# COMPILER
#  		The Compiler to use for C compilation and assembling!
# ARCHIVER
#  		The Archiver to use!

COMPILER ?= gcc
ARCHIVER ?= ar

####################################################################################################
#####                                        TARGETS                                            ####
####################################################################################################

# Project name is inferred just like for modules!
PROJECT_NAME := $(notdir $(CURDIR))

.PHONY: help
help::
	@echo -e "Make Targets for $(STYLE_BOLD)$(STYLE_BRIGHT_CYAN)$(PROJECT_NAME)$(STYLE_RESET)"
