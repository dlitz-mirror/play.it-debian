# Build the library

.PHONY: all clean

## The debug code is omitted unless DEBUG is set to 1.
DEBUG := 0

all: lib/libplayit2.sh

lib/libplayit2.sh: src/*/*.sh
	mkdir --parents lib
ifeq ($(DEBUG),1)
	find src -type f -name '*.sh' -print0 | sort -z | xargs -0 cat > lib/libplayit2.sh
	sed -i -e 's/%%DEBUG_DISABLED%%/0/' lib/libplayit2.sh
else
	find src -type f -name '*.sh' \! -path 'src/80_debug/*' -print0 | sort -z | xargs -0 cat > lib/libplayit2.sh
	sed -i -e '/^\s*debug_/d' -e 's/%%DEBUG_DISABLED%%/1/' lib/libplayit2.sh
endif

clean:
	rm --force lib/libplayit2.sh


# Install the library, main script, and man pages

.PHONY: install uninstall

## Set the default install paths
UID := $(shell id --user)
ifeq ($(UID),0)
    prefix = /usr/local
    bindir = $(prefix)/games
    datadir = $(prefix)/share/games
    mandir = $(prefix)/share/man
else
    ifeq ($(XDG_DATA_HOME),)
        XDG_DATA_HOME := $(HOME)/.local/share
    endif
    prefix = $(XDG_DATA_HOME)
    bindir = $(HOME)/.local/bin
    datadir = $(prefix)
    mandir = $(prefix)/man
endif

install: all
	install -D --mode=644 lib/libplayit2.sh $(DESTDIR)$(datadir)/play.it/libplayit2.sh
	install -D --mode=755 play.it $(DESTDIR)$(bindir)/play.it
	install -D --mode=644 man/man6/play.it.6 $(DESTDIR)$(mandir)/man6/play.it.6
	install -D --mode=644 man/fr/man6/play.it.6 $(DESTDIR)$(mandir)/fr/man6/play.it.6

uninstall:
	rm --force $(DESTDIR)$(bindir)/play.it $(DESTDIR)$(datadir)/play.it/libplayit2.sh $(DESTDIR)$(mandir)/man6/play.it.6 $(DESTDIR)$(mandir)/fr/man6/play.it.6
	rmdir -p --ignore-fail-on-non-empty $(DESTDIR)$(bindir) $(DESTDIR)$(datadir)/play.it $(DESTDIR)$(mandir)/man6 $(DESTDIR)$(mandir)/fr/man6


# Release preparation

.PHONY: dist

## The generated tarball is signed with gpg by default,
## NO_SIGN should be set to a non-0 value to skip the signature.
NO_SIGN := 0

dist: VERSION := $(shell head --lines=1 CHANGELOG)
dist: TARBALL := play.it-$(VERSION).tar.gz
dist: TAR_OPTIONS := --sort=name --mtime=2017-06-14 --owner=root:0 --group=root:0 --use-compress-program='gzip --no-name'
dist: CHANGELOG LICENSE README.md Makefile play.it man/man6/play.it.6 man/*/man6/play.it.6 src/*/*.sh
	mkdir --parents dist
	LC_ALL=C tar cf dist/$(TARBALL) $(TAR_OPTIONS) CHANGELOG LICENSE README.md Makefile play.it man/man6/play.it.6 man/*/man6/play.it.6 src/*/*.sh
ifeq ($(NO_SIGN),0)
	rm --force dist/$(TARBALL).asc
	gpg --armor --detach-sign dist/$(TARBALL)
endif


# Syntax checks relying on ShellCheck

.PHONY: check shellcheck-library shellcheck-wrapper

check: shellcheck-library shellcheck-wrapper

## Expressions don't expand in single quotes, use double quotes for that.
shellcheck-library: SHELLCHECK_EXCLUDE := --exclude=SC2016
## Don't use variables in the printf format string. Use printf "..%s.." "$foo".
shellcheck-library: SHELLCHECK_EXCLUDE += --exclude=SC2059
## Double quote to prevent globbing and word splitting.
shellcheck-library: SHELLCHECK_EXCLUDE += --exclude=SC2086
## In POSIX sh, local is undefined.
shellcheck-library: SHELLCHECK_EXCLUDE += --exclude=SC3043
shellcheck-library: lib/libplayit2.sh
	shellcheck --shell=sh $(SHELLCHECK_EXCLUDE) lib/libplayit2.sh

shellcheck-wrapper: play.it
	shellcheck --external-sources --shell=sh play.it
