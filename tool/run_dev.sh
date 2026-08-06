#!/usr/bin/env bash
# Runs the Lexivo Flutter client in debug from the single `.env.development` file.
#
# One env file drives every target. Android emulators and USB devices reach the
# host API through `adb reverse`, so `API_BASE_URL=http://localhost:8000` is
# correct everywhere. Pass --api-host for targets adb cannot tunnel (physical
# iOS device); it rewrites API_BASE_URL so the file stays the single source.
#
#   ./tool/run_dev.sh --target android
#   ./tool/run_dev.sh --target web
#   ./tool/run_dev.sh --target ios --api-host 192.168.1.20
set -euo pipefail

target="android"
device=""
api_host=""
api_port="8000"
extra=()

while [[ $# -gt 0 ]]; do
  case "$1" in
    --target) target="$2"; shift 2 ;;
    --device) device="$2"; shift 2 ;;
    --api-host) api_host="$2"; shift 2 ;;
    --api-port) api_port="$2"; shift 2 ;;
    --release) extra+=("--release"); shift ;;
    *) echo "Unknown argument: $1" >&2; exit 2 ;;
  esac
done

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
env_file="$repo_root/.env.development"

if [[ ! -f "$env_file" ]]; then
  echo "Creating .env.development from .env.example — fill SUPABASE_URL and SUPABASE_ANON_KEY."
  cp "$repo_root/.env.example" "$env_file"
fi

set_env_value() {
  local key="$1" value="$2" tmp
  tmp="$(mktemp)"
  if grep -q "^${key}=" "$env_file"; then
    sed "s|^${key}=.*|${key}=${value}|" "$env_file" >"$tmp"
  else
    cat "$env_file" >"$tmp"
    echo "${key}=${value}" >>"$tmp"
  fi
  mv "$tmp" "$env_file"
}

if [[ -n "$api_host" ]]; then
  set_env_value "API_BASE_URL" "http://${api_host}:${api_port}"
  echo "API_BASE_URL -> http://${api_host}:${api_port}"
else
  set_env_value "API_BASE_URL" "http://localhost:${api_port}"
fi

if grep -Eq '^(SUPABASE_URL|SUPABASE_ANON_KEY)=[[:space:]]*$' "$env_file"; then
  echo "Fill SUPABASE_URL and SUPABASE_ANON_KEY in .env.development before running (see README)." >&2
  exit 1
fi

case "$target" in
  web) [[ -n "$device" ]] || device="chrome" ;;
  ios) [[ -n "$device" ]] || device="ios" ;;
  macos) [[ -n "$device" ]] || device="macos" ;;
  android)
    if [[ -z "$device" ]]; then
      device="$(adb devices | awk '/\tdevice$/ {print $1; exit}')"
      [[ -n "$device" ]] || { echo "No Android device found." >&2; exit 1; }
    fi
    if [[ -z "$api_host" ]]; then
      # Maps device localhost:<port> to this machine — emulators and USB devices
      # alike, with no firewall rule.
      adb -s "$device" reverse "tcp:${api_port}" "tcp:${api_port}" >/dev/null
      echo "adb reverse tcp:${api_port} -> host:${api_port} ($device)"
    fi
    ;;
esac

echo "flutter run --dart-define-from-file=$env_file -d $device ${extra[*]:-}"
exec flutter run --dart-define-from-file="$env_file" -d "$device" ${extra[@]+"${extra[@]}"}
