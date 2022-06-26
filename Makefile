.PHONY: all clean install uninstall

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

all: libplayit2.sh

libplayit2.sh: play.it-2/src/*
	mkdir --parents play.it-2/lib
ifeq ($(DEBUG),1)
	cat play.it-2/src/* > play.it-2/lib/libplayit2.sh
	sed -i -e 's/%%DEBUG_DISABLED%%/0/' play.it-2/lib/libplayit2.sh
else
	find play.it-2/src -maxdepth 1 -type f '!' -name '85_messages_debug.sh' -print0 | sort -z | xargs -0 cat > play.it-2/lib/libplayit2.sh
	sed -i -e '/^\s*debug_/d' -e 's/%%DEBUG_DISABLED%%/1/' play.it-2/lib/libplayit2.sh
endif

clean:
	rm --force play.it-2/lib/libplayit2.sh

install:
	install -D --mode=644 play.it-2/lib/libplayit2.sh $(DESTDIR)$(datadir)/play.it/libplayit2.sh
	install -D --mode=755 play.it $(DESTDIR)$(bindir)/play.it
	install -D man/man6/play.it.6 $(DESTDIR)$(mandir)/man6/play.it.6
	install -D man/fr/man6/play.it.6 $(DESTDIR)$(mandir)/fr/man6/play.it.6

uninstall:
	rm --force $(DESTDIR)$(bindir)/play.it $(DESTDIR)$(datadir)/play.it/libplayit2.sh $(DESTDIR)$(mandir)/man6/play.it.6 $(DESTDIR)$(mandir)/fr/man6/play.it.6
	rmdir -p --ignore-fail-on-non-empty $(DESTDIR)$(bindir) $(DESTDIR)$(datadir)/play.it $(DESTDIR)$(mandir)/man6 $(DESTDIR)$(mandir)/fr/man6
