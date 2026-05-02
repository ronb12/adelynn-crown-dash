#!/usr/bin/env python3
"""
Generates per-frame PNGs + combined sprite sheets for Crown Dash characters.
Style: chunky pixel-read silhouettes (256x256), transparent background.
"""
from __future__ import annotations

import math
import os
from pathlib import Path

from PIL import Image, ImageDraw

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "assets" / "chars"
SIZE = 256
CX = SIZE // 2
FEET_Y = SIZE - 18


def _bob(anim: str, frame: int) -> float:
    if anim == "idle":
        return math.sin(frame * 1.2) * 4
    if anim in ("run", "dash"):
        return math.sin(frame * 2.2 + (1 if anim == "dash" else 0)) * 3
    return 0


def _leg_swing(anim: str, frame: int) -> tuple[float, float]:
    if anim != "run":
        return 0, 0
    a = frame * math.pi / 2
    return math.sin(a) * 12, math.cos(a) * 8


def humanoid_body(
    draw: ImageDraw.ImageDraw,
    pal: dict[str, tuple[int, int, int]],
    anim: str,
    frame: int,
    *,
    dress_skirt: bool = True,
    wide_shoulders: float = 1.0,
    short: bool = False,
) -> None:
    bob = _bob(anim, frame)
    lx, ly = _leg_swing(anim, frame)
    scale = 0.92 if short else 1.0
    hy = FEET_Y - int(110 * scale) + bob

    # legs
    leg_w, leg_h = 14, 44
    ox = int(lx)
    draw.rounded_rectangle(
        [CX - 22 + ox, FEET_Y - leg_h, CX - 22 + ox + leg_w, FEET_Y],
        radius=4,
        fill=pal["leg"],
    )
    draw.rounded_rectangle(
        [CX + 8 - ox, FEET_Y - leg_h, CX + 8 - ox + leg_w, FEET_Y],
        radius=4,
        fill=pal["leg"],
    )

    # torso / dress
    tw, th = int(38 * wide_shoulders), 52
    top = hy + 28
    if dress_skirt:
        points = [
            CX - tw // 2,
            top,
            CX + tw // 2,
            top,
            CX + 26,
            FEET_Y - leg_h + 4,
            CX - 26,
            FEET_Y - leg_h + 4,
        ]
        draw.polygon(points, fill=pal["primary"])
    else:
        draw.rounded_rectangle([CX - tw // 2, top, CX + tw // 2, top + th], radius=10, fill=pal["primary"])

    # arms
    arm_y = top + 8
    draw.rounded_rectangle([CX - tw // 2 - 14, arm_y, CX - tw // 2 + 4, arm_y + 36], radius=6, fill=pal["skin"])
    draw.rounded_rectangle([CX + tw // 2 - 4, arm_y, CX + tw // 2 + 14, arm_y + 36], radius=6, fill=pal["skin"])

    # head
    head_r = 22
    draw.ellipse([CX - head_r, hy - 8, CX + head_r, hy + 36], fill=pal["skin"])
    # hair cap
    draw.ellipse([CX - head_r - 2, hy - 18, CX + head_r + 2, hy + 18], fill=pal["hair"])


def draw_crown(draw: ImageDraw.ImageDraw, cx: int, hy: int) -> None:
    pts = [
        (cx - 16, hy - 8),
        (cx - 8, hy - 22),
        (cx, hy - 14),
        (cx + 8, hy - 22),
        (cx + 16, hy - 8),
    ]
    draw.polygon(pts, fill=(255, 215, 80, 255))


def draw_staff(draw: ImageDraw.ImageDraw, cx: int, top: int, frame: int) -> None:
    tilt = 12 + frame * 4
    draw.rounded_rectangle([cx + 22, top - 10, cx + 26 + tilt, FEET_Y - 20], radius=3, fill=(110, 72, 48, 255))
    draw.ellipse([cx + 28 + tilt, top - 24, cx + 40 + tilt, top - 10], fill=(180, 220, 255, 255))


def draw_cloak_hood(draw: ImageDraw.ImageDraw, pal: dict, cx: int, hy: int, anim: str, frame: int) -> None:
    bob = _bob(anim, frame)
    # hood silhouette over head
    draw.pieslice([cx - 28, hy - 28 + bob, cx + 28, hy + 30 + bob], 180, 360, fill=pal["secondary"])
    draw.chord([cx - 26, hy - 10 + bob, cx + 26, hy + 34 + bob], 0, 180, fill=pal["secondary"])


def draw_unicorn(draw: ImageDraw.ImageDraw, pal: dict, anim: str, frame: int) -> None:
    bob = _bob(anim, frame)
    phase = frame * math.pi / 2
    gallop = math.sin(phase) * 10

    # body
    body_y = FEET_Y - 52 + bob
    draw.rounded_rectangle([CX - 48 + gallop, body_y, CX + 44 + gallop, body_y + 36], radius=14, fill=pal["primary"])
    # neck + head
    draw.rounded_rectangle([CX + 28 + gallop, body_y - 28, CX + 52 + gallop, body_y + 12], radius=8, fill=pal["primary"])
    draw.ellipse([CX + 44 + gallop, body_y - 44, CX + 76 + gallop, body_y - 12], fill=pal["primary"])
    # horn
    draw.polygon(
        [
            (CX + 62 + gallop, body_y - 48),
            (CX + 68 + gallop, body_y - 72),
            (CX + 56 + gallop, body_y - 46),
        ],
        fill=(255, 240, 220, 255),
    )
    # legs (4)
    for i, ox in enumerate([-32, -10, 10, 32]):
        lh = 28 + int(math.sin(phase + i) * 8)
        draw.rounded_rectangle(
            [CX + ox - 6 + gallop, FEET_Y - lh, CX + ox + 6 + gallop, FEET_Y],
            radius=4,
            fill=pal["leg"],
        )
    # tail
    draw.polygon(
        [
            (CX - 52 + gallop, body_y + 8),
            (CX - 72 + gallop, body_y - 8),
            (CX - 48 + gallop, body_y + 20),
        ],
        fill=pal["hair"],
    )


def draw_dragon(draw: ImageDraw.ImageDraw, pal: dict, anim: str, frame: int) -> None:
    bob = _bob(anim, frame)
    hy = FEET_Y - 100 + bob
    # body
    draw.rounded_rectangle([CX - 28, hy + 30, CX + 28, hy + 78], radius=16, fill=pal["primary"])
    # belly
    draw.rounded_rectangle([CX - 18, hy + 44, CX + 18, hy + 70], radius=10, fill=pal["accent"])
    # head
    draw.ellipse([CX - 24, hy - 8, CX + 28, hy + 36], fill=pal["primary"])
    draw.ellipse([CX + 8, hy + 4, CX + 22, hy + 14], fill=(255, 120, 90, 255))
    # wings
    flap = math.sin(frame * 1.5) * 10 if anim in ("jump", "fall") else 4
    draw.polygon(
        [
            (CX - 20, hy + 36),
            (CX - 72 - flap, hy + 10),
            (CX - 24, hy + 48),
        ],
        fill=pal["secondary"],
    )
    draw.polygon(
        [
            (CX + 20, hy + 36),
            (CX + 72 + flap, hy + 10),
            (CX + 24, hy + 48),
        ],
        fill=pal["secondary"],
    )
    # legs
    draw.rounded_rectangle([CX - 18, FEET_Y - 36, CX - 6, FEET_Y], radius=4, fill=pal["leg"])
    draw.rounded_rectangle([CX + 6, FEET_Y - 36, CX + 18, FEET_Y], radius=4, fill=pal["leg"])
    # tail
    draw.polygon([(CX - 24, hy + 70), (CX - 52, hy + 96), (CX - 18, hy + 76)], fill=pal["primary"])


CHAR_PALETTES: dict[str, dict[str, tuple[int, int, int]]] = {
    "knight": {
        "skin": (230, 200, 175),
        "hair": (180, 175, 190),
        "primary": (140, 148, 158),
        "secondary": (110, 38, 42),
        "leg": (90, 92, 98),
        "accent": (220, 220, 235),
    },
    "sprite": {
        "skin": (210, 245, 210),
        "hair": (80, 160, 90),
        "primary": (60, 130, 85),
        "secondary": (140, 210, 150),
        "leg": (45, 100, 65),
        "accent": (255, 255, 200),
    },
    "mage": {
        "skin": (230, 210, 245),
        "hair": (120, 80, 160),
        "primary": (90, 70, 140),
        "secondary": (160, 130, 220),
        "leg": (70, 55, 110),
        "accent": (200, 230, 255),
    },
    "prince": {
        "skin": (255, 215, 195),
        "hair": (200, 160, 90),
        "primary": (70, 110, 190),
        "secondary": (230, 235, 250),
        "leg": (55, 75, 130),
        "accent": (255, 215, 80),
    },
    "shadow": {
        "skin": (190, 190, 205),
        "hair": (40, 35, 55),
        "primary": (55, 50, 75),
        "secondary": (30, 28, 48),
        "leg": (35, 32, 50),
        "accent": (180, 120, 255),
    },
    "nomad": {
        "skin": (225, 185, 150),
        "hair": (120, 85, 55),
        "primary": (190, 150, 95),
        "secondary": (230, 200, 140),
        "leg": (140, 100, 60),
        "accent": (255, 200, 120),
    },
    "unicorn": {
        "skin": (245, 245, 255),
        "hair": (255, 200, 230),
        "primary": (245, 245, 250),
        "secondary": (230, 230, 255),
        "leg": (220, 220, 235),
        "accent": (255, 240, 220),
    },
    "dragon": {
        "skin": (180, 230, 160),
        "hair": (70, 140, 70),
        "primary": (65, 140, 85),
        "secondary": (120, 200, 140),
        "leg": (50, 110, 70),
        "accent": (220, 255, 210),
    },
}


def render_character(char_id: str, anim: str, frame: int) -> Image.Image:
    im = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
    dr = ImageDraw.Draw(im)
    pal = {k: v + (255,) for k, v in CHAR_PALETTES[char_id].items()}

    if char_id == "unicorn":
        draw_unicorn(dr, pal, anim, frame)
        return im
    if char_id == "dragon":
        draw_dragon(dr, pal, anim, frame)
        return im

    dress = char_id not in ("knight", "prince", "mage", "shadow", "nomad")
    wide = 1.15 if char_id == "knight" else 1.0
    short = char_id == "sprite"

    humanoid_body(dr, pal, anim, frame, dress_skirt=dress, wide_shoulders=wide, short=short)

    hy = FEET_Y - int(110 * (0.92 if short else 1.0)) + _bob(anim, frame)

    if char_id == "knight":
        dr.rounded_rectangle([CX - 26, hy - 22, CX + 26, hy + 8], radius=8, fill=(160, 165, 175, 255))
        dr.polygon([(CX - 6, hy - 28), (CX + 6, hy - 28), (CX, hy - 38)], fill=(200, 40, 40, 255))
    elif char_id == "prince":
        draw_crown(dr, CX, hy)
        dr.rectangle([CX - 20, hy + 24, CX + 20, hy + 28], fill=(255, 215, 80, 255))
    elif char_id == "mage":
        dr.polygon([(CX - 18, hy - 36), (CX + 18, hy - 36), (CX + 22, hy - 8), (CX - 22, hy - 8)], fill=(90, 70, 140, 255))
        draw_staff(dr, CX, hy + 16, frame)
    elif char_id == "shadow":
        draw_cloak_hood(dr, pal, CX, hy, anim, frame)
    elif char_id == "nomad":
        # scarf
        dr.pieslice([CX - 30, hy - 6, CX + 30, hy + 40], 200, 340, fill=(230, 200, 140, 255))

    return im


ANIMATIONS = {
    "idle": 4,
    "run": 4,
    "dash": 3,
    "jump": 2,
    "fall": 2,
    "land": 3,
}


def main() -> None:
    # Princess Adelynn uses hand-drawn PNGs in repo root assets/ (idle_0.png, …) — not generated here.
    chars = list(CHAR_PALETTES.keys())
    for cid in chars:
        ddir = OUT / cid
        ddir.mkdir(parents=True, exist_ok=True)
        sheet_frames: list[Image.Image] = []

        for anim, count in ANIMATIONS.items():
            for f in range(count):
                img = render_character(cid, anim, f)
                img.save(ddir / f"{anim}_{f}.png")
                sheet_frames.append(img)

        # Combined sprite sheet (horizontal strip for tooling / preview)
        cols = 6
        rows = (len(sheet_frames) + cols - 1) // cols
        sheet = Image.new("RGBA", (cols * SIZE, rows * SIZE), (40, 44, 52, 255))
        for i, fr in enumerate(sheet_frames):
            x, y = (i % cols) * SIZE, (i // cols) * SIZE
            sheet.paste(fr, (x, y), fr)
        sheet.save(OUT / f"{cid}_sheet.png")

    print(f"Wrote characters under {OUT}")


if __name__ == "__main__":
    main()
