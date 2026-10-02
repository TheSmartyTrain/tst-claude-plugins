#!/usr/bin/env bash
# Package tst-build for upload to the Claude app (web, desktop, Cowork).
#
# Writes to dist/:
#   tst-build-plugin-<version>.zip   the whole plugin, for
#                                    Organization settings > Plugins & skills,
#                                    if the plugin upload accepts it
#   tst-build-<skill>-<version>.zip  one per skill, for the skill upload,
#                                    which takes exactly one SKILL.md and no
#                                    plugin manifest
#
# Claude Code users don't need any of this: they install from the marketplace.
set -euo pipefail

cd "$(dirname "$0")/.."
plugin=plugins/tst-build
version=$(node -p "require('./$plugin/.claude-plugin/plugin.json').version")

rm -rf dist
mkdir -p dist

# The plugin: manifest at the root of the zip, as in the plugin folder.
(cd "$plugin" && zip -qr "../../dist/tst-build-plugin-$version.zip" . -x '*.DS_Store')

# Each skill on its own: a folder named after the skill, holding SKILL.md.
for dir in "$plugin"/skills/*/; do
  skill=$(basename "$dir")
  (cd "$plugin/skills" && zip -qr "../../../dist/tst-build-$skill-$version.zip" "$skill" -x '*.DS_Store')
done

# The skill upload's own rules, checked here so a bad zip never reaches it.
for z in dist/tst-build-*-"$version".zip; do
  case "$z" in *plugin*) continue ;; esac
  n=$(unzip -Z1 "$z" | grep -c 'SKILL\.md$' || true)
  [ "$n" -eq 1 ] || { echo "$z holds $n SKILL.md files, the upload needs exactly 1" >&2; exit 1; }
  if unzip -Z1 "$z" | grep -q 'plugin\.json$'; then
    echo "$z holds a plugin manifest, the skill upload refuses it" >&2; exit 1
  fi
done

ls -1 dist
