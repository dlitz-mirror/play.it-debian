# ./play.it contribution guide

## Branches overview

### Stable branch

`master` branch is the currently distributed version of ./play.it.

No merge request should target it, we use staging branches for testing code before merging it into `master`.

### Staging branches

We currently use two persistent staging branches: `staging-1.x` and `staging-2.x`.

Extra temporary staging branches are used during the preparation of a release, and include the full version in their name, like `staging-2.12`.

All merge requests should target one of these staging branches.

### Development branches

All development happens on dedicated per-feature branches, using a namespace based on the target staging branch.

A development branch targeting `staging-2.x` should have a name starting with `dev-2.x/`, one targeting `staging-2.12` should have a name starting with `dev-2.12/`, etc.

## Game-specific scripts

### New scripts

Scripts for new games should be done on dedicated development branches targeting `staging-2.x`, using the naming convention `dev-2.x/games/new/${game_id}`, where `${game_id}` is the value assigned to `GAME_ID` in the script.

The development branch starting point should be the latest published tag.

### Scripts updates

Updates to game-specific scripts should be done on dedicated development branches targeting `staging-2.x`, using the naming convention `dev-2.x/games/update/${game_id}/${update_description}`, where `${game_id}` is the value assigned to `GAME_ID` in the script. An example name would be `dev-2.x/games/update/alpha-centauri/new-archive`, for a branch adding support for a new archive to the Alpha Centauri script.

The development branch starting point should be the latest published tag.

### Scripts bugfixes

Fixes to game-specific scripts follow the same rules than updates, only the naming convention is different: `dev-2.x/games/fix/${game_id}/${fix_description}`.

In addition to the updates rules, fixes are allowed to target `staging-1.x`, using the naming convention `dev-1.x/games/fix/${game_id}/${fix_description}`.
