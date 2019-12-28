#!/usr/bin/env bash
set -Ceu

sudo atsutil databases -remove
atsutil server -shutdown
atsutil server -ping

echo "Logout needed to apply the effect."
