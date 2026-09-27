GIT_TOP := $(shell git rev-parse --show-toplevel)

MODS := $(abspath ./module2) $(abspath ./module1)

include $(GIT_TOP)/colors.mk
include $(GIT_TOP)/make_c/project.mk

BIN := $(BUILD_DIR)/test

$(BIN): $(MOD_LIBS) $(MOD_TEST_LIBS) | $(BUILD_DIR)
	@echo "$(HLINE)"
	$(call LINK_MSG,$@)
	$Q$(COMPILER) -L$(MODS_INSTALL_DIR) \
		-Wl,--start-group \
		$(MOD_LIBS_FLAGS) $(MOD_TEST_LIBS_FLAGS) \
		-Wl,--end-group \
		-z noexecstack \
		-o $@

.PHONY: bin
bin: $(BIN)

t:
	@echo "$(MOD_LIBS) $(MOD_TEST_LIBS)"

help::
	$(call USAGE_MSG,bin,build project binary)


.PHONY: clean
clean: $(PROJECT_PREFIX).clean

help::
	$(call USAGE_MSG,clean,alias for $(PROJECT_PREFIX).clean)
