#!/bin/sh
set -eu

if [ "$(uname -s)" != "Darwin" ]; then
  exit 0
fi

source_root="/Applications/WezTerm.app/Contents/Resources/terminfo"

if [ ! -d "$source_root" ]; then
  printf '%s\n' "WezTerm terminfo was not found at ${source_root}. Install WezTerm, then run chezmoi apply again." >&2
  exit 0
fi

mkdir -p "${HOME}/.terminfo"
cp -R "${source_root}/." "${HOME}/.terminfo/"
