#!/usr/bin/env bash
set -euo pipefail

WATCH_DIR=${WATCH_DIR:-/data/downloads}
DELETE_SOURCE=${DELETE_SOURCE:-false}
OUTPUT_MODE=${OUTPUT_MODE:-sidecar}

# Log helper
log() { printf "[%s] %s\n" "$(date '+%Y-%m-%d %H:%M:%S')" "$*"; }

process_cue_ape() {
  local cue_file="$1"
  local base_dir
  base_dir="$(dirname "$cue_file")"

  # Find referenced audio file from CUE or fallback to same-name .ape
  local audio_file
  audio_file=$(awk -F '"' '/^FILE .* APE$/ {print $2}' "$cue_file" | head -n1 || true)
  if [[ -z "${audio_file}" ]]; then
    # Try generic FILE line if not marked APE
    audio_file=$(awk -F '"' '/^FILE "/ {print $2}' "$cue_file" | head -n1 || true)
  fi
  if [[ -z "${audio_file}" ]]; then
    # Same-stem fallback
    local stem
    stem="${cue_file%.cue}"
    if [[ -f "${stem}.ape" ]]; then
      audio_file="$(basename "${stem}.ape")"
    fi
  fi

  if [[ -z "$audio_file" || ! -f "$base_dir/$audio_file" ]]; then
    log "Skipping: no matching APE for CUE -> $cue_file"
    return 0
  fi

  local marker
  marker="$cue_file.converted"
  if [[ -f "$marker" ]]; then
    log "Already converted: $cue_file"
    return 0
  fi

  local out_dir
  case "$OUTPUT_MODE" in
    in_place)
      out_dir="$base_dir"
      ;;
    sidecar|*)
      out_dir="$base_dir/_split_flac"
      mkdir -p "$out_dir"
      ;;
  esac

  log "Splitting $(basename "$audio_file") using $(basename "$cue_file")"

  pushd "$out_dir" >/dev/null
  # Perform split to FLAC using shnsplit, then tag using cuetag
  shnsplit -f "$cue_file" -o flac "$base_dir/$audio_file"
  cuetag "$cue_file" split-track*.flac || true
  popd >/dev/null

  # Set marker to avoid reprocessing
  : > "$marker"

  # Optional: delete sources after successful split
  if [[ "$DELETE_SOURCE" == "true" ]]; then
    log "Deleting source files for $cue_file"
    rm -f "$base_dir/$audio_file" "$cue_file"
  fi

  log "Done: $cue_file -> $(ls -1 "$out_dir"/split-track*.flac 2>/dev/null | wc -l) FLAC tracks"
}

initial_scan() {
  log "Initial scan of $WATCH_DIR for .cue/.ape pairs"
  while IFS= read -r -d '' cue; do
    process_cue_ape "$cue"
  done < <(find "$WATCH_DIR" -type f -iname '*.cue' -print0)
}

watch_loop() {
  log "Watching for new CUE/APE files in $WATCH_DIR"
  inotifywait -m -r -e close_write,create,move "$WATCH_DIR" | while read -r dir _ file; do
    case "$file" in
      *.cue|*.CUE)
        process_cue_ape "$dir/$file"
        ;;
      *) ;;
    esac
  done
}

mkdir -p "$WATCH_DIR"
initial_scan
watch_loop

