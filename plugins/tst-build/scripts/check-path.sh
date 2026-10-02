#!/usr/bin/env bash
# PreToolUse hook for Write and Edit (stage 2; see hooks.example.json).
# Blocks a new file whose path inside the repository contains a space, and a
# new top-level folder whose name is not kebab-case. Existing paths are left
# alone: folders with spaces are renamed deliberately, with redirects, in
# step 10.2 of docs/governance/implementation-plan.md.
# Reads the hook's JSON on stdin; exit 2 blocks the tool call and shows stderr
# to Claude.
set -euo pipefail
input=$(cat)
file=$(printf '%s' "$input" | node -e 'let s="";process.stdin.on("data",d=>s+=d).on("end",()=>{try{const j=JSON.parse(s);process.stdout.write((j.tool_input&&(j.tool_input.file_path||j.tool_input.path))||"")}catch{}})')
[ -z "$file" ] && exit 0
[ -e "$file" ] && exit 0
root=$(git -C "$(dirname "$file")" rev-parse --show-toplevel 2>/dev/null || pwd)
rel=${file#"$root"/}
# Only the part of the path being created is checked: work inside an existing
# folder with a space carries on until that folder is renamed.
existing=$(dirname "$file")
while [ ! -e "$existing" ] && [ "$existing" != "/" ]; do existing=$(dirname "$existing"); done
new=${file#"$existing"/}
if [[ "$new" == *" "* ]]; then
  echo "TST standard: paths have no spaces. Use kebab-case, for example '${new// /-}' instead of '$new'. Spaces break Azure routing in ways that fail silently." >&2
  exit 2
fi
top=${rel%%/*}
if [[ "$rel" == */* && ! -e "$root/$top" && ! "$top" =~ ^[a-z0-9]+(-[a-z0-9]+)*$ && ! "$top" =~ ^\. ]]; then
  echo "TST standard: new top-level folders are kebab-case (lower case, words joined by hyphens), for example 'client-name-tool-name'. Got '$top'. Start a new tool with /tst-build:new-tool." >&2
  exit 2
fi
exit 0
