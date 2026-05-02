#!/usr/bin/env python3
"""
Extract Adelynn gameplay frames from the full reference sheet.

Outputs the loose 180x180 PNG files that index.html loads first:
idle_*.png, run_*.png, dash_*.png, jump_*.png, fall_*.png, land_*.png.
"""
from __future__ import annotations

from collections import deque
from pathlib import Path
import shutil

from PIL import Image, ImageChops, ImageFilter

ROOT = Path(__file__).resolve().parents[1]
ASSETS = ROOT / "assets"
SOURCE_DIR = ASSETS / "source"
DEFAULT_SOURCE = Path("/Users/ronellbradley/Downloads/ChatGPT Image May 1, 2026, 07_04_37 AM.png")
PROJECT_SOURCE = SOURCE_DIR / "adelynn_reference_sheet.png"
BACKUP = ASSETS / "_adelynn_detailed_frames"
OUT_SIZE = 180

# Crop boxes are (left, top, right, bottom) in the 1536x1024 sheet.
# They are deliberately tight enough to avoid labels and guide lines.
FRAME_BOXES: dict[str, list[tuple[int, int, int, int]]] = {
    "idle": [
        (282, 74, 355, 224),
        (386, 74, 460, 224),
        (493, 74, 566, 224),
        (596, 74, 671, 224),
    ],
    "run": [
        (1075, 70, 1188, 224),
        (1190, 70, 1305, 224),
        (1304, 70, 1422, 224),
        (1412, 70, 1535, 224),
    ],
    "dash": [
        (285, 334, 376, 438),
        (416, 329, 512, 437),
        (546, 329, 642, 437),
    ],
    "jump": [
        (688, 338, 770, 448),
        (796, 316, 885, 444),
    ],
    "fall": [
        (1112, 326, 1194, 448),
        (1236, 322, 1322, 448),
    ],
    "land": [
        (36, 548, 129, 633),
        (155, 548, 238, 633),
        (275, 532, 356, 633),
    ],
}


def ensure_source() -> Path:
    SOURCE_DIR.mkdir(parents=True, exist_ok=True)
    if DEFAULT_SOURCE.exists():
        shutil.copy2(DEFAULT_SOURCE, PROJECT_SOURCE)
    if not PROJECT_SOURCE.exists():
        raise FileNotFoundError(f"Missing source sheet: {PROJECT_SOURCE}")
    return PROJECT_SOURCE


def backup_existing() -> None:
    BACKUP.mkdir(exist_ok=True)
    for anim, boxes in FRAME_BOXES.items():
        for i in range(len(boxes)):
            src = ASSETS / f"{anim}_{i}.png"
            dst = BACKUP / src.name
            if src.exists() and not dst.exists():
                dst.write_bytes(src.read_bytes())


def flood_remove_background(crop: Image.Image) -> Image.Image:
    rgba = crop.convert("RGBA")
    px = rgba.load()
    w, h = rgba.size
    # Sheet background is soft pink; sample the crop corners so small lighting
    # changes across the sheet do not matter.
    samples = [px[0, 0], px[w - 1, 0], px[0, h - 1], px[w - 1, h - 1]]
    bg = tuple(sum(c[i] for c in samples) // len(samples) for i in range(3))

    def close_to_bg(p: tuple[int, int, int, int]) -> bool:
        r, g, b, _ = p
        dr, dg, db = abs(r - bg[0]), abs(g - bg[1]), abs(b - bg[2])
        # Keep bright gold/magic and dark outlines even if anti-aliased.
        if r + g + b < 190:
            return False
        return dr < 46 and dg < 42 and db < 46

    q: deque[tuple[int, int]] = deque()
    seen = set()
    for x in range(w):
        q.append((x, 0))
        q.append((x, h - 1))
    for y in range(h):
        q.append((0, y))
        q.append((w - 1, y))

    while q:
        x, y = q.popleft()
        if x < 0 or y < 0 or x >= w or y >= h or (x, y) in seen:
            continue
        seen.add((x, y))
        if not close_to_bg(px[x, y]):
            continue
        px[x, y] = (0, 0, 0, 0)
        q.append((x + 1, y))
        q.append((x - 1, y))
        q.append((x, y + 1))
        q.append((x, y - 1))

    alpha = rgba.getchannel("A")
    # Drop tiny detached guide-line remnants, but avoid nibbling the sprite.
    faint_bg = Image.new("L", rgba.size, 0)
    fp = faint_bg.load()
    rp = rgba.load()
    for y in range(h):
        for x in range(w):
            r, g, b, a = rp[x, y]
            if a and r > 178 and g > 130 and b > 142 and abs(r - g) < 75:
                fp[x, y] = 255
    alpha = ImageChops.subtract(alpha, faint_bg.filter(ImageFilter.GaussianBlur(0.4)))
    rgba.putalpha(alpha)
    return rgba


def normalize_frame(crop: Image.Image) -> Image.Image:
    alpha = crop.getchannel("A")
    box = alpha.getbbox()
    if not box:
        return Image.new("RGBA", (OUT_SIZE, OUT_SIZE), (0, 0, 0, 0))

    sprite = crop.crop(box)
    sw, sh = sprite.size
    target_h = 132 if sh >= sw else 122
    scale = min(target_h / max(sh, 1), 1.8)
    nw, nh = max(1, round(sw * scale)), max(1, round(sh * scale))
    sprite = sprite.resize((nw, nh), Image.Resampling.LANCZOS)

    out = Image.new("RGBA", (OUT_SIZE, OUT_SIZE), (0, 0, 0, 0))
    foot_y = 164
    x = (OUT_SIZE - nw) // 2
    y = foot_y - nh
    out.alpha_composite(sprite, (x, y))
    return out


def keep_main_component(sprite: Image.Image) -> Image.Image:
    rgba = sprite.convert("RGBA")
    alpha = rgba.getchannel("A")
    px = alpha.load()
    w, h = alpha.size
    seen: set[tuple[int, int]] = set()
    comps: list[list[tuple[int, int]]] = []

    for sy in range(h):
        for sx in range(w):
            if px[sx, sy] == 0 or (sx, sy) in seen:
                continue
            q = deque([(sx, sy)])
            seen.add((sx, sy))
            comp: list[tuple[int, int]] = []
            while q:
                x, y = q.popleft()
                if px[x, y] == 0:
                    continue
                comp.append((x, y))
                for nx, ny in ((x + 1, y), (x - 1, y), (x, y + 1), (x, y - 1)):
                    if 0 <= nx < w and 0 <= ny < h and (nx, ny) not in seen:
                        seen.add((nx, ny))
                        if px[nx, ny]:
                            q.append((nx, ny))
            if comp:
                comps.append(comp)

    if not comps:
        return rgba
    main = max(comps, key=len)
    keep = Image.new("L", (w, h), 0)
    kp = keep.load()
    for x, y in main:
        kp[x, y] = px[x, y]
    rgba.putalpha(keep)
    return rgba


def repair_internal_alpha_gaps(sprite: Image.Image) -> Image.Image:
    """Fill transparent pinholes inside the character while preserving the outer cutout."""
    rgba = sprite.convert("RGBA")
    alpha = rgba.getchannel("A")
    ap = alpha.load()
    w, h = alpha.size

    outside = Image.new("L", (w, h), 0)
    op = outside.load()
    q: deque[tuple[int, int]] = deque()
    for x in range(w):
        q.append((x, 0))
        q.append((x, h - 1))
    for y in range(h):
        q.append((0, y))
        q.append((w - 1, y))

    while q:
        x, y = q.popleft()
        if x < 0 or y < 0 or x >= w or y >= h or op[x, y]:
            continue
        if ap[x, y] > 0:
            continue
        op[x, y] = 255
        q.append((x + 1, y))
        q.append((x - 1, y))
        q.append((x, y + 1))
        q.append((x, y - 1))

    # Fill only small transparent islands that are enclosed by nontransparent art.
    rp = rgba.load()
    seen: set[tuple[int, int]] = set()
    for sy in range(h):
        for sx in range(w):
            if ap[sx, sy] > 0 or op[sx, sy] or (sx, sy) in seen:
                continue
            comp: list[tuple[int, int]] = []
            q = deque([(sx, sy)])
            seen.add((sx, sy))
            while q:
                x, y = q.popleft()
                if ap[x, y] > 0 or op[x, y]:
                    continue
                comp.append((x, y))
                for nx, ny in ((x + 1, y), (x - 1, y), (x, y + 1), (x, y - 1)):
                    if 0 <= nx < w and 0 <= ny < h and (nx, ny) not in seen:
                        seen.add((nx, ny))
                        if ap[nx, ny] == 0 and not op[nx, ny]:
                            q.append((nx, ny))
            if not comp or len(comp) > 180:
                continue

            colors: list[tuple[int, int, int]] = []
            for x, y in comp:
                for yy in range(max(0, y - 2), min(h, y + 3)):
                    for xx in range(max(0, x - 2), min(w, x + 3)):
                        if ap[xx, yy] > 80:
                            r, g, b, _ = rp[xx, yy]
                            colors.append((r, g, b))
            if not colors:
                continue
            colors.sort()
            r = sum(c[0] for c in colors) // len(colors)
            g = sum(c[1] for c in colors) // len(colors)
            b = sum(c[2] for c in colors) // len(colors)
            for x, y in comp:
                rp[x, y] = (r, g, b, 255)
                ap[x, y] = 255

    rgba.putalpha(alpha)
    return rgba


def add_solid_underpaint(sprite: Image.Image) -> Image.Image:
    """Place a dress-colored matte behind the detailed pixels to prevent see-through specks."""
    rgba = sprite.convert("RGBA")
    alpha = rgba.getchannel("A")
    px = rgba.load()
    colors: list[tuple[int, int, int]] = []
    w, h = rgba.size
    for y in range(h):
        for x in range(w):
            r, g, b, a = px[x, y]
            if a > 160 and r > 130 and b > 85 and g < 135:
                colors.append((r, g, b))
    if colors:
        r = sum(c[0] for c in colors) // len(colors)
        g = sum(c[1] for c in colors) // len(colors)
        b = sum(c[2] for c in colors) // len(colors)
    else:
        r, g, b = (194, 76, 128)

    closed = alpha.filter(ImageFilter.MaxFilter(5)).filter(ImageFilter.MinFilter(5))
    matte = Image.new("RGBA", rgba.size, (r, g, b, 255))
    matte.putalpha(closed.point(lambda p: min(230, int(p * 0.9))))
    out = Image.new("RGBA", rgba.size, (0, 0, 0, 0))
    out.alpha_composite(matte)
    out.alpha_composite(rgba)
    return out


def extract() -> None:
    src_path = ensure_source()
    backup_existing()
    sheet = Image.open(src_path).convert("RGBA")
    for anim, boxes in FRAME_BOXES.items():
        for i, box in enumerate(boxes):
            crop = sheet.crop(box)
            clean = flood_remove_background(crop)
            clean = keep_main_component(clean)
            clean = repair_internal_alpha_gaps(clean)
            clean = add_solid_underpaint(clean)
            frame = normalize_frame(clean)
            frame.save(ASSETS / f"{anim}_{i}.png")
    print(f"Extracted Adelynn frames from {src_path}")


if __name__ == "__main__":
    extract()
