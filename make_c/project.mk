
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

################################# EXPORTED SYMBOLS AND TARGETS #####################################

# As `project.mk` doesn't really product a single binary, it is the responsibilty of the includer
# to package everything together however they see fit.
#
# To do this, `project.mk` defines some targets and symbols which are meant to be used later on in
# the including Makefile!
#
# Exported Symbols:
#
# MOD_NAMES
#  	 	Names of all modules. 	
#
# PROJECT_PREFIX
#  		To prevent collision with targets in the including Makefile, all targets (except for `help`)
#  		being with `$(PROJECT_PREFIX).`. 
#
# Exported Targets:
#
# $(PROJECT_PREFIX).lib
#  		Generate all module library files. (See $(BUILD_DIR)/install explained above)
#
# $(PROJECT_PREFIX).test_lib
#  		Generate all module test library files.
#
# NOTE: Nothing is stopping you from using anything defined in this file really. The targets
# and symbols listed here are just the most important.

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
	$(call USAGE_MSG,help,display this message)

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

# Creative way to make a "kinda" static map in Make!
# $(foreach mod_path,$(MODS),$(eval MOD_PATH_MAP_$(notdir $(mod_path)) := $(mod_path)))

PROJECT_PREFIX := p

# DESIGN NOTE: I used to have an abstract target forwarding scheme using pattern matching rules.
# This actually turned out to be quite confusing. How Make interprets non-explict patterned
# targets is very weird. Especially if those targets are intended to be PHONY.
#
# Anyway, now there is a preset list of targets which can be forwarded to modules.
MOD_FORWARD_TARGETS := \
			   help \
			   clangd \
			   clangd_clean \
			   lib \
			   test_lib

# NOTE: That in previous projects of mine I have always avoided dynamic make.
# In this situation though where we are mapping module names to their absolute paths, it is kinda
# required! Given just the name of a module, it is impossible to deduce its absolute path.
# This macro will pair them together by having access to the module absolute path when creating
# its rules!
#
# $1 - Absolute module path
define MOD_FORWARD_TARGETS_MACRO
MOD_FORWARD_TARGETS_$(notdir $(1)) := $(foreach mft,$(MOD_FORWARD_TARGETS),$(PROJECT_PREFIX).$(mft).$(notdir $(1)))
.PHONY: $$(MOD_FORWARD_TARGETS_$(notdir $(1)))
$$(MOD_FORWARD_TARGETS_$(notdir $(1))): $(PROJECT_PREFIX).%.$(notdir $(1)):
	$Q$(MOD_MAKE) -C $(1) $$*
endef 

$(foreach mod_path,$(MODS),$(eval $(call MOD_FORWARD_TARGETS_MACRO,$(mod_path))))

FULL_ALL_FORWARD_TARGETS := $(addprefix $(PROJECT_PREFIX).,$(MOD_FORWARD_TARGETS))
.PHONY: $(FULL_ALL_FORWARD_TARGETS)
$(FULL_ALL_FORWARD_TARGETS): $(PROJECT_PREFIX).%: $(foreach mod,$(MOD_NAMES),$(PROJECT_PREFIX).%.$(mod))

help::
	@echo -e ""
	@echo -e "  $(STYLE_BOLD)module target forwarding$(STYLE_RESET)"
	@echo -e "  project.mk allows certain targets to be invoked on modules directly from this"
	@echo -e "  directory. To do so, use the following patterns."
	@echo -e ""
	$(call USAGE_MSG,$(PROJECT_PREFIX).<targ>.<mod>,invoke target <targ> on module <mod>)
	$(call USAGE_MSG,$(PROJECT_PREFIX).<targ>,invoke target <targ> on all modules)
	@echo -e ""
	@echo -e "  <targ> \in $(STYLE_BOLD)$(MOD_FORWARD_TARGETS)$(STYLE_RESET)"
	@echo -e "  <mod>  \in $(STYLE_BOLD)$(MOD_NAMES)$(STYLE_RESET)"
	@echo -e ""
	@echo -e "  If unsure what a value of <targ> does, invoke $(PROJECT_PREFIX).help.<mod>"
	@echo -e "  for any valid value of <mod>. This will display module make targets."

.PHONY: $(PROJECT_PREFIX).clean
$(PROJECT_PREFIX).clean:
	$(call CLEAN_MSG,$(BUILD_DIR))
	$Qrm -rf $(BUILD_DIR)

help::
	@echo -e ""
	$(call USAGE_MSG,clean,delete build directory)



