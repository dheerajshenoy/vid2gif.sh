#!/usr/bin/env bash
set -euo pipefail

show_help() {
cat <<'EOF'
vid2gif.sh — high-quality video → GIF (Linux)

USAGE:
  vid2gif.sh -i INPUT -o OUTPUT [options]

REQUIRED:
  -i, --input FILE          Input video
  -o, --output FILE         Output GIF

QUALITY DEFAULTS:
  fps       = 30
  width     = input video width (auto)
  dither    = sierra2_4a
  scaling   = lanczos
  loop      = enabled

OPTIONS:
  -f, --fps N               Frames per second
  -w, --width PX            Override output width
      --dither MODE         sierra2_4a | bayer | none
      --no-loop             Disable GIF looping

TIMELINE:
      --from TIME           Start time (seconds or HH:MM:SS)
      --to TIME             End time (seconds or HH:MM:SS)
      --duration SECONDS    Duration (alternative to --to)

OTHER:
  -h, --help                Show this help
EOF
}

# Defaults (high quality)
fps=30
width=""
dither="sierra2_4a"
from="0"
to=""
duration=""
loop=1
input=""
output=""

# Parse args
while [[ $# -gt 0 ]]; do
  case "$1" in
    -i|--input)     input="$2"; shift 2 ;;
    -o|--output)    output="$2"; shift 2 ;;
    -f|--fps)       fps="$2"; shift 2 ;;
    -w|--width)     width="$2"; shift 2 ;;
    --dither)       dither="$2"; shift 2 ;;
    --from)         from="$2"; shift 2 ;;
    --to)           to="$2"; shift 2 ;;
    --duration)     duration="$2"; shift 2 ;;
    --no-loop)      loop=0; shift ;;
    -h|--help)      show_help; exit 0 ;;
    *) echo "Unknown option: $1"; show_help; exit 1 ;;
  esac
done

# Validation
[[ -z "$input" || -z "$output" ]] && { show_help; exit 1; }
[[ ! -f "$input" ]] && { echo "Input not found: $input"; exit 1; }
command -v ffmpeg  >/dev/null || { echo "ffmpeg not installed"; exit 1; }
command -v ffprobe >/dev/null || { echo "ffprobe not installed"; exit 1; }

# Auto-detect width if not provided
if [[ -z "$width" ]]; then
  width="$(ffprobe -v error \
    -select_streams v:0 \
    -show_entries stream=width \
    -of csv=p=0 "$input")"

  if [[ -z "$width" ]]; then
    echo "Failed to detect video width" >&2
    exit 1
  fi
fi

# Timeline
seek_args=(-ss "$from")
if [[ -n "$to" ]]; then
  seek_args+=(-to "$to")
elif [[ -n "$duration" ]]; then
  seek_args+=(-t "$duration")
fi

# Loop
loop_arg=(-loop 0)
[[ $loop -eq 0 ]] && loop_arg=()

palette="$(mktemp --suffix=.png)"
trap 'rm -f "$palette"' EXIT

vf="fps=${fps},scale=${width}:-1:flags=lanczos"

echo "[1/2] Generating palette (width=${width}px)…"
ffmpeg -y \
  "${seek_args[@]}" \
  -i "$input" \
  -vf "${vf},palettegen=stats_mode=diff" \
  "$palette"

echo "[2/2] Creating GIF (high quality)…"
ffmpeg -y \
  "${seek_args[@]}" \
  -i "$input" -i "$palette" \
  -lavfi "${vf} [x]; [x][1:v] paletteuse=dither=${dither}" \
  "${loop_arg[@]}" \
  "$output"

echo "Done → $output"

