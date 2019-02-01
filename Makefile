.PHONY: all

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
    bindir = $(HOME)/bin
    datadir = $(prefix)
    mandir = $(prefix)/man
endif

PANDOC := $(shell command -v pandoc 2> /dev/null)

all: libplayit2.sh play.it.6

libplayit2.sh: play.it-2/src/*
	mkdir --parents play.it-2/lib
	cat play.it-2/src/* > play.it-2/lib/libplayit2.sh

%.6: %.6.md
ifneq ($(PANDOC),)
	$(PANDOC) --standalone $< --to man --output $@
else
	@echo "pandoc not installed; skipping $@"
endif

clean:
	rm -f play.it-2/lib/libplayit2.sh
	rm -f *.6

install:
	mkdir -p $(DESTDIR)$(bindir)
	cp -a play.it $(DESTDIR)$(bindir)
	mkdir -p $(DESTDIR)$(datadir)/play.it
	cp -a play.it-2/lib/libplayit2.sh play.it-2/games/* $(DESTDIR)$(datadir)/play.it
ifneq ($(PANDOC),)
	mkdir -p $(DESTDIR)$(mandir)/man6
	gzip -c play.it.6 > $(DESTDIR)$(mandir)/man6/play.it.6.gz
endif

uninstall:
	rm $(DESTDIR)$(bindir)/play.it
	rmdir -p --ignore-fail-on-non-empty $(DESTDIR)$(bindir) || true
	rm $(DESTDIR)$(datadir)/play.it/libplayit2.sh
	rm $(DESTDIR)$(datadir)/play.it/play-*.sh
	rmdir -p --ignore-fail-on-non-empty $(DESTDIR)$(datadir)/play.it
	rm --force $(DESTDIR)$(mandir)/man6/play.it.6.gz
	rmdir -p --ignore-fail-on-non-empty $(DESTDIR)$(mandir)/man6
