#!/usr/bin/env bash
set -euo pipefail

echo "Starting Navidrome..."

# Defaults (safe for Pterodactyl)
ND_PORT="${ND_PORT:-4533}"
ND_DATAFOLDER="${ND_DATAFOLDER:-/home/container/data}"
ND_MUSICFOLDER="${ND_MUSICFOLDER:-/home/container/music}"
ND_LOGLEVEL="${ND_LOGLEVEL:-info}"

# Create necessary directories
mkdir -p "$ND_DATAFOLDER" "$ND_MUSICFOLDER"
mkdir -p "$ND_DATAFOLDER/cache"

# Some setups want cache separate; support both:
# - if ND_CACHEFOLDER is set, use it
# - else use "$ND_DATAFOLDER/cache"
ND_CACHEFOLDER="${ND_CACHEFOLDER:-$ND_DATAFOLDER/cache}"
mkdir -p "$ND_CACHEFOLDER"

# Optional: show identity + perms (helps debugging in Pterodactyl)
echo "User: $(id -u):$(id -g) ($(id -un 2>/dev/null || true))"
echo "ND_PORT=$ND_PORT"
echo "ND_DATAFOLDER=$ND_DATAFOLDER"
echo "ND_MUSICFOLDER=$ND_MUSICFOLDER"
echo "ND_CACHEFOLDER=$ND_CACHEFOLDER"
echo "ND_LOGLEVEL=$ND_LOGLEVEL"
echo "ND_CONFIGFILE=${ND_CONFIGFILE:-<empty>}"

# Build args using env vars.
ARGS=(
  "--port" "$ND_PORT"
  "--datafolder" "$ND_DATAFOLDER"
  "--musicfolder" "$ND_MUSICFOLDER"
  "--cachefolder" "$ND_CACHEFOLDER"
  "--loglevel" "$ND_LOGLEVEL"
)

# Optional env passthroughs (only if set & non-empty)
if [[ -n "${ND_BASEURL:-}" ]]; then
  ARGS+=( "--baseurl" "$ND_BASEURL" )
fi

if [[ -n "${ND_ENABLEINSIGHTSCOLLECTOR:-}" ]]; then
  # accepts true/false or 1/0 depending on version; just pass it through
  ARGS+=( "--enableinsightscollector" "$ND_ENABLEINSIGHTSCOLLECTOR" )
fi

# IMPORTANT FIX: only pass configfile if it is non-empty
if [[ -n "${ND_CONFIGFILE:-}" ]]; then
  ARGS+=( "--configfile" "$ND_CONFIGFILE" )
fi

# If you use ND_DATABASE_URL, let Navidrome read it from env (no flag needed).
# Same for Spotify/LastFM keys; they are read from env.

# Find navidrome binary path (different images use different paths)
if command -v navidrome >/dev/null 2>&1; then
  NAVIDROME_BIN="$(command -v navidrome)"
elif [[ -x "/navidrome" ]]; then
  NAVIDROME_BIN="/navidrome"
elif [[ -x "/app/navidrome" ]]; then
  NAVIDROME_BIN="/app/navidrome"
else
  echo "ERROR: navidrome binary not found (tried: navidrome, /navidrome, /app/navidrome)"
  exit 1
fi

echo "Launching: $NAVIDROME_BIN ${ARGS[*]}"
exec "$NAVIDROME_BIN" "${ARGS[@]}"
