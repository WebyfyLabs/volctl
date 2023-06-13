VERSION = 0.99.9
PACKAGE_NAME = volctl

VOLCTL_BIN = volctl
VOLNTFY_BIN = volntfy
VOLNTFYD_BIN = volntfy-d
VOLNTFYD_DESKTOP = volntfy-d.desktop

PREFIX ?= /usr
PREFIX := $(realpath $(PREFIX))
BINDIR = $(PREFIX)/bin
DATADIR = $(PREFIX)/share/$(PACKAGE_NAME)
BASH_COMPLETION_DIR = $(PREFIX)/share/bash-completion/completions
AUTOSTART_DIR = /etc/xdg/autostart
RM = rm
Q = @

ifneq (,$(findstring ${HOME},$(PREFIX)))
	AUTOSTART_DIR = "${HOME}/.config/autostart"
endif

all: build/$(VOLCTL_BIN) build/$(VOLNTFYD_BIN) build/$(VOLNTFY_BIN) build/$(VOLNTFYD_DESKTOP)

build/$(VOLCTL_BIN): common/$(VOLCTL_BIN).in
	$(Q)mkdir -p build
	$(Q)sed -e 's|@DATADIR@|'$(DATADIR)'|' $<  >$@

build/$(VOLNTFY_BIN): common/$(VOLNTFY_BIN)
	$(Q)mkdir -p build
	$(Q)sed -e 's|DATADIR=""|DATADIR="'$(DATADIR)'"|' $<  >$@

build/$(VOLNTFYD_BIN): common/$(VOLNTFYD_BIN)
	$(Q)mkdir -p build
	$(Q)cp $< $@

build/$(VOLNTFYD_DESKTOP): common/$(VOLNTFYD_DESKTOP)
	$(Q)mkdir -p build
	$(Q)sed -e 's|@BINDIR@|'$(BINDIR)'|' $<  >$@

clean:
	$(RM) -f backup*.tgz
	$(RM) -rf build
	$(RM) -rf doc-pak

install:all
	install -Dm755 build/$(VOLCTL_BIN) "$(BINDIR)/$(VOLCTL_BIN)"
	install -Dm755 build/$(VOLNTFY_BIN) "$(BINDIR)/$(VOLNTFY_BIN)"
	install -Dm755 build/$(VOLNTFYD_BIN) "$(BINDIR)/$(VOLNTFYD_BIN)"
	install -Dm644 common/config.skel "$(DATADIR)/config.skel"
	# bash autocompletion
	install -p -dm755 "$(BASH_COMPLETION_DIR)"
	install -Dm644 common/volctl_completion "$(BASH_COMPLETION_DIR)/_volctl"
	# autostart
	install -p -dm755 "$(AUTOSTART_DIR)"
	install -Dm644 build/$(VOLNTFYD_DESKTOP) "$(AUTOSTART_DIR)/$(VOLNTFYD_DESKTOP)"

uninstall:
	$(RM) -f "$(BINDIR)/$(VOLCTL_BIN)"
	$(RM) -f "$(BINDIR)/$(VOLNTFY_BIN)"
	$(RM) -f "$(BINDIR)/$(VOLNTFYD_BIN)"
	$(RM) -f "$(BASH_COMPLETION_DIR)/_volctl"
	$(RM) -f "$(AUTOSTART_DIR)/$(VOLNTFYD_DESKTOP)"
	$(RM) -rf "$(DATADIR)"

deb:
	sudo checkinstall -D -y \
		--maintainer "webyfy \<info@webyfy.com\>" \
		--deldesc=yes \
		--deldoc=yes \
		--delspec=yes \
		--fstrans=no \
		--arch=all \
		--pkgname=$(PACKAGE_NAME) \
		--pkgversion=$(VERSION) \
		--pkgrelease=$$(date +"%Y%m%d") \
		--pkglicense=GPL \
		--requires="bash, pulseaudio-utils, coreutils, ncurses-bin, sound-theme-freedesktop, util-linux, python3-dbus" \
		--pakdir=build \
		--pkggroup=sound \
		--install=no

.PHONY: all clean uninstall deb test
