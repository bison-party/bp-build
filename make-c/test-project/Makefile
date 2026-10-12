GIT_TOP := $(shell git rev-parse --show-toplevel)

MODS := $(abspath ./module2) $(abspath ./module1)

include $(GIT_TOP)/colors.mk
include $(GIT_TOP)/make-c/project.mk

BIN := $(BUILD_DIR)/test

$(BIN): $(MOD_LIBS) $(MOD_TEST_LIBS)
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

help::
	@echo -e ""
	$(call USAGE_MSG,bin,build project binary)


.PHONY: clean docs
clean docs: %: $(PROJECT_PREFIX).%

help::
	$(call USAGE_MSG,docs,alias for $(PROJECT_PREFIX).docs)
	$(call USAGE_MSG,clean,alias for $(PROJECT_PREFIX).clean)
