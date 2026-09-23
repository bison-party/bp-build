####################################################################################################
#####                                     EXPECTED USAGE                                        ####
####################################################################################################

# colors.mk is not very restrictive in its usage. It's intended to be included in a Makefile
# early on. Thus, allowing for later defined targets to use helper macros below!

####################################################################################################
#####                                         INPUTS                                            ####
####################################################################################################

# NOT_TERMINAL
#  		When outputing to a file, ANSI terminal commands should not be printed.
#  		When NOT_TERMINAL is defined, all ANSI macros below are left undefined!
#
# VERBOSE
#  		When left undefined, the macro Q is set to @. It is intended that the including Makefile
#  		prefixes lengthy commands with $Q. Thus, such commands are only echo'd when VERBOSE
#  		is defined!

# There is no preference for how inputs should be provided. (Unlike Dynamic/Static inputs outlined
# in `make_c/module.mk`)

####################################################################################################
#####                                    DECLARATIONS                                           ####
####################################################################################################

ifndef NOT_TERMINAL
STYLE_ESC := \033
STYLE_RESET := $(STYLE_ESC)[0m

STYLE_BOLD := $(STYLE_ESC)[1m
STYLE_DIM := $(STYLE_ESC)[2m
STYLE_ITALIC := $(STYLE_ESC)[3m
STYLE_UNDERLINE := $(STYLE_ESC)[4m
STYLE_BLINK := $(STYLE_ESC)[5m
STYLE_REVERSE := $(STYLE_ESC)[7m
STYLE_HIDDEN := $(STYLE_ESC)[8m
STYLE_STRIKE := $(STYLE_ESC)[9m

STYLE_BLACK := $(STYLE_ESC)[30m
STYLE_RED := $(STYLE_ESC)[31m
STYLE_GREEN := $(STYLE_ESC)[32m
STYLE_YELLOW := $(STYLE_ESC)[33m
STYLE_BLUE := $(STYLE_ESC)[34m
STYLE_MAGENTA := $(STYLE_ESC)[35m
STYLE_CYAN := $(STYLE_ESC)[36m
STYLE_WHITE := $(STYLE_ESC)[37m

STYLE_BRIGHT_BLACK := $(STYLE_ESC)[90m
STYLE_BRIGHT_RED := $(STYLE_ESC)[91m
STYLE_BRIGHT_GREEN := $(STYLE_ESC)[92m
STYLE_BRIGHT_YELLOW := $(STYLE_ESC)[93m
STYLE_BRIGHT_BLUE := $(STYLE_ESC)[94m
STYLE_BRIGHT_MAGENTA := $(STYLE_ESC)[95m
STYLE_BRIGHT_CYAN := $(STYLE_ESC)[96m
STYLE_BRIGHT_WHITE := $(STYLE_ESC)[97m

STYLE_BG_BLACK := $(STYLE_ESC)[40m
STYLE_BG_RED := $(STYLE_ESC)[41m
STYLE_BG_GREEN := $(STYLE_ESC)[42m
STYLE_BG_YELLOW := $(STYLE_ESC)[43m
STYLE_BG_BLUE := $(STYLE_ESC)[44m
STYLE_BG_MAGENTA := $(STYLE_ESC)[45m
STYLE_BG_CYAN := $(STYLE_ESC)[46m
STYLE_BG_WHITE := $(STYLE_ESC)[47m

STYLE_BG_BRIGHT_BLACK := $(STYLE_ESC)[100m
STYLE_BG_BRIGHT_RED := $(STYLE_ESC)[101m
STYLE_BG_BRIGHT_GREEN := $(STYLE_ESC)[102m
STYLE_BG_BRIGHT_YELLOW := $(STYLE_ESC)[103m
STYLE_BG_BRIGHT_BLUE := $(STYLE_ESC)[104m
STYLE_BG_BRIGHT_MAGENTA := $(STYLE_ESC)[105m
STYLE_BG_BRIGHT_CYAN := $(STYLE_ESC)[106m
STYLE_BG_BRIGHT_WHITE := $(STYLE_ESC)[107m
endif

ifndef VERBOSE
Q := @
endif

USAGE_MSG = @printf "  $(STYLE_BOLD)$(STYLE_BRIGHT_YELLOW)%-16.16s$(STYLE_RESET) %s\n" "$1" "$2";

GET_TIME = $(shell date '+%H:%M:%S')

# $1 - Name of Action
# $2 - Style of Action
# $3 - Action description
ACTION_MSG = @printf "$(STYLE_BOLD)$(STYLE_BRIGHT_BLACK)%s$(STYLE_RESET)  $2%-10.10s$(STYLE_RESET) $(STYLE_ITALIC)%s$(STYLE_RESET)\n" \
			 "$(GET_TIME)" "$1" "$3"

# Different action types which may be helpful!
CLEAN_MSG 	= $(call ACTION_MSG,CLEAN,$(STYLE_BLUE),$1)
GEN_MSG   	= $(call ACTION_MSG,GEN,$(STYLE_GREEN),$1)
DOTD_MSG   	= $(call ACTION_MSG,DOTD,$(STYLE_MAGENTA),$1)
ASM_MSG   	= $(call ACTION_MSG,ASM,$(STYLE_RED),$1)
COMPILE_MSG = $(call ACTION_MSG,COMPILE,$(STYLE_CYAN),$1)
PACKAGE_MSG = $(call ACTION_MSG,PACKAGE,$(STYLE_YELLOW),$1)
