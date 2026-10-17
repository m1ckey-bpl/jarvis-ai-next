import math
from PIL import Image, ImageDraw

def generate_icon(output_path):
    size = 1024
    img = Image.new("RGBA", (size, size), (10, 10, 15, 255))
    draw = ImageDraw.Draw(img)

    center = size / 2

    # Background subtle radial rings
    for r in range(480, 100, -40):
        alpha = int(15 + (480 - r) * 0.08)
        draw.ellipse(
            [center - r, center - r, center + r, center + r],
            outline=(0, 217, 255, alpha),
            width=2
        )

    # Outer arc / orbital rings
    draw.ellipse(
        [center - 360, center - 360, center + 360, center + 360],
        outline=(0, 217, 255, 140),
        width=6
    )

    draw.ellipse(
        [center - 320, center - 320, center + 320, center + 320],
        outline=(255, 255, 255, 60),
        width=3
    )

    # Core glowing circular iris
    for r in range(240, 40, -10):
        ratio = (240 - r) / 200.0
        red = int(0 * (1 - ratio) + 255 * ratio)
        green = int(180 * (1 - ratio) + 255 * ratio)
        blue = int(255)
        alpha = int(180 * (1 - ratio) + 255 * ratio)
        draw.ellipse(
            [center - r, center - r, center + r, center + r],
            outline=(red, green, blue, alpha),
            width=3
        )

    # Center power core
    draw.ellipse(
        [center - 90, center - 90, center + 90, center + 90],
        fill=(255, 255, 255, 255)
    )

    # Subtle inner geometric accents
    for angle_deg in range(0, 360, 45):
        rad = math.radians(angle_deg)
        x1 = center + math.cos(rad) * 110
        y1 = center + math.sin(rad) * 110
        x2 = center + math.cos(rad) * 220
        y2 = center + math.sin(rad) * 220
        draw.line([(x1, y1), (x2, y2)], fill=(0, 217, 255, 180), width=4)

    # Convert to RGB (App Store requires no alpha channel in iOS app icon)
    final_img = Image.new("RGB", (size, size), (10, 10, 15))
    final_img.paste(img, mask=img.split()[3])
    final_img.save(output_path, "PNG")
    print(f"Generated app icon at {output_path}")

if __name__ == "__main__":
    import sys
    out = sys.argv[1] if len(sys.argv) > 1 else "ios/JarvisApp/Resources/Assets.xcassets/AppIcon.appiconset/AppIcon.png"
    generate_icon(out)
