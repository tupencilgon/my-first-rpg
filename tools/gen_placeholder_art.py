"""
Tao art pixel tam thoi (placeholder) cho game - luoi 32x32.
Chay:  python tools/gen_placeholder_art.py

Script nay ve bang code, khong can cai them thu vien nao.
Khi ban da ve art that bang Aseprite, chi can thay the file PNG
trong assets/ la xong - khong can sua code game.

QUAN TRONG: giu nguyen kich thuoc anh khi thay art that.
  player.png  = 128x128  (4 cot frame di bo  x  4 hang huong, moi o 32x32)
  floor.png   = 32x32
  wall.png    = 32x32
"""

import os
import struct
import zlib

HERE = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

# Kich thuoc 1 o trong sprite sheet, cung la kich thuoc 1 tile.
FRAME = 32


# ---------------------------------------------------------------- PNG writer
def write_png(path, width, height, pixels):
    """pixels: list[height] cua list[width] cua tuple (r, g, b, a)."""
    raw = bytearray()
    for row in pixels:
        raw.append(0)  # filter type 0 = None
        for (r, g, b, a) in row:
            raw += bytes((r, g, b, a))

    def chunk(tag, data):
        body = tag + data
        return struct.pack(">I", len(data)) + body + struct.pack(">I", zlib.crc32(body) & 0xFFFFFFFF)

    png = b"\x89PNG\r\n\x1a\n"
    png += chunk(b"IHDR", struct.pack(">IIBBBBB", width, height, 8, 6, 0, 0, 0))
    png += chunk(b"IDAT", zlib.compress(bytes(raw), 9))
    png += chunk(b"IEND", b"")

    os.makedirs(os.path.dirname(path), exist_ok=True)
    with open(path, "wb") as f:
        f.write(png)
    try:
        shown = os.path.relpath(path, HERE).replace("\\", "/")
    except ValueError:  # khac o dia thi khong tinh duong dan tuong doi duoc
        shown = path
    print("  ->", shown)


def blank(w, h):
    return [[(0, 0, 0, 0) for _ in range(w)] for _ in range(h)]


# ---------------------------------------------------------------- bang mau
CLEAR = (0, 0, 0, 0)
OUTLINE = (37, 30, 46, 255)

SKIN_L = (255, 222, 192, 255)
SKIN = (240, 195, 160, 255)
SKIN_D = (206, 156, 124, 255)

HAIR_L = (126, 84, 62, 255)
HAIR = (92, 58, 46, 255)
HAIR_D = (64, 39, 32, 255)

EYE = (37, 30, 46, 255)
EYE_HL = (255, 252, 248, 255)
MOUTH = (172, 96, 92, 255)
BLUSH = (232, 160, 150, 255)

SHIRT_L = (110, 166, 224, 255)
SHIRT = (72, 128, 196, 255)
SHIRT_D = (52, 96, 156, 255)

PANTS = (88, 96, 136, 255)
PANTS_D = (64, 70, 104, 255)

BOOT_L = (154, 112, 80, 255)
BOOT = (124, 86, 60, 255)

BELT_L = (140, 100, 70, 255)
BELT = (96, 64, 44, 255)
BUCKLE = (198, 168, 96, 255)

GRASS_L = (128, 176, 104, 255)
GRASS = (104, 152, 88, 255)
GRASS_D = (84, 128, 72, 255)

STONE_L = (158, 152, 168, 255)
STONE = (128, 122, 138, 255)
STONE_D = (92, 88, 104, 255)
MORTAR = (74, 70, 86, 255)


# ---------------------------------------------------------------- helpers ve
def rect(px, x0, y0, x1, y1, color):
    """Ve hinh chu nhat dac, bao gom ca (x1, y1)."""
    h = len(px)
    w = len(px[0])
    for y in range(y0, y1 + 1):
        for x in range(x0, x1 + 1):
            if 0 <= x < w and 0 <= y < h:
                px[y][x] = color


def dot(px, x, y, color):
    if 0 <= y < len(px) and 0 <= x < len(px[0]):
        px[y][x] = color


def add_outline(px, color=OUTLINE):
    """Them vien 1px quanh moi vung khong trong suot - meo pixel art co ban.

    Vien luon day 1px du art to hay nho. Do la ly do art 32x32 trong
    'mem' hon 16x16: ti le vien tren than nguoi nho di mot nua.
    """
    h, w = len(px), len(px[0])
    todo = []
    for y in range(h):
        for x in range(w):
            if px[y][x][3] != 0:
                continue
            for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)):
                nx, ny = x + dx, y + dy
                if 0 <= nx < w and 0 <= ny < h and px[ny][nx][3] != 0 and px[ny][nx] != color:
                    todo.append((x, y))
                    break
    for x, y in todo:
        px[y][x] = color


def round_corners(px, x0, y0, x1, y1, size=2, top=True, bottom=True):
    """Cat goc cho khoi bot vuong.

    O luoi 32x32, mot cai dau hinh chu nhat vuong chan lo ra rat ro - trong
    khi o 16x16 thi mat gan nhu khong nhan ra. Art cang to cang can bo goc.
    """
    for i in range(size):
        for j in range(size):
            if i + j >= size:
                continue
            if top:
                dot(px, x0 + i, y0 + j, CLEAR)
                dot(px, x1 - i, y0 + j, CLEAR)
            if bottom:
                dot(px, x0 + i, y1 - j, CLEAR)
                dot(px, x1 - i, y1 - j, CLEAR)


def mirror_x(px):
    return [list(reversed(row)) for row in px]


# ---------------------------------------------------------------- nhan vat
# Moi frame 32x32. Sheet cuoi cung: 4 cot (frame di bo) x 4 hang (huong).
# Thu tu hang:  0 = xuong, 1 = len, 2 = trai, 3 = phai
#
# Chu ky di bo 4 frame: dung - nhac chan trai - dung - nhac chan phai.
# O luoi 32px phai nhac 2 pixel thi mat moi thay ro (16px chi can 1).
LEG_CYCLE = [(0, 0), (-2, 0), (0, 0), (0, -2)]


def one_leg(px, x0, x1, lift, shade=0):
    """Chan cao 4px: 2px quan + 2px giay. lift am = nhac chan len."""
    pants_a = PANTS_D if shade else PANTS
    pants_b = PANTS_D
    boot_a = BOOT if shade else BOOT_L
    boot_b = BOOT
    rect(px, x0, 27 + lift, x1, 27 + lift, pants_a)
    rect(px, x0, 28 + lift, x1, 28 + lift, pants_b)
    rect(px, x0, 29 + lift, x1, 29 + lift, boot_a)
    rect(px, x0, 30 + lift, x1, 30 + lift, boot_b)


def _torso(px, x0, x1, belt_buckle=True):
    """Than tren: ao co vet sang ben trai, bong ben phai, that lung."""
    rect(px, x0, 18, x1, 26, SHIRT)
    rect(px, x0, 19, x0 + 1, 24, SHIRT_L)
    rect(px, x1 - 1, 22, x1, 26, SHIRT_D)
    rect(px, x0, 25, x1, 26, BELT)
    rect(px, x0, 25, x1, 25, BELT_L)
    if belt_buckle:
        mid = (x0 + x1) // 2
        rect(px, mid, 25, mid + 1, 26, BUCKLE)


def _arm(px, x0, x1, shaded=False):
    """Tay ao + ban tay."""
    rect(px, x0, 19, x1, 23, SHIRT_D if shaded else SHIRT)
    rect(px, x0, 23, x1, 23, SHIRT_D)
    rect(px, x0, 24, x1, 26, SKIN_D if shaded else SKIN)
    rect(px, x0, 26, x1, 26, SKIN_D)


def char_down(frame):
    """Nhin chinh dien: thay mat, hai mat, mieng, ma hong."""
    px = blank(FRAME, FRAME)
    lift_l, lift_r = LEG_CYCLE[frame]

    one_leg(px, 12, 15, lift_l)
    one_leg(px, 16, 19, lift_r)
    _torso(px, 11, 20)
    _arm(px, 9, 10)
    _arm(px, 21, 22)

    rect(px, 14, 17, 17, 18, SKIN_D)                  # co

    rect(px, 10, 10, 21, 17, SKIN)                    # mat
    rect(px, 10, 10, 21, 10, SKIN_D)                  # bong duoi mai toc
    rect(px, 10, 17, 21, 17, SKIN_D)                  # bong duoi cam
    dot(px, 11, 12, SKIN_L)
    dot(px, 12, 11, SKIN_L)
    for ex in (12, 18):
        rect(px, ex, 13, ex + 1, 14, EYE)
        dot(px, ex, 13, EYE_HL)                       # diem sang trong mat
    rect(px, 12, 12, 13, 12, HAIR_D)                  # long may
    rect(px, 18, 12, 19, 12, HAIR_D)
    rect(px, 15, 16, 16, 16, MOUTH)
    dot(px, 10, 14, BLUSH)
    dot(px, 21, 14, BLUSH)

    rect(px, 8, 2, 23, 9, HAIR)                       # toc
    rect(px, 10, 3, 17, 4, HAIR_L)
    rect(px, 11, 2, 15, 2, HAIR_L)
    rect(px, 8, 8, 23, 9, HAIR_D)
    rect(px, 8, 10, 9, 15, HAIR)                      # toc hai ben mat
    rect(px, 22, 10, 23, 15, HAIR)
    rect(px, 8, 14, 9, 15, HAIR_D)
    rect(px, 22, 14, 23, 15, HAIR_D)

    round_corners(px, 8, 2, 23, 17, size=2, bottom=False)
    round_corners(px, 10, 10, 21, 17, size=2, top=False)

    add_outline(px)
    return px


def char_up(frame):
    """Nhin tu sau: chi thay toc va gay."""
    px = blank(FRAME, FRAME)
    lift_l, lift_r = LEG_CYCLE[frame]

    one_leg(px, 12, 15, lift_l)
    one_leg(px, 16, 19, lift_r)
    _torso(px, 11, 20, belt_buckle=False)
    _arm(px, 9, 10)
    _arm(px, 21, 22)

    rect(px, 14, 16, 17, 18, SKIN_D)                  # gay

    rect(px, 8, 2, 23, 17, HAIR)                      # toc phu kin dau
    rect(px, 10, 3, 17, 5, HAIR_L)                    # diem sang tren dinh
    rect(px, 11, 2, 15, 2, HAIR_L)
    rect(px, 8, 14, 23, 17, HAIR_D)                   # bong o duoi toc
    rect(px, 8, 10, 9, 17, HAIR_D)
    rect(px, 22, 10, 23, 17, HAIR_D)
    for sx in (11, 14, 17, 20):                       # goi y vai loi toc
        rect(px, sx, 6, sx, 13, HAIR_D if sx % 2 else HAIR_L)

    round_corners(px, 8, 2, 23, 17, size=2)

    add_outline(px)
    return px


def char_left(frame):
    """Nhin nghieng sang trai: mot mat, mot canh tay, toc che gay."""
    px = blank(FRAME, FRAME)
    lift_l, lift_r = LEG_CYCLE[frame]

    one_leg(px, 15, 18, lift_r, shade=1)              # chan xa - to mau toi hon
    one_leg(px, 12, 15, lift_l)                       # chan gan
    _torso(px, 12, 20, belt_buckle=False)
    _arm(px, 10, 11)                                  # chi thay 1 tay

    rect(px, 13, 17, 16, 18, SKIN_D)                  # co

    rect(px, 9, 10, 18, 17, SKIN)                     # mat nhin nghieng
    rect(px, 9, 10, 18, 10, SKIN_D)
    rect(px, 9, 17, 18, 17, SKIN_D)
    dot(px, 8, 13, SKIN)                              # song mui nho ra
    dot(px, 8, 14, SKIN_D)
    rect(px, 11, 13, 12, 14, EYE)
    dot(px, 11, 13, EYE_HL)
    rect(px, 11, 12, 12, 12, HAIR_D)                  # long may
    rect(px, 10, 16, 11, 16, MOUTH)
    dot(px, 15, 15, BLUSH)

    rect(px, 9, 2, 22, 9, HAIR)                       # toc dinh dau
    rect(px, 11, 3, 17, 4, HAIR_L)
    rect(px, 9, 8, 22, 9, HAIR_D)
    rect(px, 17, 10, 22, 17, HAIR)                    # toc sau gay
    rect(px, 20, 13, 22, 17, HAIR_D)

    round_corners(px, 9, 2, 22, 17, size=2, bottom=False)
    round_corners(px, 9, 10, 18, 17, size=2, top=False)

    add_outline(px)
    return px


def build_character_sheet():
    rows = []
    for maker in (char_down, char_up, char_left):
        rows.append([maker(f) for f in range(4)])
    rows.append([mirror_x(f) for f in rows[2]])  # huong phai = lat nguoc huong trai

    sheet = blank(FRAME * 4, FRAME * 4)
    for ry, frames in enumerate(rows):
        for rx, frame in enumerate(frames):
            for y in range(FRAME):
                for x in range(FRAME):
                    sheet[ry * FRAME + y][rx * FRAME + x] = frame[y][x]
    return sheet


# ---------------------------------------------------------------- tile
def build_floor():
    """Tile co 32x32, lien mach khi lap lai.

    Luu y: TUYET DOI khong nhet vat the de nhan ra (hoa, da, nam...) vao tile
    nen. Chung se lap lai dung mot vi tri cu 32 pixel, tao thanh luoi deu tap
    tap - mat nguoi nhin ra ngay va map trong rat gia. Chi de ket cau co mo
    nhat o day; hoa va vat trang tri phai rai rac thu cong tren map bang
    TileMapLayer hoac dat thanh Sprite2D rieng.
    """
    px = blank(FRAME, FRAME)
    rect(px, 0, 0, 31, 31, GRASS)

    blades_d = [(3, 5), (12, 2), (20, 7), (27, 4), (6, 14), (17, 12), (25, 17),
                (2, 22), (10, 26), (19, 24), (29, 28), (14, 19), (23, 30)]
    blades_l = [(8, 3), (16, 8), (30, 11), (5, 10), (21, 15), (12, 21),
                (26, 23), (1, 17), (18, 29), (9, 31)]
    for x, y in blades_d:
        dot(px, x, y, GRASS_D)
        dot(px, (x + 1) % 32, y, GRASS_D)
        dot(px, x, (y + 1) % 32, GRASS_D)
    for x, y in blades_l:
        dot(px, x, y, GRASS_L)
        dot(px, x, (y + 1) % 32, GRASS_L)
    return px


def build_wall():
    """Tile tuong gach 32x32, lien mach khi lap lai.

    Bo cuc: 2 hang gach, hang duoi lech nua vien so voi hang tren.
    """
    px = blank(FRAME, FRAME)
    rect(px, 0, 0, 31, 31, STONE)

    # Mach vua ngang (dong thoi la day cua moi hang gach).
    rect(px, 0, 15, 31, 15, MORTAR)
    rect(px, 0, 31, 31, 31, MORTAR)
    # Mach vua doc: hang tren nut o giua, hang duoi nut o mep -> so le.
    rect(px, 15, 0, 15, 15, MORTAR)
    rect(px, 31, 16, 31, 31, MORTAR)

    # Vien sang tren dinh va vien toi duoi day cua tung vien gach.
    for (y0, y1) in ((0, 14), (16, 30)):
        rect(px, 0, y0, 31, y0, STONE_L)
        rect(px, 0, y1, 31, y1, STONE_D)

    # Ham nho cho da co ve ro rap, khong phang li.
    for x, y in ((4, 5), (22, 3), (9, 20), (27, 24), (18, 9), (2, 27)):
        dot(px, x, y, STONE_D)
    for x, y in ((11, 7), (25, 11), (6, 23), (19, 27), (29, 6)):
        dot(px, x, y, STONE_L)
    return px


# ---------------------------------------------------------------- main
def main():
    print("Dang tao art placeholder (luoi 32x32)...")
    write_png(os.path.join(HERE, "assets", "sprites", "player.png"),
              FRAME * 4, FRAME * 4, build_character_sheet())
    write_png(os.path.join(HERE, "assets", "tiles", "floor.png"),
              FRAME, FRAME, build_floor())
    write_png(os.path.join(HERE, "assets", "tiles", "wall.png"),
              FRAME, FRAME, build_wall())
    print("Xong.")


if __name__ == "__main__":
    main()
