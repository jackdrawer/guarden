from __future__ import annotations

import argparse
import json
from pathlib import Path
from typing import Any

from PIL import Image, ImageColor, ImageDraw, ImageFilter, ImageFont


CANVAS_WIDTH = 1242
CANVAS_HEIGHT = 2208
SCREEN_TOP = 420
SCREEN_SIDE = 94
SCREEN_BOTTOM = 86
SCREEN_RADIUS = 54
HEADER_LEFT = 86
HEADER_RIGHT = CANVAS_WIDTH - 86

BACKGROUND_TOP = "#11131D"
BACKGROUND_BOTTOM = "#1A1F2D"
TEXT_PRIMARY = "#F4F5FA"
TEXT_SECONDARY = "#B7BED0"
ACCENT = "#F39A4A"
ACCENT_SOFT = "#2A2018"


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Build Play Store screenshot cards from raw app screenshots.",
    )
    parser.add_argument(
        "--config",
        default="docs/release/playstore_screenshots.tr.json",
        help="Path to the screenshot manifest JSON.",
    )
    parser.add_argument(
        "--project-root",
        default=".",
        help="Project root used to resolve relative paths in the manifest.",
    )
    parser.add_argument(
        "--validate",
        action="store_true",
        help="Validate inputs without generating output files.",
    )
    return parser.parse_args()


def load_manifest(config_path: Path) -> dict[str, Any]:
    with config_path.open("r", encoding="utf-8") as handle:
        return json.load(handle)


def resolve_path(root: Path, raw_path: str) -> Path:
    path = Path(raw_path)
    return path if path.is_absolute() else (root / path).resolve()


def load_font(size: int, *, bold: bool = False) -> ImageFont.FreeTypeFont | ImageFont.ImageFont:
    candidates = [
        "C:/Windows/Fonts/bahnschrift.ttf",
        "C:/Windows/Fonts/seguisb.ttf" if bold else "C:/Windows/Fonts/segoeui.ttf",
        "C:/Windows/Fonts/arialbd.ttf" if bold else "C:/Windows/Fonts/arial.ttf",
    ]
    for candidate in candidates:
        font_path = Path(candidate)
        if font_path.exists():
            return ImageFont.truetype(str(font_path), size=size)
    return ImageFont.load_default()


def rounded_mask(size: tuple[int, int], radius: int) -> Image.Image:
    mask = Image.new("L", size, 0)
    draw = ImageDraw.Draw(mask)
    draw.rounded_rectangle((0, 0, size[0], size[1]), radius=radius, fill=255)
    return mask


def make_background() -> Image.Image:
    base = Image.new("RGBA", (CANVAS_WIDTH, CANVAS_HEIGHT), BACKGROUND_BOTTOM)
    draw = ImageDraw.Draw(base)
    for y in range(CANVAS_HEIGHT):
        ratio = y / max(CANVAS_HEIGHT - 1, 1)
        top_rgb = ImageColor.getrgb(BACKGROUND_TOP)
        bottom_rgb = ImageColor.getrgb(BACKGROUND_BOTTOM)
        color = tuple(
            int(top_rgb[i] + (bottom_rgb[i] - top_rgb[i]) * ratio) for i in range(3)
        )
        draw.line((0, y, CANVAS_WIDTH, y), fill=color)

    glow = Image.new("RGBA", (CANVAS_WIDTH, CANVAS_HEIGHT), (0, 0, 0, 0))
    glow_draw = ImageDraw.Draw(glow)
    glow_draw.ellipse(
        (CANVAS_WIDTH - 420, -180, CANVAS_WIDTH + 260, 520),
        fill=(243, 154, 74, 62),
    )
    glow_draw.ellipse(
        (-260, 1180, 320, 1760),
        fill=(243, 154, 74, 28),
    )
    return Image.alpha_composite(base, glow.filter(ImageFilter.GaussianBlur(90)))


def wrap_text(draw: ImageDraw.ImageDraw, text: str, font: ImageFont.ImageFont, max_width: int) -> list[str]:
    words = text.split()
    if not words:
        return [""]
    lines: list[str] = []
    current = words[0]
    for word in words[1:]:
        trial = f"{current} {word}"
        if draw.textbbox((0, 0), trial, font=font)[2] <= max_width:
            current = trial
        else:
            lines.append(current)
            current = word
    lines.append(current)
    return lines


def crop_source(image: Image.Image, crop_top: int, crop_bottom: int) -> Image.Image:
    width, height = image.size
    top = max(0, crop_top)
    bottom = max(0, height - crop_bottom)
    if bottom <= top:
        return image.copy()
    return image.crop((0, top, width, bottom))


def fit_screenshot(image: Image.Image) -> Image.Image:
    max_width = CANVAS_WIDTH - (SCREEN_SIDE * 2)
    max_height = CANVAS_HEIGHT - SCREEN_TOP - SCREEN_BOTTOM
    ratio = min(max_width / image.width, max_height / image.height)
    new_size = (int(image.width * ratio), int(image.height * ratio))
    return image.resize(new_size, Image.Resampling.LANCZOS)


def draw_header(
    canvas: Image.Image,
    item: dict[str, Any],
    brand_icon: Image.Image | None,
    app_name: str,
) -> None:
    draw = ImageDraw.Draw(canvas)
    pill_font = load_font(24, bold=True)
    headline_font = load_font(68, bold=True)
    sub_font = load_font(28, bold=False)

    pill_text = item.get("eyebrow", app_name.upper())
    pill_bbox = draw.textbbox((0, 0), pill_text, font=pill_font)
    pill_width = pill_bbox[2] - pill_bbox[0]
    pill_height = pill_bbox[3] - pill_bbox[1]
    pill_box = (HEADER_LEFT, 72, HEADER_LEFT + pill_width + 64, 72 + pill_height + 26)
    draw.rounded_rectangle(pill_box, radius=30, fill=ACCENT_SOFT, outline=(243, 154, 74, 90), width=2)
    if brand_icon:
        icon_size = 34
        icon = brand_icon.resize((icon_size, icon_size), Image.Resampling.LANCZOS)
        icon_y = pill_box[1] + ((pill_box[3] - pill_box[1] - icon_size) // 2)
        canvas.alpha_composite(icon, (pill_box[0] + 18, icon_y))
        text_x = pill_box[0] + 18 + icon_size + 16
    else:
        text_x = pill_box[0] + 22
    draw.text((text_x, pill_box[1] + 12), pill_text, font=pill_font, fill=ACCENT)

    headline_lines = wrap_text(draw, item["headline"], headline_font, HEADER_RIGHT - HEADER_LEFT)
    headline_y = pill_box[3] + 34
    for line in headline_lines:
        draw.text((HEADER_LEFT, headline_y), line, font=headline_font, fill=TEXT_PRIMARY)
        line_height = draw.textbbox((0, 0), line, font=headline_font)[3]
        headline_y += line_height + 10

    subheadline = item.get("subheadline", "").strip()
    if subheadline:
        sub_lines = wrap_text(draw, subheadline, sub_font, HEADER_RIGHT - HEADER_LEFT)
        sub_y = headline_y + 10
        for line in sub_lines:
            draw.text((HEADER_LEFT, sub_y), line, font=sub_font, fill=TEXT_SECONDARY)
            line_height = draw.textbbox((0, 0), line, font=sub_font)[3]
            sub_y += line_height + 8


def place_screenshot(canvas: Image.Image, screenshot: Image.Image) -> None:
    shadow = Image.new("RGBA", canvas.size, (0, 0, 0, 0))
    shadow_draw = ImageDraw.Draw(shadow)
    x = (CANVAS_WIDTH - screenshot.width) // 2
    y = SCREEN_TOP + ((CANVAS_HEIGHT - SCREEN_TOP - SCREEN_BOTTOM - screenshot.height) // 2)
    shadow_box = (x + 6, y + 18, x + screenshot.width + 6, y + screenshot.height + 18)
    shadow_draw.rounded_rectangle(shadow_box, radius=SCREEN_RADIUS, fill=(0, 0, 0, 120))
    shadow = shadow.filter(ImageFilter.GaussianBlur(24))
    canvas.alpha_composite(shadow)

    screenshot_rgba = screenshot.convert("RGBA")
    mask = rounded_mask(screenshot_rgba.size, SCREEN_RADIUS)
    framed = Image.new("RGBA", screenshot_rgba.size, (0, 0, 0, 0))
    framed.paste(screenshot_rgba, (0, 0), mask)
    border = Image.new("RGBA", screenshot_rgba.size, (0, 0, 0, 0))
    border_draw = ImageDraw.Draw(border)
    border_draw.rounded_rectangle(
        (0, 0, screenshot_rgba.width - 1, screenshot_rgba.height - 1),
        radius=SCREEN_RADIUS,
        outline=(255, 255, 255, 32),
        width=2,
    )
    framed = Image.alpha_composite(framed, border)
    canvas.alpha_composite(framed, (x, y))


def generate_one(
    item: dict[str, Any],
    *,
    project_root: Path,
    icon: Image.Image | None,
    app_name: str,
) -> Path:
    input_path = resolve_path(project_root, item["input"])
    output_path = resolve_path(project_root, item["output"])
    output_path.parent.mkdir(parents=True, exist_ok=True)

    source = Image.open(input_path).convert("RGB")
    cropped = crop_source(
        source,
        int(item.get("crop_top", 0)),
        int(item.get("crop_bottom", 0)),
    )
    fitted = fit_screenshot(cropped)

    canvas = make_background()
    draw_header(canvas, item, icon, app_name)
    place_screenshot(canvas, fitted)
    canvas.save(output_path)
    return output_path


def validate_manifest(manifest: dict[str, Any], project_root: Path) -> list[str]:
    issues: list[str] = []
    if "screenshots" not in manifest or not isinstance(manifest["screenshots"], list):
        issues.append("Manifest must contain a screenshots list.")
        return issues
    for index, item in enumerate(manifest["screenshots"], start=1):
        if "input" not in item or "output" not in item or "headline" not in item:
            issues.append(f"Screenshot item {index} is missing input, output, or headline.")
            continue
        input_path = resolve_path(project_root, item["input"])
        if not input_path.exists():
            issues.append(f"Missing input image: {input_path}")
    return issues


def main() -> int:
    args = parse_args()
    project_root = Path(args.project_root).resolve()
    config_path = resolve_path(project_root, args.config)
    manifest = load_manifest(config_path)

    issues = validate_manifest(manifest, project_root)
    if issues:
        for issue in issues:
            print(f"[missing] {issue}")
        return 1

    if args.validate:
        print("Manifest validation passed.")
        return 0

    app_name = manifest.get("app_name", "Guarden")
    icon_path_raw = manifest.get("brand_icon")
    icon: Image.Image | None = None
    if icon_path_raw:
        icon_path = resolve_path(project_root, icon_path_raw)
        if icon_path.exists():
            icon = Image.open(icon_path).convert("RGBA")

    generated: list[Path] = []
    for item in manifest["screenshots"]:
        generated.append(
            generate_one(item, project_root=project_root, icon=icon, app_name=app_name)
        )

    for path in generated:
        print(f"[ok] {path}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
