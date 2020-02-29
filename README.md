# ./play.it: Installer for DRM-free commercial games

The canonical repository is https://forge.dotslashplay.it/play.it/scripts,
issues and merge requests raised at mirrors will be migrated.

## Description

./play.it is a free software building native packages from installers for
Windows or Linux, mainly those sold by stores focusing on DRM-free games
distribution. The goal is that a game installed via ./play.it is
indistinguishable from a game installed via the official repositories of your
favourite distribution.

The games are installed globally on multi-user systems, avoiding unnecessary
duplication. The locations of save games, settings, mods, temporary files and
backups are standardized with XDG Base Directory support.

Packaging the games simplifies future updates, uninstalls and handling of any
necessary dependencies, including integrated obsolete dependencies if specific
versions are needed.

## Installation

You can check on Repology if ./play.it is packaged for your distribution:

[![latest packaged version]][repology]

[latest packaged version]: https://repology.org/badge/latest-versions/play.it.svg
[repology]: https://repology.org/metapackage/play.it

For Debian and derivatives (Ubuntu, Linux Mint, etc.): `apt install play.it`

For Arch Linux, AUR packages are provided:
* stable version: https://aur.archlinux.org/packages/play.it/
* development version: https://aur.archlinux.org/packages/play.it-git/

For Gentoo, an overlay is provided: https://framagit.org/BetaRays/gentoo-overlay

If your distribution does not already have a package for ./play.it, you can
install it from this git repository:
```
git clone https://forge.dotslashplay.it/play.it/scripts.git play.it.git
cd play.it.git
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

[some documentation]: https://forge.dotslashplay.it/play.it/scripts/wikis/home
[IRC]: irc://chat.freenode.net/#play.it
[Matrix]: https://matrix.to/#/!tKCYmGJvyaFDYHUmzm:matrix.org
[pastebin]: https://paste.debian.net/
[Merge Request]: https://forge.dotslashplay.it/play.it/scripts/merge_requests/new
