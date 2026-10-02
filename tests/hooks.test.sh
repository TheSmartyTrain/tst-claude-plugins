#!/usr/bin/env bash
# Exercises the two stage-2 hook scripts with the JSON a PreToolUse hook
# receives. Exit 2 means "blocked"; exit 0 means "allowed".
set -uo pipefail
here=$(cd "$(dirname "$0")/.." && pwd)
scripts="$here/plugins/tst-build/scripts"
work=$(mktemp -d)
git -C "$work" init -q
mkdir -p "$work/People Pulse" "$work/HIVE"
fail=0
check() { # check <want> <description> <command> <json>
  local want=$1 desc=$2 cmd=$3 json=$4 got
  printf '%s' "$json" | (cd "$work" && $cmd) >/dev/null 2>&1; got=$?
  if [ "$got" = "$want" ]; then echo "ok   $desc"; else echo "FAIL $desc (want $want, got $got)"; fail=1; fi
}
p="bash $scripts/check-path.sh"
d="node $scripts/check-personal-data.js"
check 2 "new folder with a space is blocked"            "$p" "{\"tool_input\":{\"file_path\":\"$work/My Tool/index.html\"}}"
check 0 "new file in an existing spaced folder is allowed" "$p" "{\"tool_input\":{\"file_path\":\"$work/People Pulse/x.html\"}}"
check 2 "new spaced subfolder is blocked"                "$p" "{\"tool_input\":{\"file_path\":\"$work/HIVE/new dir/x.js\"}}"
check 2 "new non-kebab top-level folder is blocked"      "$p" "{\"tool_input\":{\"file_path\":\"$work/NewTool/index.html\"}}"
check 0 "new kebab-case folder is allowed"               "$p" "{\"tool_input\":{\"file_path\":\"$work/new-tool/a.html\"}}"
check 0 "existing upper-case folder is allowed"          "$p" "{\"tool_input\":{\"file_path\":\"$work/HIVE/new.js\"}}"
check 2 "six real-looking emails are blocked"            "$d" '{"tool_input":{"content":"a@x.co b@x.co c@x.co d@x.co e@x.co f@x.co"}}'
check 0 "placeholder emails are allowed"                 "$d" '{"tool_input":{"content":"a@example.com b@example.com c@example.com d@example.com e@example.com f@example.com g@example.com"}}'
check 2 "an ethnicity field is blocked"                  "$d" '{"tool_input":{"new_string":"{\"ethnicity\": \"x\"}"}}'
check 2 "a UK mobile number is blocked"                  "$d" '{"tool_input":{"content":"call 07700 900123"}}'
check 0 "ordinary text is allowed"                       "$d" '{"tool_input":{"content":"hello world"}}'
rm -rf "$work"
exit $fail
