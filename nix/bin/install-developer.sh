#!/usr/bin/env bash

# This installs each of the bknix profiles in a way that's useful for a developer's workstation.
# Specifically:
#   - If not previously done, install nix and cachix
#   - Install the binaries for each profile in /nix/var/nix/profiles/per-user/$USER/bknix-$PROFILE
#   - Don't do anything about data; this will be done at the developer's discretion
#
# Pre-requisites:
#   Use a Debian-like main OS
#   Install the "nix" package manager.
#   Only tested with multiuser mode.
#   Login as proper root (e.g. `sudo -i bash`)
#
# Example: Install (or upgrade) the most common profiles
#   ./bin/install-developer.sh
#
# Example: Install (or upgrade) specific profiles
#   PROFILES='min max old edge dfl' ./bin/install-developer.sh
#
# After installation, an automated script can use a statement like:
#    eval $(use-bknix min)
#    eval $(use-bknix max)
#    eval $(use-bknix dfl)

###########################################################
## Bootstrap

set -e
BINDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
BKNIXSRC=$(dirname "$BINDIR")
cd "$BKNIXSRC"
source "$BINDIR/../lib/common.sh"

###########################################################
## Main

PROFILES=${PROFILES:-min max dfl}

assert_not_root_user
if [ ! -d /nix ]; then
  install_nix_interactive
fi
check_reqs
install_cachix
install_bin "$BINDIR"/use-bknix /usr/local/bin/use-bknix
install_bin "$BINDIR"/run-bknix-job /usr/local/bin/run-bknix-job
for PROFILE in $PROFILES ; do
  install_profile_binaries "$PROFILE" $(get_nix_profile_path "bknix-$PROFILE")
done

## We need to run setup_buildkit with one of the profiles; but given multiple options, any of them would be equally reasonable.
for PROFILE in $PROFILES ; do
  PRFDIR=$(get_nix_profile_path "bknix-$PROFILE")
  do_as_dev "$(declare -f setup_buildkit)" setup_buildkit ".loco/loco.yml"
  break
done
