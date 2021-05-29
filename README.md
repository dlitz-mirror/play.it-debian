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

### Distributions providing ./play.it

The following distributions provide installation instructions in their official
documentation:

* [Debian]
* [Gentoo]
* [Ubuntu] (French article)

[Debian]: https://wiki.debian.org/Games/PlayIt#Installation
[Gentoo]: https://wiki.gentoo.org/wiki/Play.it#Installation
[Ubuntu]: https://doc.ubuntu-fr.org/play.it#installation

In most cases, these instructions should work in the same way for derivatives
of these distributions.

### Installation from git

If your distribution does not already have a package for ./play.it, you can
install it from this git repository.

#### Latest stable version

```
git clone --branch 2.13.1 --depth 1 https://forge.dotslashplay.it/play.it/scripts.git play.it.git
cd play.it.git
make
make install
```

#### Current development version

```
git clone --branch master --depth 1 https://forge.dotslashplay.it/play.it/scripts.git play.it.git
cd play.it.git
make
make install
```

## Usage

Once installed, you just need to provide a [supported game installer] as the
first argument to create the package.

[supported game installer]: https://wiki.dotslashplay.it/

## Contributing

There is [some documentation] on how to add support for new games, but the best
bet is to find a similar game and copy its script. You'll likely need to visit
our IRC channel to ask for more help. It can also be useful to
upload your attempts to [pastebin] for commentary, or feel free to raise a WIP
[Merge Request].

[some documentation]: https://forge.dotslashplay.it/play.it/scripts/wikis/home
[pastebin]: https://paste.debian.net/
[Merge Request]: https://forge.dotslashplay.it/play.it/scripts/merge_requests/new

## Contact informations

### IRC channel

Some ./play.it developers and users can be reached on IRC, channel is `#play.it` on server `irc.oftc.net`.
The main language on this IRC channel is English.

A secondary channel is provided for French speakers, `#play.it` on server `irc.geeknode.net`.
A clever bot will automatically translate and share messages between the English and French channels.

### E-mail

A contact e-mail for feedback can usually be found in each ./play.it game script, as well as in the library.
Open one of these files with any text editor to see the contact e-mail.
