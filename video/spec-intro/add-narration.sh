#!/usr/bin/env bash
# Add the narration to the rendered video, once the MP3s exist.
#
# The video is authored and rendered silent because this session's egress policy
# blocks every TTS endpoint (nowvoice.ai, HeyGen, HuggingFace). Nothing else is
# missing: the frames, timings and cut are final. Generate the six MP3s with the
# `nowvoice-tts` skill from `../narration/*.txt`, drop them in `audio/`, run this.
#
#   audio/01-hook.mp3  02-install.mp3  03-gates.mp3
#        04-collab.mp3 05-probe.mp3    06-proof.mp3
#
# Two modes:
#   ./add-narration.sh            mux the narration onto the EXISTING render,
#                                 keeping the current picture timing (fast, no
#                                 re-render). Use when each MP3 is close to its
#                                 frame's estimated length.
#   ./add-narration.sh --resync   push the REAL durations back into STORYBOARD.md
#                                 (audio.mjs sync-durations), re-assemble and
#                                 re-render so picture and voice match exactly.
#                                 Use when a line came out much longer/shorter.
#
# Frame windows in the current cut (seconds):
#   01-hook 0 · 02-install 17 · 03-gates 30.5 · 04-collab 51 · 05-probe 69 · 06-proof 89
set -euo pipefail
cd "$(dirname "$0")"

AUDIO_DIR=audio
OUT=renders/video-narrated.mp4
FRAMES=(01-hook 02-install 03-gates 04-collab 05-probe 06-proof)
STARTS=(0 17 30.5 51 69 89)

command -v ffmpeg >/dev/null || { echo "需要 ffmpeg，未找到"; exit 1; }

missing=0
for f in "${FRAMES[@]}"; do
  [ -f "$AUDIO_DIR/$f.mp3" ] || { echo "缺少 $AUDIO_DIR/$f.mp3"; missing=1; }
done
[ "$missing" -eq 0 ] || { echo "补齐配音后再跑。文案在 ../narration/。"; exit 1; }

if [ "${1:-}" = "--resync" ]; then
  echo "== 用真实配音时长覆盖估算值，然后重渲 =="
  node ~/.claude/skills/product-launch-video/scripts/audio.mjs sync-durations \
    --audio-meta ./audio_meta.json --storyboard ./STORYBOARD.md
  node ~/.claude/skills/product-launch-video/scripts/assemble-index.mjs \
    --storyboard ./STORYBOARD.md --hyperframes .
  # the assembler rewrites the GSAP tag back to the CDN, which this network blocks
  sed -i 's#<script src="https://cdn\.jsdelivr\.net/[^"]*gsap[^"]*"[^>]*></script>#<script src="vendor/gsap.min.js"></script>#' index.html
  npx hyperframes check
  npx hyperframes render --skill=product-launch-video --quality high --output "$OUT"
  echo "✅ $OUT"
  exit 0
fi

echo "== 把配音混到现有画面上（不重渲）=="
args=(-i renders/video.mp4)
filter=""
for i in "${!FRAMES[@]}"; do
  args+=(-i "$AUDIO_DIR/${FRAMES[$i]}.mp3")
  # delay each line to its frame's start; sum them into one narration track
  filter+="[$((i + 1)):a]adelay=$(awk "BEGIN{printf \"%d\", ${STARTS[$i]} * 1000}")|$(awk "BEGIN{printf \"%d\", ${STARTS[$i]} * 1000}")[a$i];"
done
mix=""
for i in "${!FRAMES[@]}"; do mix+="[a$i]"; done
filter+="${mix}amix=inputs=${#FRAMES[@]}:normalize=0[out]"

ffmpeg -nostdin -y -v error "${args[@]}" \
  -filter_complex "$filter" \
  -map 0:v -map "[out]" \
  -c:v copy -c:a aac -b:a 160k -ar 48000 \
  -movflags +faststart -shortest "$OUT"

echo "✅ $OUT"
ffprobe -v error -show_entries format=duration,size -of default=noprint_wrappers=1 "$OUT"
echo "画面时长不变；若某段配音超出其窗口，改用 ./add-narration.sh --resync"
