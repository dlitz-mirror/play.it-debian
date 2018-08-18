% play.it(6) | Games Manual
%
% 2018-05-15

# NAME

./play.it - Installer for drm-free commercial games

# SYNOPSIS

**play.it** *installer*

# DESCRIPTION

*installer* (.exe, .sh, ...) must be a supported game installation file at a
known version

**play.it** repackages the game data and engine from the provided *installer*
into a .deb or .pkg and displays the command needed to install the game.

The games are installed globally on multi-user systems, avoiding unnecessary
duplication. The locations of save games, settings, mods, temporary files and
backups are standardized with XDG Base Directory support.

# ENVIRONMENT

*PLAYIT_LIB2* If set, overrides the provided version of **libplayit2.sh** (and
its supported games) to a local copy for development
(default: /usr/share/games/play.it/libplayit2.sh)
