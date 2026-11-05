#!/usr/bin/env bash
# Ground Control's exact-case adapter for the native Go JSON test runner.
set -euo pipefail
selection=$(cat)
file=$(jq -er '.test_file | select(type == "string")' <<<"$selection")
name=$(jq -er '.test_name | select(type == "string")' <<<"$selection")
if [[ ! "$name" =~ ^Test[A-Za-z0-9_]+$ || "$file" != implementations/go/*_test.go || "$file" == *..* || ! -f "$file" ]]; then
  echo 'Select an existing Go test file and one top-level TestName.' >&2
  exit 2
fi
resolved=$(realpath "$file")
if [[ "$resolved" != "$(pwd)/implementations/go/"* ]]; then
  echo 'The selected test must stay inside the runtime module.' >&2
  exit 2
fi
log=$(mktemp)
errors=$(mktemp)
trap 'rm -f "$log" "$errors"' EXIT
status=0
go -C "$(dirname "$file")" test -json -count=1 -run "^${name}$" . >"$log" 2>"$errors" || status=$?
cat "$log" "$errors" >&2
jq -s --arg name "$name" --argjson exit_code "$status" '
  [.[] | select(.Test == $name and (.Action == "pass" or .Action == "fail" or .Action == "skip"))] as $cases |
  {test_name: $name, matches: ($cases | length),
   status: (if ($cases | length) == 0 then (if $exit_code == 0 then "missing" else "broken" end)
            elif ($cases | length) != 1 then "broken"
            elif $cases[0].Action == "skip" then "skipped"
            elif $cases[0].Action == "fail" then "failed"
            elif $exit_code != 0 then "broken" else "passed" end),
   message: ([.[] | select(.Test == $name) | .Output // empty] | join("") | .[:6000])}
' "$log"
