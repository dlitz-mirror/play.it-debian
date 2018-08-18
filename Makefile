.PHONY: all

prefix = /usr/local
bindir = $(prefix)/games
datadir = $(prefix)/share/games
mandir = $(prefix)/share/man

PANDOC := $(shell command -v pandoc 2> /dev/null)

all: libplayit2.sh play.it.6

libplayit2.sh: play.it-2/src/*
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
	rm -r $(DESTDIR)$(datadir)/play.it
	rm -f $(DESTDIR)$(mandir)/man6/play.it.6.gz
