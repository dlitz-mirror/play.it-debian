# ./play.it: Installer for drm-free commercial games

The canonical repository is https://framagit.org/vv221/play.it, issues and PRs
raised at mirrors will be migrated.

## Description

The ./play.it tool builds .deb and .pkg packages from installers for Windows
or Linux, mainly those sold by GOG and Humble Bundle. The goal is that a game
installed via ./play.it is indistinguishable from a game installed via the
official repositories of your favorite distribution.

The games are installed globally on multi-user systems, avoiding unnecessary
duplication. The locations of save games, settings, mods, temporary files and
backups are standardized with XDG Base Directory support.

Packaging the games simplifies future updates, uninstalls and handling of any
necessary dependencies, including integrated obsolete dependencies if specific
versions are needed.

## Installation

For recent Debian-based distros: `apt install play.it` [![version]][repology]

[version]: https://repology.org/badge/latest-versions/play.it.svg
[repology]: https://repology.org/metapackage/play.it

For Archlinux users there is an AUR package [![aur]](https://aur.archlinux.org/packages/play.it/)

[aur]: http://badge.kloud51.com/aur/v/play.it.svg

For everyone else:

```
git clone https://framagit.org/vv221/play.it
cd play.it
make
make install
```

Once installed, you just need to provide a [supported game installer] as the
first argument to create the package.

[supported game installer]: https://wiki.dotslashplay.it/

## Contributing

There is [some documentation] on how to add support for new games, but the best
bet is to find a similar game and copy its script. You'll likely need to visit
\#play.it on [IRC]/[Matrix] to ask for more help. It can also be useful to
upload your attempts to [pastebin] for commentary, or feel free to raise a WIP
[Merge Request].

[some documentation]: https://framagit.org/vv221/play.it/wikis
[IRC]: irc://chat.freenode.net/#play.it
[Matrix]: https://matrix.to/#/!tKCYmGJvyaFDYHUmzm:matrix.org
[pastebin]: https://paste.debian.net/
[Merge Request]: https://framagit.org/vv221/play.it/merge_requests/new
