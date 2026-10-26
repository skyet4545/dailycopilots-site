#!/bin/sh
set -eu

repo_root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
output="$repo_root/BibleCopilot/Config/Sentry.local.xcconfig"
service="sentry.bible-copilot-ios.dsn"
account="automation"

dsn=$(/usr/bin/security find-generic-password -a "$account" -s "$service" -w)
case "$dsn" in
  https://*) ;;
  *)
    echo "Keychain service $service does not contain a valid HTTPS DSN." >&2
    exit 1
    ;;
esac

# In xcconfig syntax, $() expands to an empty string and prevents // from
# being parsed as the start of a comment.
escaped_dsn="https:/\$()/${dsn#https://}"
umask 077
temporary="$output.tmp.$$"
printf '%s\n' "// Generated from macOS Keychain. Do not commit." "SENTRY_DSN = $escaped_dsn" > "$temporary"
mv "$temporary" "$output"
echo "Updated local Sentry build configuration."
