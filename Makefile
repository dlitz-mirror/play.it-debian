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
	rm --force play.it-2/lib/libplayit2.sh *.6

install:
	install -D --mode=644 play.it-2/lib/libplayit2.sh $(DESTDIR)$(datadir)/play.it/libplayit2.sh
	install -D --mode=755 play.it $(DESTDIR)$(bindir)/play.it
ifneq ($(wildcard play.it.6),)
	mkdir --parents $(DESTDIR)$(mandir)/man6
	gzip -c play.it.6 > $(DESTDIR)$(mandir)/man6/play.it.6.gz
else
	@echo "manpage not generated; skipping its installation"
endif

uninstall:
	rm --force $(DESTDIR)$(bindir)/play.it $(DESTDIR)$(datadir)/play.it/libplayit2.s $(DESTDIR)$(mandir)/man6/play.it.6.gz
	rmdir -p --ignore-fail-on-non-empty $(DESTDIR)$(bindir) $(DESTDIR)$(datadir)/play.it $(DESTDIR)$(mandir)/man6
