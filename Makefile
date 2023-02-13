.PHONY: all clean install uninstall check shellcheck-library shellcheck-wrapper

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

install:
	install -D --mode=644 lib/libplayit2.sh $(DESTDIR)$(datadir)/play.it/libplayit2.sh
	install -D --mode=755 play.it $(DESTDIR)$(bindir)/play.it
	install -D man/man6/play.it.6 $(DESTDIR)$(mandir)/man6/play.it.6
	install -D man/fr/man6/play.it.6 $(DESTDIR)$(mandir)/fr/man6/play.it.6

uninstall:
	rm --force $(DESTDIR)$(bindir)/play.it $(DESTDIR)$(datadir)/play.it/libplayit2.sh $(DESTDIR)$(mandir)/man6/play.it.6 $(DESTDIR)$(mandir)/fr/man6/play.it.6
	rmdir -p --ignore-fail-on-non-empty $(DESTDIR)$(bindir) $(DESTDIR)$(datadir)/play.it $(DESTDIR)$(mandir)/man6 $(DESTDIR)$(mandir)/fr/man6

# Syntax checks relying on ShellCheck

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
