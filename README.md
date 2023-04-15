# ./play.it: Installer for DRM-free commercial games

The canonical repository is https://forge.dotslashplay.it/play.it/scripts, issues and merge requests raised at mirrors will probably be missed.

## Description

./play.it is a free software building native packages from installers for Windows or Linux, mainly those sold by stores focusing on DRM-free games distribution. The goal is that a game installed via ./play.it is indistinguishable from a game installed via the official repositories of your favourite distribution.

The games are installed globally on multi-user systems, avoiding unnecessary duplication. The locations of save games, settings, mods, temporary files and backups are standardized with XDG Base Directory support.

Packaging the games simplifies future updates, uninstalls and handling of any necessary dependencies, including integrated obsolete dependencies if specific versions are needed.

## Installation

### Distributions providing ./play.it

The following distributions provide installation instructions in their official documentation:

- [Debian]
- [Gentoo]
- [Ubuntu] (French article)

[Debian]: https://wiki.debian.org/Games/PlayIt#Installation
[Gentoo]: https://wiki.gentoo.org/wiki/Play.it#Installation
[Ubuntu]: https://doc.ubuntu-fr.org/play.it#installation

In most cases, these instructions should work in the same way for derivatives of these distributions.

### Installation from git

If your distribution does not already have a package for ./play.it, you can install it from this git repository:

```
git clone --branch 2.23.0 --depth 1 https://forge.dotslashplay.it/play.it/scripts.git play.it.git
cd play.it.git
make
make install
```

## Game scripts

Starting with ./play.it 2.16 release, game scripts are no longer provided in this repository. You need to install a collection of game scripts in addition to the core library and wrapper to add support for some game installers. The following games collections are available:

- [The community-maintained main collection]
- [vv221ʼs games collection]
- [Hoëlʼs games]

[The community-maintained main collection]: https://forge.dotslashplay.it/play.it/games
[vv221ʼs games collection]: https://forge.dotslashplay.it/vv221/games
[Hoëlʼs games]: https://forge.dotslashplay.it/hoel/les-jeux-de-hoel

## Usage

Once ./play.it is installed, you can call it providing a supported game installer as the first argument to generate the packages. An example could be:

```
play.it ~/Downloads/setup_sid_meiers_alpha_centauri_2.0.2.23.exe
```

The building process can take from a couple seconds to several minutes, depending mostly on the game size, and ends with the command to run as root to install the generated packages. On Debian, this could be something like:

```
apt install /home/user/Downloads/alpha-centauri_6.0b-gog2.0.2.23+20221005.2_i386.deb /home/user/Downloads/alpha-centauri-movies_6.0b-gog2.0.2.23+20221005.2_all.deb /home/user/Downloads/alpha-centauri-data_6.0b-gog2.0.2.23+20221005.2_all.deb
```

## Contributing

There is [some documentation] on how to add support for new games, but the best bet is to find a similar game and copy its script. Youʼll likely need to visit our IRC channel to ask for more help. It can also be useful to upload your attempts to [pastebin] for commentary, or feel free to raise a WIP [Merge Request].

[some documentation]: https://forge.dotslashplay.it/play.it/scripts/-/wikis/home
[pastebin]: https://paste.debian.net/
[Merge Request]: https://forge.dotslashplay.it/play.it/scripts/-/merge_requests/new

## Contact informations

### IRC channel

Some ./play.it developers and users can be reached on IRC, channel is `#play.it` on network `irc.oftc.net`. The main language on this IRC channel is English, but most of us can speak French too.

### E-mail

A contact e-mail for feedback can usually be found in each ./play.it game script, as well as in the library. Open one of these files with any text editor to see the contact e-mail.
