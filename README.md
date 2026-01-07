# vid2gif

High-quality video → GIF converter for Linux, built on top of FFmpeg.

This script uses the **correct** GIF workflow (`palettegen` + `paletteuse`) and
sensible defaults so you get the best possible GIF quality without tweaking
flags every time.

---

## Why this exists

Most “video to GIF” tools:
- destroy colors,
- introduce banding,
- or silently upscale/downscale your video.

`vid2gif`:
- reads the **actual video frame size**,
- generates an optimized color palette,
- uses high-quality scaling and dithering by default,
- and lets you precisely select the video timeline.

GIF is still a bad format — this just makes it as good as it can be.

---

## Features

- High-quality GIF conversion (palette-based)
- Auto-detects input video width
- Lanczos scaling
- Sensible defaults (no flags required)
- Precise timeline control (`--from`, `--to`, `--duration`)
- Flag-based CLI (no positional argument chaos)
- Linux-only, zero dependencies beyond FFmpeg

---

## Requirements

- Linux
- `ffmpeg` **and** `ffprobe`

### Install FFmpeg

**Debian / Ubuntu**
```bash
sudo apt install ffmpeg
```

**Arch Linux**
```bash
sudo pacman -S ffmpeg
```

---

## Installation

```bash
chmod +x vid2gif.sh
sudo mv vid2gif.sh /usr/local/bin/vid2gif
```

---

## Usage

```bash
vid2gif -i INPUT -o OUTPUT [options]
```

### Minimal example

```bash
vid2gif -i input.mp4 -o output.gif
```

---

## Timeline selection

```bash
vid2gif -i input.mp4 -o clip.gif --from 5 --to 8
vid2gif -i input.mp4 -o clip.gif --from 00:01:10 --duration 3
```

---

## Defaults

| Setting | Value |
|-------|-------|
| FPS | 15 |
| Width | Auto-detected |
| Scaling | Lanczos |
| Dithering | sierra2_4a |
| Loop | Enabled |

---

## Notes

- GIF is limited to 256 colors per frame.
- Large inputs create large GIFs.
- Use `--width` to control size.

---

## License

GNU General Public License v3.0 (see [LICENSE](LICENSE))
