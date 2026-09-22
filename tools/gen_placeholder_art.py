"""
Tao art pixel tam thoi (placeholder) cho game - luoi 32x32, SPRITE PHAN LOP.
Chay:  python tools/gen_placeholder_art.py

Script nay ve bang code, khong can cai them thu vien nao.

=== HE THONG PHAN LOP (paper doll) ===

Nhan vat KHONG phai mot anh duy nhat. No la nhieu lop PNG chong len nhau:

    Body    <- than the: da, toc, mat, do lot. Lop nay co VIEN.
    Outfit  <- bo do (giap + quan). Ve de len than, khong can vien rieng.
    Helmet  <- mu. Ve de len toc.
    Weapon  <- vu khi. Thò ra ngoai than nen CO vien rieng.

Moi lop la 1 file PNG 128x128, cung bo cuc 4 cot x 4 hang, phan khong co gi
thi de trong suot. Code trong player.gd gan CUNG MOT chi so frame cho ca 4 lop.

Nho vay chi phi art la phep CONG chu khong phai phep NHAN:
  3 bo do + 3 mu = 6 file  ->  van ra 9 ve ngoai khac nhau.

=== QUY TAC BAT BUOC KHI VE ART THAT ===

1. Moi lop PHAI cung kich thuoc 128x128 va cung bo cuc 4x4.
2. Moi lop PHAI dung chung mot bo toa do hinh hoc (bien GEOM ben duoi).
   Neu lop Outfit ve than o hang 18-26 ma lop Body dat than o hang 17-25
   thi quan ao se lech khoi nguoi.
3. Ban nam va ban nu PHAI cung dang nguoi (silhouette). Chi khac toc va mat.
   Neu dang nguoi khac nhau thi MOI bo do phai ve hai lan -> gap doi cong viec.

QUAN TRONG: giu nguyen kich thuoc anh khi thay art that.
  Moi file sprite = 128x128  (4 cot frame  x  4 hang huong, moi o 32x32)
  Tile            = 32x32
"""

import os
import struct
import zlib

HERE = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

# Kich thuoc 1 o trong sprite sheet, cung la kich thuoc 1 tile.
FRAME = 32

# Chi so hang trong sprite sheet = huong nhin.
DOWN, UP, LEFT, RIGHT = 0, 1, 2, 3


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

# Do lot cua lop Body - chi thay khi chua mac bo do nao.
UNDER_L = (198, 192, 186, 255)
UNDER = (166, 160, 154, 255)
UNDER_D = (130, 124, 120, 255)

GRASS_L = (128, 176, 104, 255)
GRASS = (104, 152, 88, 255)
GRASS_D = (84, 128, 72, 255)

STONE_L = (158, 152, 168, 255)
STONE = (128, 122, 138, 255)
STONE_D = (92, 88, 104, 255)
MORTAR = (74, 70, 86, 255)

DIRT_L = (172, 136, 98, 255)
DIRT = (146, 110, 74, 255)
DIRT_D = (116, 86, 56, 255)

SLAB_L = (188, 182, 174, 255)
SLAB = (156, 150, 142, 255)
SLAB_D = (118, 112, 106, 255)

WOOD_L = (172, 126, 80, 255)
WOOD = (140, 98, 60, 255)
WOOD_D = (104, 70, 42, 255)

WATER_L = (108, 176, 216, 255)
WATER = (62, 126, 182, 255)
WATER_D = (40, 92, 142, 255)

CAVE_L = (112, 106, 116, 255)
CAVE = (86, 82, 92, 255)
CAVE_D = (60, 56, 66, 255)

CAVEW_L = (86, 80, 94, 255)
CAVEW = (58, 54, 66, 255)
CAVEW_D = (36, 33, 42, 255)

# --- Mau cho Aster sau dem chay ---
ASH_L = (152, 146, 142, 255)
ASH = (120, 114, 110, 255)
ASH_D = (88, 83, 80, 255)

CHAR_L = (76, 64, 58, 255)          # go chay den
CHAR = (50, 42, 38, 255)
CHAR_D = (30, 25, 23, 255)

BGRASS_L = (118, 110, 82, 255)      # co chay kho, vang uc
BGRASS = (92, 86, 64, 255)
BGRASS_D = (66, 62, 46, 255)

LEAF_L = (92, 138, 74, 255)         # tan cay
LEAF = (58, 100, 52, 255)
LEAF_D = (36, 70, 38, 255)

GDIRT_L = (112, 94, 72, 255)        # dat nghia trang
GDIRT = (86, 70, 54, 255)
GDIRT_D = (60, 48, 36, 255)


def palette(light, mid, dark):
    """Gom 3 sac do cua cung mot chat lieu thanh 1 bo mau."""
    return {"l": light, "m": mid, "d": dark}


# Bo do: (sang, vua, toi). Them bo moi chi can them 1 dong o day.
OUTFIT_CLOTH = palette((110, 166, 224, 255), (72, 128, 196, 255), (52, 96, 156, 255))
OUTFIT_LEATHER = palette((166, 116, 72, 255), (128, 84, 50, 255), (92, 58, 34, 255))

HELMET_IRON = palette((188, 192, 204, 255), (140, 146, 162, 255), (94, 100, 118, 255))

WEAPON_SWORD = palette((222, 226, 236, 255), (176, 182, 198, 255), (110, 116, 134, 255))
WEAPON_BOW = palette((166, 116, 72, 255), (128, 84, 50, 255), (92, 58, 34, 255))


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

    CHI dung cho lop Body va lop Weapon. Lop Outfit va Helmet nam gon ben
    trong dang nguoi nen dung chung vien cua Body; neu them vien rieng thi
    quan ao se co duong ke den chay giua nguoi.
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


# ---------------------------------------------------------------- HINH HOC CHUNG
#
# DAY LA PHAN QUAN TRONG NHAT CUA FILE.
#
# Moi lop (Body, Outfit, Helmet, Weapon) deu doc toa do tu day. Sua mot con so
# o day la ca bon lop cung dich theo, khong bao gio lech nhau.
#
# Hang (row) tinh tu tren xuong, 0 o dinh anh 32x32:
#   2-9   toc / mu
#   10-17 mat
#   17-18 co
#   18-26 than (ao)
#   27-30 chan (quan + giay)

ROW_HAIR = (2, 9)
ROW_FACE = (10, 17)
ROW_NECK = (17, 18)
ROW_TORSO = (18, 26)
ROW_ARM = (19, 26)
ROW_LEG = (27, 30)

GEOM = {
    DOWN: {
        "head": (8, 23),
        "face": (10, 21),
        "torso": (11, 20),
        "arms": ((9, 10), (21, 22)),
        "legs": ((12, 15), (16, 19)),
        "hair_side": ((8, 9), (22, 23)),
    },
    UP: {
        "head": (8, 23),
        "face": None,                      # nhin tu sau, khong thay mat
        "torso": (11, 20),
        "arms": ((9, 10), (21, 22)),
        "legs": ((12, 15), (16, 19)),
        "hair_side": ((8, 9), (22, 23)),
    },
    LEFT: {
        "head": (9, 22),
        "face": (9, 18),
        "torso": (12, 20),
        "arms": ((10, 11),),               # nhin nghieng chi thay 1 tay
        "legs": ((12, 15), (15, 18)),      # chan gan, chan xa
        "hair_side": ((17, 22),),          # toc sau gay
    },
}

# Chu ky di bo 4 frame: dung - nhac chan trai - dung - nhac chan phai.
# O luoi 32px phai nhac 2 pixel thi mat moi thay ro (16px chi can 1).
LEG_CYCLE = [(0, 0), (-2, 0), (0, 0), (0, -2)]


# ---------------------------------------------------------------- LOP: BODY
def _legs(px, d, frame, pal_upper, pal_lower, boots=True):
    """Ve hai chan theo dung chu ky buoc. Dung chung cho Body va Outfit."""
    lift_l, lift_r = LEG_CYCLE[frame]
    legs = GEOM[d]["legs"]
    y0, y1 = ROW_LEG

    # Huong nghieng: chan xa ve truoc va to mau toi hon cho co chieu sau.
    order = [(legs[1], lift_r, True), (legs[0], lift_l, False)] if d == LEFT else \
            [(legs[0], lift_l, False), (legs[1], lift_r, False)]

    for (x0, x1), lift, far in order:
        upper = pal_upper["d"] if far else pal_upper["m"]
        lower = pal_lower["d"] if far else pal_lower["m"]
        rect(px, x0, y0 + lift, x1, y0 + lift, upper)
        rect(px, x0, y0 + 1 + lift, x1, y0 + 1 + lift, pal_upper["d"])
        if boots:
            rect(px, x0, y1 - 1 + lift, x1, y1 - 1 + lift, lower)
            rect(px, x0, y1 + lift, x1, y1 + lift, pal_lower["d"])


def layer_body(d, frame, female=False):
    """Than the: da, toc, mat, do lot. Lop duy nhat co vien day du.

    Tham so `female` hien KHONG duoc dung: cot truyen chot nhan vat chinh la
    Kael (nam), nen chi sinh ra body_male.png. Giu lai doan code nay vi neu
    sau nay them nhan vat nu thi chi can bat lai mot dong o ham main().

    QUAN TRONG neu sau nay bat lai: ban nam va ban nu phai dung CHUNG dang
    nguoi, chi khac toc va mat. Neu dang nguoi khac nhau thi moi bo do va moi
    cai mu deu phai ve hai lan - nhan doi khoi luong art trang bi, vinh vien.
    """
    g = GEOM[d]
    px = blank(FRAME, FRAME)
    under = palette(UNDER_L, UNDER, UNDER_D)

    _legs(px, d, frame, under, under)

    # Than + tay trong do lot.
    tx0, tx1 = g["torso"]
    rect(px, tx0, ROW_TORSO[0], tx1, ROW_TORSO[1], UNDER)
    rect(px, tx0, ROW_TORSO[1], tx1, ROW_TORSO[1], UNDER_D)
    for (ax0, ax1) in g["arms"]:
        rect(px, ax0, ROW_ARM[0], ax1, ROW_ARM[0] + 4, UNDER)
        rect(px, ax0, ROW_ARM[0] + 5, ax1, ROW_ARM[1], SKIN)   # ban tay

    # Co.
    nx0 = (tx0 + tx1) // 2 - 1
    rect(px, nx0, ROW_NECK[0], nx0 + 3, ROW_NECK[1], SKIN_D)

    hx0, hx1 = g["head"]
    fr0, fr1 = ROW_FACE

    if g["face"] is not None:
        fx0, fx1 = g["face"]
        rect(px, fx0, fr0, fx1, fr1, SKIN)
        rect(px, fx0, fr0, fx1, fr0, SKIN_D)                   # bong duoi mai toc
        rect(px, fx0, fr1, fx1, fr1, SKIN_D)                   # bong duoi cam
        if d == DOWN:
            for ex in (12, 18):
                rect(px, ex, 13, ex + 1, 14, EYE)
                dot(px, ex, 13, EYE_HL)
            rect(px, 12, 12, 13, 12, HAIR_D)                   # long may
            rect(px, 18, 12, 19, 12, HAIR_D)
            rect(px, 15, 16, 16, 16, MOUTH)
            dot(px, 10, 14, BLUSH)
            dot(px, 21, 14, BLUSH)
        else:                                                   # nghieng trai
            dot(px, fx0 - 1, 13, SKIN)                         # song mui
            dot(px, fx0 - 1, 14, SKIN_D)
            rect(px, 11, 13, 12, 14, EYE)
            dot(px, 11, 13, EYE_HL)
            rect(px, 11, 12, 12, 12, HAIR_D)
            rect(px, 10, 16, 11, 16, MOUTH)
            dot(px, 15, 15, BLUSH)

    # Toc.
    hr0, hr1 = ROW_HAIR
    rect(px, hx0, hr0, hx1, hr1, HAIR)
    rect(px, hx0 + 2, hr0 + 1, hx0 + 9, hr0 + 2, HAIR_L)       # diem sang
    rect(px, hx0 + 3, hr0, hx0 + 7, hr0, HAIR_L)
    rect(px, hx0, hr1 - 1, hx1, hr1, HAIR_D)

    if d == UP:
        rect(px, hx0, fr0, hx1, fr1, HAIR)                     # sau dau toan toc
        rect(px, hx0, fr1 - 3, hx1, fr1, HAIR_D)
        for sx in (hx0 + 3, hx0 + 6, hx0 + 9, hx0 + 12):
            rect(px, sx, hr0 + 4, sx, fr1 - 4, HAIR_D if sx % 2 else HAIR_L)
    else:
        for (sx0, sx1) in g["hair_side"]:
            rect(px, sx0, fr0, sx1, fr1 - 2, HAIR)
            rect(px, sx0, fr1 - 3, sx1, fr1 - 2, HAIR_D)

    # Toc dai cho ban nu: xoa xuong qua vai o hai ben than.
    if female:
        long_rows = (fr1 - 1, ROW_TORSO[0] + 3)
        if d == LEFT:
            rect(px, 18, long_rows[0], 21, long_rows[1], HAIR)
            rect(px, 20, long_rows[0], 21, long_rows[1], HAIR_D)
        else:
            rect(px, hx0, long_rows[0], hx0 + 1, long_rows[1], HAIR)
            rect(px, hx1 - 1, long_rows[0], hx1, long_rows[1], HAIR)
            rect(px, hx0, long_rows[1], hx0 + 1, long_rows[1], HAIR_D)
            rect(px, hx1 - 1, long_rows[1], hx1, long_rows[1], HAIR_D)

    round_corners(px, hx0, hr0, hx1, fr1, size=2, bottom=(d == UP))
    if g["face"] is not None:
        fx0, fx1 = g["face"]
        round_corners(px, fx0, fr0, fx1, fr1, size=2, top=False)

    add_outline(px)
    return px


# ---------------------------------------------------------------- LOP: OUTFIT
def layer_outfit(d, frame, pal):
    """Bo do = giap (than + tay ao) + quan. Ve de len Body, KHONG co vien.

    Gop giap va quan lam mot lop: o goc nhin top-down, quan chiem rat it pixel
    nen tach rieng khong dang - ma lai ton them nguyen mot bo frame.
    """
    g = GEOM[d]
    px = blank(FRAME, FRAME)

    _legs(px, d, frame, pal, pal, boots=False)

    tx0, tx1 = g["torso"]
    ty0, ty1 = ROW_TORSO
    rect(px, tx0, ty0, tx1, ty1, pal["m"])
    rect(px, tx0, ty0 + 1, tx0 + 1, ty1 - 2, pal["l"])          # vet sang ben trai
    rect(px, tx1 - 1, ty0 + 4, tx1, ty1, pal["d"])              # bong ben phai
    rect(px, tx0, ty1, tx1, ty1, pal["d"])

    # Tay ao: chi phu phan tren, chua ban tay lai.
    for (ax0, ax1) in g["arms"]:
        rect(px, ax0, ROW_ARM[0], ax1, ROW_ARM[0] + 4, pal["m"])
        rect(px, ax0, ROW_ARM[0] + 4, ax1, ROW_ARM[0] + 4, pal["d"])

    return px


# ---------------------------------------------------------------- LOP: HELMET
def layer_helmet(d, frame, pal):
    """Mu: phu len vung toc. Ve de len Body, khong co vien rieng."""
    g = GEOM[d]
    px = blank(FRAME, FRAME)
    hx0, hx1 = g["head"]
    hr0, hr1 = ROW_HAIR

    rect(px, hx0, hr0, hx1, hr1 + 1, pal["m"])
    rect(px, hx0 + 2, hr0 + 1, hx0 + 9, hr0 + 2, pal["l"])      # diem sang
    rect(px, hx0, hr1, hx1, hr1 + 1, pal["d"])                  # vanh mu

    if d != UP:
        # Hai mieng che ma.
        for (sx0, sx1) in (((hx0, hx0 + 1), (hx1 - 1, hx1)) if d != LEFT else ((hx1 - 3, hx1),)):
            rect(px, sx0, hr1 + 2, sx1, ROW_FACE[0] + 3, pal["m"])
            rect(px, sx0, ROW_FACE[0] + 3, sx1, ROW_FACE[0] + 3, pal["d"])

    round_corners(px, hx0, hr0, hx1, hr1 + 1, size=2, bottom=False)
    return px


# ---------------------------------------------------------------- LOP: WEAPON
def layer_weapon(d, frame, pal, kind="sword"):
    """Vu khi cam o tay. Tho ra ngoai dang nguoi nen CO vien rieng.

    Chi hien khi nhan vat dang o trang thai chien dau (player.gd bat/tat).
    """
    g = GEOM[d]
    px = blank(FRAME, FRAME)

    # Tay cam vu khi: huong nghieng thi la tay duy nhat, con lai la tay phai.
    #
    # Huong nghieng phai day vu khi ra xa hon (-4 thay vi +1), neu khong luoi
    # kiem se cat ngang qua mat nhan vat - loi nay chi lo ra khi chong cac lop
    # len nhau, nhin tung lop rieng thi khong thay.
    hand = g["arms"][-1]
    hx = hand[1] + 1 if d != LEFT else hand[0] - 4

    # Vu khi bat dau tu ngang vai (hang 14) tro xuong, khong dua len qua dau.
    if kind == "sword":
        rect(px, hx, 14, hx + 1, 25, pal["m"])                  # luoi kiem
        rect(px, hx, 14, hx, 25, pal["l"])                      # canh sang
        rect(px, hx - 1, 26, hx + 2, 26, pal["d"])              # chan kiem
        rect(px, hx, 27, hx + 1, 28, (92, 58, 34, 255))         # can go
    else:                                                        # cung
        rect(px, hx, 15, hx, 27, pal["m"])                      # than cung
        rect(px, hx + 1, 14, hx + 1, 15, pal["d"])              # dau cong tren
        rect(px, hx + 1, 27, hx + 1, 28, pal["d"])              # dau cong duoi
        rect(px, hx - 1, 16, hx - 1, 26, pal["l"])              # day cung

    add_outline(px)
    return px


# ---------------------------------------------------------------- ghep sheet
def build_sheet(make_frame):
    """Ghep 16 o thanh 1 sheet 128x128.

    make_frame(huong, frame) -> anh 32x32.
    Huong PHAI (hang 3) sinh ra bang cach lat nguoc huong TRAI - tiet kiem
    mot phan tu cong viec ve, va dam bao hai huong luon khop nhau.
    """
    rows = []
    for d in (DOWN, UP, LEFT):
        rows.append([make_frame(d, f) for f in range(4)])
    rows.append([mirror_x(f) for f in rows[LEFT]])

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

    rect(px, 0, 15, 31, 15, MORTAR)
    rect(px, 0, 31, 31, 31, MORTAR)
    rect(px, 15, 0, 15, 15, MORTAR)
    rect(px, 31, 16, 31, 31, MORTAR)

    for (y0, y1) in ((0, 14), (16, 30)):
        rect(px, 0, y0, 31, y0, STONE_L)
        rect(px, 0, y1, 31, y1, STONE_D)

    for x, y in ((4, 5), (22, 3), (9, 20), (27, 24), (18, 9), (2, 27)):
        dot(px, x, y, STONE_D)
    for x, y in ((11, 7), (25, 11), (6, 23), (19, 27), (29, 6)):
        dot(px, x, y, STONE_L)
    return px


def _speckle(px, pts, color, size=1):
    """Rac cac dom nho len tile. Dung modulo de khong bi dut o mep tile."""
    for x, y in pts:
        for dy in range(size):
            for dx in range(size):
                dot(px, (x + dx) % FRAME, (y + dy) % FRAME, color)


def build_dirt():
    """Duong dat 32x32."""
    px = blank(FRAME, FRAME)
    rect(px, 0, 0, 31, 31, DIRT)
    _speckle(px, [(4, 3), (15, 8), (26, 5), (9, 17), (21, 21), (2, 28),
                  (30, 26), (12, 30), (18, 13)], DIRT_D, size=2)
    _speckle(px, [(8, 9), (22, 2), (29, 15), (5, 22), (17, 26), (25, 30),
                  (13, 4), (1, 12)], DIRT_L)
    return px


def build_stone_floor():
    """San da lat 32x32: 4 vien vuong 16x16 xep thang hang (khong so le).

    Co tinh xep thang hang de phan biet voi tile TUONG - tuong xep so le.
    """
    px = blank(FRAME, FRAME)
    rect(px, 0, 0, 31, 31, SLAB)
    for (y0, y1) in ((0, 15), (16, 31)):
        for (x0, x1) in ((0, 15), (16, 31)):
            rect(px, x0, y0, x1, y0, SLAB_L)      # canh tren sang
            rect(px, x0, y1, x1, y1, SLAB_D)      # canh duoi toi
            rect(px, x1, y0, x1, y1, SLAB_D)      # mach doc
    _speckle(px, [(5, 6), (21, 9), (10, 24), (26, 20)], SLAB_D)
    return px


def build_wood_floor():
    """San go 32x32: 4 tam van ngang, moi tam cao 8px, moi noi le nhau."""
    px = blank(FRAME, FRAME)
    rect(px, 0, 0, 31, 31, WOOD)
    for i, y0 in enumerate((0, 8, 16, 24)):
        y1 = y0 + 7
        rect(px, 0, y0, 31, y0, WOOD_L)           # canh tren tam van
        rect(px, 0, y1, 31, y1, WOOD_D)           # khe giua hai tam
        seam = (i * 11 + 5) % 32                  # moi noi le nhau tung tam
        rect(px, seam, y0, seam, y1 - 1, WOOD_D)
        rect(px, (seam + 9) % 32, y0 + 3, (seam + 14) % 32, y0 + 3, WOOD_D)  # van go
    return px


def build_water():
    """Nuoc 32x32. Tile nay CO va cham - nguoi choi khong loi qua duoc."""
    px = blank(FRAME, FRAME)
    rect(px, 0, 0, 31, 31, WATER)
    for (x, y, w) in ((3, 4, 6), (18, 7, 5), (26, 13, 4), (8, 16, 7),
                      (21, 22, 6), (2, 27, 5), (14, 29, 4)):
        for i in range(w):
            dot(px, (x + i) % 32, y, WATER_L)
            dot(px, (x + i) % 32, (y + 1) % 32, WATER_D)
    _speckle(px, [(12, 11), (29, 20), (6, 24)], WATER_L)
    return px


def build_cave_floor():
    """San hang 32x32: da vun toi mau."""
    px = blank(FRAME, FRAME)
    rect(px, 0, 0, 31, 31, CAVE)
    _speckle(px, [(6, 5), (19, 3), (27, 11), (3, 15), (14, 18), (24, 24),
                  (10, 28), (30, 30), (17, 9)], CAVE_D, size=2)
    _speckle(px, [(11, 7), (22, 16), (5, 26), (28, 5), (16, 23)], CAVE_L)
    return px


def build_cave_wall():
    """Vach hang 32x32: khoi da tho, khong theo hang loi nhu tuong xay."""
    px = blank(FRAME, FRAME)
    rect(px, 0, 0, 31, 31, CAVEW)
    # Vai khoi da to, canh tren sang canh duoi toi cho ra khoi.
    for (x0, y0, x1, y1) in ((0, 0, 13, 10), (14, 0, 31, 13),
                             (0, 11, 10, 22), (11, 14, 31, 24),
                             (0, 23, 16, 31), (17, 25, 31, 31)):
        rect(px, x0, y0, x1, y0, CAVEW_L)
        rect(px, x0, y1, x1, y1, CAVEW_D)
        rect(px, x1, y0, x1, y1, CAVEW_D)
    _speckle(px, [(5, 4), (20, 6), (25, 18), (7, 27)], CAVEW_D)
    return px


# ------------------------------------------------- tile Aster sau dem chay
#
# Aster trong demo la ngoi lang VUA CHAY. Nhung tile duoi day dung de ve no.
# Tat ca deu lien mach khi lap lai, va deu tranh nhet vat the de nhan ra vao
# tile nen (xem chu thich o build_floor).

def build_ash():
    """Tro tan 32x32 - phu nhung cho nha da chay rui."""
    px = blank(FRAME, FRAME)
    rect(px, 0, 0, 31, 31, ASH)
    _speckle(px, [(3, 6), (14, 2), (25, 9), (8, 18), (20, 15), (29, 22),
                  (5, 27), (17, 29), (11, 12)], ASH_D, size=2)
    _speckle(px, [(9, 4), (21, 7), (2, 14), (27, 17), (15, 22), (6, 31),
                  (31, 3), (13, 25)], ASH_L)
    _speckle(px, [(19, 5), (7, 21), (26, 28)], CHAR_D)   # vai manh than con lai
    return px


def build_burnt_grass():
    """Co chay kho 32x32 - vanh ngoai khu chay, vai bui co con song."""
    px = blank(FRAME, FRAME)
    rect(px, 0, 0, 31, 31, BGRASS)
    _speckle(px, [(4, 3), (16, 9), (27, 6), (9, 16), (21, 20), (2, 26),
                  (30, 29), (13, 30), (24, 13)], BGRASS_D, size=2)
    _speckle(px, [(11, 5), (23, 3), (6, 11), (29, 18), (17, 24), (3, 20)], BGRASS_L)
    _speckle(px, [(8, 8), (25, 25), (18, 14)], CHAR_D)   # vet chay den
    _speckle(px, [(14, 18), (28, 10)], GRASS_D)          # co con song sot
    return px


def build_burnt_wood_floor():
    """San go da chay 32x32 - van con nhan ra la san nha, nhung den thui."""
    px = blank(FRAME, FRAME)
    rect(px, 0, 0, 31, 31, CHAR)

    # Chi ke duong ngang cho ra tam van. KHONG ke duong doc: them mach doc la
    # tile bien thanh tuong gach ngay, khong con doc ra la san go nua.
    for y0 in (0, 8, 16, 24):
        rect(px, 0, y0, 31, y0, CHAR_L)          # canh tren tam van
        rect(px, 0, y0 + 7, 31, y0 + 7, CHAR_D)  # khe giua hai tam

    # Vet nut chay doc theo tho go - ngan, nam trong long tam van.
    for (x, y, w) in ((4, 3, 9), (18, 11, 7), (9, 19, 11), (23, 27, 6),
                      (28, 4, 4), (13, 12, 5)):
        for i in range(w):
            dot(px, (x + i) % 32, y, CHAR_D)

    # Vai cho than con do am.
    _speckle(px, [(7, 5), (21, 21), (15, 29)], CHAR_L)
    return px


def build_debris_road():
    """Duong dat day manh vo 32x32 - go chay, da, do dac cua dan lang."""
    px = blank(FRAME, FRAME)
    rect(px, 0, 0, 31, 31, DIRT)
    _speckle(px, [(5, 4), (18, 11), (28, 7), (10, 21), (23, 26), (2, 29)],
             DIRT_D, size=2)
    # Manh go chay: nhung thanh ngan nam ngang.
    for (x, y, w) in ((3, 9, 7), (20, 17, 6), (11, 28, 5), (25, 2, 5)):
        for i in range(w):
            dot(px, (x + i) % 32, y, CHAR)
            dot(px, (x + i) % 32, (y + 1) % 32, CHAR_D)
    # Da va do vo. Dung bang mau ASH (xam am) chu khong dung STONE_L - xam
    # lanh cua STONE_L noi len xanh lo giua nen nau, nhin ra ngay la lac mau.
    _speckle(px, [(15, 6), (7, 24), (29, 14)], ASH_D, size=2)
    _speckle(px, [(16, 6), (8, 24), (12, 15), (26, 22)], ASH_L)
    return px


def build_charred_beam():
    """Dong go chay do sap 32x32. Tile nay CHAN DUONG.

    Dung cho khung nha da sap. Cac thanh dam keo het chieu rong/cao nen khi
    lap lai chung noi lien thanh mot dong do nat lien mach.
    """
    px = blank(FRAME, FRAME)
    rect(px, 0, 0, 31, 31, ASH_D)
    for y0 in (6, 20):                            # hai dam ngang
        rect(px, 0, y0, 31, y0 + 4, CHAR)
        rect(px, 0, y0, 31, y0, CHAR_L)
        rect(px, 0, y0 + 4, 31, y0 + 4, CHAR_D)
    rect(px, 12, 0, 16, 31, CHAR)                 # mot dam doc de len
    rect(px, 12, 0, 12, 31, CHAR_L)
    rect(px, 16, 0, 16, 31, CHAR_D)
    _speckle(px, [(4, 14), (24, 27), (8, 2)], ASH_L)
    return px


def build_tree_canopy():
    """Tan cay ram 32x32. Tile nay CHAN DUONG - dung lam bia rung."""
    px = blank(FRAME, FRAME)
    rect(px, 0, 0, 31, 31, LEAF)
    # Nhung cum la: dam toi lam chieu sau, dam sang lam anh nang.
    for (x, y) in ((3, 5), (17, 2), (26, 11), (8, 15), (21, 22), (1, 25),
                   (30, 28), (13, 29), (11, 8)):
        for dy in range(3):
            for dx in range(4):
                dot(px, (x + dx) % 32, (y + dy) % 32, LEAF_D)
    for (x, y) in ((7, 3), (22, 7), (2, 12), (28, 19), (15, 17), (10, 25),
                   (25, 30), (19, 12)):
        for dx in range(2):
            dot(px, (x + dx) % 32, y, LEAF_L)
    return px


def build_graveyard_dirt():
    """Dat nghia trang 32x32 - dat nen chat, co thua."""
    px = blank(FRAME, FRAME)
    rect(px, 0, 0, 31, 31, GDIRT)
    _speckle(px, [(4, 7), (15, 3), (26, 12), (9, 19), (22, 24), (2, 28),
                  (30, 20), (18, 30)], GDIRT_D, size=2)
    _speckle(px, [(11, 9), (24, 5), (6, 16), (29, 26), (16, 21)], GDIRT_L)
    _speckle(px, [(13, 13), (27, 31), (5, 23)], BGRASS_D)   # bui co thua
    return px


def build_gravel():
    """Soi da vun 32x32 - loi di trong nghia trang, quanh gieng."""
    px = blank(FRAME, FRAME)
    rect(px, 0, 0, 31, 31, STONE)
    _speckle(px, [(3, 3), (12, 7), (21, 2), (28, 9), (6, 13), (17, 16),
                  (25, 20), (2, 22), (14, 26), (30, 29), (9, 30), (19, 11)],
             STONE_D, size=2)
    _speckle(px, [(8, 5), (23, 13), (4, 18), (16, 4), (27, 25), (11, 22),
                  (31, 15), (20, 30)], STONE_L)
    return px


# ---------------------------------------------------------------- atlas tile
#
# TAT CA tile nam chung trong MOT file anh goi la "atlas". TileSet cua Godot
# cat file nay thanh luoi 32x32 va danh so o theo toa do (cot, hang).
#
# Toa do nay PHAI khop voi file assets/tiles/terrain.tres. Doi thu tu o day
# ma quen sua ben do la ban do se hien sai tile.
ATLAS_COLS = 4
ATLAS_ROWS = 4
ATLAS = [
    # (cot, hang, ten, ham ve, co va cham khong)
    # --- hang 0-1: lang binh thuong + hang dong ---
    (0, 0, "co",             build_floor,           False),
    (1, 0, "duong dat",      build_dirt,            False),
    (2, 0, "san da",         build_stone_floor,     False),
    (3, 0, "san go",         build_wood_floor,      False),
    (0, 1, "nuoc",           build_water,           True),
    (1, 1, "tuong da",       build_wall,            True),
    (2, 1, "san hang",       build_cave_floor,      False),
    (3, 1, "vach hang",      build_cave_wall,       True),
    # --- hang 2-3: Aster sau dem chay ---
    (0, 2, "tro tan",        build_ash,             False),
    (1, 2, "co chay",        build_burnt_grass,     False),
    (2, 2, "san go chay",    build_burnt_wood_floor, False),
    (3, 2, "duong manh vo",  build_debris_road,     False),
    (0, 3, "go chay do sap", build_charred_beam,    True),
    (1, 3, "tan cay",        build_tree_canopy,     True),
    (2, 3, "dat nghia trang", build_graveyard_dirt, False),
    (3, 3, "soi da",         build_gravel,          False),
]


def build_terrain_atlas():
    atlas = blank(FRAME * ATLAS_COLS, FRAME * ATLAS_ROWS)
    for (cx, cy, _name, fn, _solid) in ATLAS:
        tile = fn()
        for y in range(FRAME):
            for x in range(FRAME):
                atlas[cy * FRAME + y][cx * FRAME + x] = tile[y][x]
    return atlas


# ---------------------------------------------------------------- main
SPRITES = "assets/sprites"
TILES = "assets/tiles"


def main():
    print("Dang tao art placeholder (luoi 32x32, sprite phan lop)...")

    layers = {
        # Nhan vat chinh la Kael (nam). Muon them ban nu thi bo dau ; o dong duoi.
        # f"{SPRITES}/body_female.png":  lambda d, f: layer_body(d, f, female=True),
        f"{SPRITES}/body_male.png":      lambda d, f: layer_body(d, f, female=False),
        f"{SPRITES}/outfit_cloth.png":   lambda d, f: layer_outfit(d, f, OUTFIT_CLOTH),
        f"{SPRITES}/outfit_leather.png": lambda d, f: layer_outfit(d, f, OUTFIT_LEATHER),
        f"{SPRITES}/helmet_iron.png":    lambda d, f: layer_helmet(d, f, HELMET_IRON),
        f"{SPRITES}/weapon_sword.png":   lambda d, f: layer_weapon(d, f, WEAPON_SWORD, "sword"),
        f"{SPRITES}/weapon_bow.png":     lambda d, f: layer_weapon(d, f, WEAPON_BOW, "bow"),
    }
    for rel, fn in layers.items():
        write_png(os.path.join(HERE, *rel.split("/")), FRAME * 4, FRAME * 4, build_sheet(fn))

    write_png(os.path.join(HERE, *f"{TILES}/terrain.png".split("/")),
              FRAME * ATLAS_COLS, FRAME * ATLAS_ROWS, build_terrain_atlas())
    print("   (atlas: " + ", ".join("%d:%d %s" % (c, r, n) for c, r, n, _f, _s in ATLAS) + ")")
    print("Xong.")


if __name__ == "__main__":
    main()
