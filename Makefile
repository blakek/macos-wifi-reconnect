NAME ?= wifi-reconnect.bash
PREFIX ?= /usr/local/bin
LAUNCH_LOCATION ?= $(HOME)/Library/LaunchAgents
LAUNCH_NAME ?= me.blakek.wifi-reconnect.plist

.PHONY: all
all: install

$(LAUNCH_NAME):
	sed -e "s|{{prefix}}|$(PREFIX)|g" \
		-e "s|{{name}}|$(NAME)|g" \
		-e "s|{{launchName}}|$(LAUNCH_NAME)|g" \
		`pwd`/launch-agent.template.plist > $(LAUNCH_NAME)

.PHONY: install-launchd
install-launchd: $(LAUNCH_NAME)
	mv `pwd`/$(LAUNCH_NAME) $(LAUNCH_LOCATION)/$(LAUNCH_NAME)

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
	rm $(LAUNCH_LOCATION)/$(LAUNCH_NAME)
