
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

# MODS
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

MODS_BUILD_DIR := $(BUILD_DIR)/mods
MODS_INSTALL_DIR := $(BUILD_DIR)/install

ALL_CFLAGS := $(CFLAGS) $(EXTRA_CFLAGS)
ALL_SFLAGS := $(SFLAGS) $(EXTRA_SFLAGS)

# We'll use this when invoking make on modules!
MOD_MAKE := $(MAKE) --no-print-directory \
			BUILD_DIR=$(MODS_BUILD_DIR) \
			INSTALL_DIR=$(MODS_INSTALL_DIR) \
			EXTRA_CFLAGS="$(ALL_CFLAGS)" \
 			EXTRA_SFLAGS="$(ALL_SFLAGS)" \
			COMPILER=$(COMPILER) \
			ARCHIVER=$(ARCHIVER)

ifndef MODS
$(error projects require at least one module be given)
endif

# Confirm that modules all have unique names.
# Remember that $(sort ...) removes duplicates!
MOD_NAMES := $(notdir $(MODS))

ifneq ($(words $(MOD_NAMES)),$(words $(sort $(MOD_NAMES))))
$(error project module names must be unique)
endif

PROJECT_PREFIX := p

# This is a helper for defining a "forwarding target" for a specific module.
# A "forwarding target" invokes the module's Makefile with whatever target is provided
# in the placeholder.
#
# The defined target is PHONY, however, you cannot place % into a PHONY declaration for 
# some reason. So the forwarding target for module <mod> will also define and depend on 
# phony target $(PROJECT_PREFIX)_phony.mod
#
# $1 - Module absolute path.
define MOD_FORWARD_TARGET 
.PHONY: $(PROJECT_PREFIX)_phony.$(notdir $(1))
$(PROJECT_PREFIX).%.$(notdir $(1)): $(PROJECT_PREFIX)_phony.$(notdir $(1))
	$Q$(MOD_MAKE) -C $(1) $$*
endef 

$(foreach mod_path,$(MODS),$(eval $(call MOD_FORWARD_TARGET,$(mod_path))))


$(PROJECT_PREFIX).%: $(foreach mod,$(MOD_NAMES),$(PROJECT_PREFIX).%.$(mod))
