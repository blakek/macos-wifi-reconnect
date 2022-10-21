NAME ?= wifi-reconnect.bash
PREFIX ?= /usr/local/bin
LAUNCH_LOCATION ?= /Library/LaunchDaemons
LAUNCH_NAME ?= me.blakek.wifi-reconnect

.PHONY: all
all: install

$(LAUNCH_NAME).plist:
	sed -e "s|{{prefix}}|$(PREFIX)|g" \
		-e "s|{{name}}|$(NAME)|g" \
		-e "s|{{launchName}}|$(LAUNCH_NAME)|g" \
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
