NAME ?= wifi-reconnect.bash
PREFIX ?= /usr/local/bin
LAUNCH_LOCATION ?= /Library/LaunchDaemons
LAUNCH_NAME ?= me.blakek.wifi-reconnect

.PHONY: all
all: install

.PHONY: set-debug-vars
set-debug-vars:
	@echo "Setting debug variables"
	$(eval DEBUG_ARGS ?= <string>--verbose</string><string>--interval</string><string>10</string>)
	$(eval DEBUG_CONFIG ?= <key>StandardOutPath</key><string>/tmp/$(LAUNCH_NAME).log</string><key>StandardErrorPath</key><string>/tmp/$(LAUNCH_NAME).log</string>)

$(LAUNCH_NAME).plist:
	sed -e "s|{{prefix}}|$(PREFIX)|g" \
		-e "s|{{name}}|$(NAME)|g" \
		-e "s|{{launchName}}|$(LAUNCH_NAME)|g" \
		-e "s|{{debugArgs}}|$(DEBUG_ARGS)|g" \
		-e "s|{{debugConfig}}|$(DEBUG_CONFIG)|g" \
		`pwd`/launch-agent.template.plist > $(LAUNCH_NAME).plist

.PHONY: install-launchd
install-launchd: $(LAUNCH_NAME).plist
	mv `pwd`/$(LAUNCH_NAME).plist $(LAUNCH_LOCATION)/$(LAUNCH_NAME).plist

# Moves the built binary to the installation prefix
.PHONY: install
install: install-launchd
	cp `pwd`/wifi-reconnect.bash $(PREFIX)/$(NAME)

# Alternate to install (for local development). Symlinks from this directory to
# the installation prefix.
.PHONY: symlink
symlink: install-launchd
	ln -s `pwd`/wifi-reconnect.bash $(PREFIX)/$(NAME)

# Removes the binary from the installation prefix
.PHONY: uninstall
uninstall:
	rm $(PREFIX)/$(NAME)
	rm $(LAUNCH_LOCATION)/$(LAUNCH_NAME).plist

# Loads the launchd agent
.PHONY: load
load:
	launchctl load $(LAUNCH_LOCATION)/$(LAUNCH_NAME).plist

# Unloads the launchd agent
.PHONY: unload
unload:
	launchctl unload $(LAUNCH_LOCATION)/$(LAUNCH_NAME).plist

# Full install and load for testing
.PHONY: install-debug
install-debug: set-debug-vars install load

# Full uninstall and unload for testing
.PHONY: uninstall-debug
uninstall-debug: set-debug-vars unload uninstall
