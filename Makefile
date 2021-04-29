.PHONY: all clean install uninstall install-library install-games install-wrapper install-manpage

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

install-library:
	install -D --mode=644 play.it-2/lib/libplayit2.sh $(DESTDIR)$(datadir)/play.it/libplayit2.sh

install-games:
	install -D --mode=755 --target-directory=$(DESTDIR)$(datadir)/play.it play.it-2/games/*

install-wrapper:
	install -D --mode=755 play.it $(DESTDIR)$(bindir)/play.it

install-manpage:
ifneq ($(wildcard play.it.6),)
	mkdir --parents $(DESTDIR)$(mandir)/man6
	gzip -c play.it.6 > $(DESTDIR)$(mandir)/man6/play.it.6.gz
else
	@echo "manpage not generated; skipping its installation"
endif


install: install-library install-games install-wrapper install-manpage

uninstall:
	rm $(DESTDIR)$(bindir)/play.it
	rmdir -p --ignore-fail-on-non-empty $(DESTDIR)$(bindir) || true
	rm $(DESTDIR)$(datadir)/play.it/libplayit2.sh
	rm $(DESTDIR)$(datadir)/play.it/play-*.sh
	rmdir -p --ignore-fail-on-non-empty $(DESTDIR)$(datadir)/play.it
	rm --force $(DESTDIR)$(mandir)/man6/play.it.6.gz
	rmdir -p --ignore-fail-on-non-empty $(DESTDIR)$(mandir)/man6
