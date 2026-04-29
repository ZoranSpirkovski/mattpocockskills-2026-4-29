#!/usr/bin/env bash
set -euo pipefail

# Sync the source skill folders under skills/<bucket>/<name>/ into the
# marketplace plugin wrappers under plugins/<name>/skills/<name>/.
#
# Why copies (not symlinks): Claude Code's plugin loader does not follow
# symlinks when installing a marketplace plugin, so the wrapped skills end
# up empty on the user's machine. Run this script after editing any skill
# under skills/ to keep the marketplace plugins in sync, then commit.

REPO="$(cd "$(dirname "$0")/.." && pwd)"

find "$REPO/skills" -mindepth 3 -maxdepth 3 -name SKILL.md -print0 |
while IFS= read -r -d '' skill_md; do
  src="$(dirname "$skill_md")"
  name="$(basename "$src")"
  bucket="$(basename "$(dirname "$src")")"

  # Only sync skills that have a corresponding plugin wrapper.
  plugin_dir="$REPO/plugins/$name"
  if [ ! -d "$plugin_dir/.claude-plugin" ]; then
    continue
  fi

  dest="$plugin_dir/skills/$name"
  rm -rf "$dest"
  mkdir -p "$plugin_dir/skills"
  cp -r "$src" "$dest"
  echo "synced $bucket/$name -> plugins/$name/skills/$name"
done
