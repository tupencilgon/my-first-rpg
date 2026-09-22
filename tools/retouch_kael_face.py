"""
Cham lai pixel khuon mat Kael tren sprite sheet co san.

CHAY
    python tools/retouch_kael_face.py

    Doc:  assets/sprites/kael_v02/kael_walk_v02.png
    Ghi:  assets/sprites/kael_v03/kael_walk_v03.png

VAN DE DANG SUA

Sprite goc CO mat, nhung moi mat chi rong 1 pixel va dung dung mau viền
(#160f0c). O co game (1 pixel = 3 pixel man hinh) chung dinh vao bong toc
va khuon mat doc ra nhu trong khong.

CACH SUA
    1. Noi rong moi mat tu 1 pixel thanh 2 pixel, no ve phia GIUA mat.
       Nho vay chua khoang da o hai ben - mat tach khoi mep toc.
    2. Them mieng 2 pixel o hang duoi mat (chi cho huong XUONG).

VI SAO KHONG LAM TU DONG BANG "THU NHO ANH REF"

Thu nho mot anh 1254x1254 ve 32x32 khong bao gio ra mat, vi o co 32px thi
mat chi con 2 pixel - phai QUYET DINH dat 2 pixel do o dau, khong phai tinh
trung binh mau. Do la viec doc hieu hinh, khong phai viec resample.

Script nay tim mat theo DAU HIEU HINH HOC thay vi toa do viet cung: mot pixel
toi ma hai ben trai/phai deu la mau da thi gan nhu chac chan la con mat. Nho
vay no chay dung cho ca 16 frame du dau nhan vat xe dich giua cac frame.
"""

import os
import sys

HERE = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0, os.path.join(HERE, "tools"))

from gen_placeholder_art import write_png
from check_asset import read_png

SRC = os.path.join(HERE, "assets", "sprites", "kael_v02", "kael_walk_v02.png")
DST = os.path.join(HERE, "assets", "sprites", "kael_v03", "kael_walk_v03.png")

FRAME = 32
ROW_DOWN, ROW_UP, ROW_LEFT, ROW_RIGHT = 0, 1, 2, 3

# Bang mau da cua sprite goc (sang -> toi).
SKIN = {
    (255, 196, 151, 255),
    (232, 165, 117, 255),
    (207, 143, 96, 255),
    (176, 119, 81, 255),
}

# Mau dung ve mat: chinh la mau viền cua sprite goc, giu nguyen cho dong bo.
EYE = (22, 15, 12, 255)

# Mieng: sac do nau tram. Sang hon mot chut la no thanh diem nhan giua mat,
# hut het chu y khoi doi mat.
MOUTH = (120, 68, 62, 255)


def is_skin(p):
    return p in SKIN


def is_dark(p):
    return p[3] != 0 and (p[0] + p[1] + p[2]) < 140


# Vung co the chua khuon mat. Ngoai khoang nay thi khong xet - de tranh bat
# nham khe giua hai ban tay (nam quanh hang 21-23) lam con mat.
FACE_ROWS = range(10, 19)

# Mot con mat cao it nhat 2 pixel. Pixel toi le loi chi cao 1 pixel thuong la
# mep toc choc vao mat hoac song mui, khong phai mat.
MIN_EYE_HEIGHT = 2


def find_eye_columns(frame):
    """Tim cac COT chua con mat.

    Dau hieu cua mot con mat:
      - pixel toi, hai ben trai/phai deu la mau da
      - nam trong vung mat (FACE_ROWS)
      - xep thanh cot lien tuc cao >= 2 pixel

    Tra ve dict {cot: [cac hang]}.
    """
    hits = {}
    for y in FACE_ROWS:
        for x in range(1, FRAME - 1):
            if not is_dark(frame[y][x]):
                continue
            if is_skin(frame[y][x - 1]) and is_skin(frame[y][x + 1]):
                hits.setdefault(x, []).append(y)

    cols = {}
    for x, ys in hits.items():
        ys.sort()
        # Tach thanh cac doan lien tuc, giu doan dai nhat.
        best, run = [], [ys[0]]
        for prev, cur in zip(ys, ys[1:]):
            if cur == prev + 1:
                run.append(cur)
            else:
                if len(run) > len(best):
                    best = run
                run = [cur]
        if len(run) > len(best):
            best = run
        if len(best) >= MIN_EYE_HEIGHT:
            cols[x] = best
    return cols


def retouch(frame, row_index):
    """Tra ve (frame moi, so mat tim duoc)."""
    out = [list(r) for r in frame]

    # Huong LEN la nhin tu sau dau - khong co mat. Bo qua han cho chac.
    if row_index == ROW_UP:
        return out, 0

    cols = find_eye_columns(frame)
    if not cols:
        return out, 0

    xs = sorted(cols)
    centre = sum(xs) / float(len(xs))

    for x in xs:
        ys = cols[x]
        if row_index == ROW_LEFT:
            step = -1            # mat huong sang trai -> no ve phia truoc mat
        elif row_index == ROW_RIGHT:
            step = 1
        else:
            # Nhin chinh dien: no ve phia GIUA mat, de chua khoang da o hai ben
            # cho mat tach khoi mep toc.
            step = 1 if x < centre else -1
        nx = x + step
        for y in ys:
            if 0 <= nx < FRAME and is_skin(out[y][nx]):
                out[y][nx] = EYE

    # Chi them mieng cho huong nhin chinh dien. Huong nghieng dat mieng rat de
    # sai cho, ma khong co mieng thi cung khong ai thay thieu.
    if row_index == ROW_DOWN and len(xs) >= 2:
        mouth_y = max(max(cols[x]) for x in xs) + 2
        # Mieng rong 2 pixel, dat CAN GIUA hai mat. Voi tam o 15.5 thi hai
        # pixel dung la 15 va 16 -> lay int() (lam tron xuong), khong dung
        # round(): round(15.5) cho ra 16 nen mieng bi lech han sang phai.
        mx = int(centre)
        for dx in (0, 1):
            if 0 <= mouth_y < FRAME and is_skin(out[mouth_y][mx + dx]):
                out[mouth_y][mx + dx] = MOUTH

    return out, len(xs)


def main():
    w, h, px = read_png(SRC)
    if (w, h) != (FRAME * 4, FRAME * 4):
        print("Kich thuoc la, mong doi 128x128:", w, h)
        sys.exit(1)

    sheet = [[(0, 0, 0, 0) for _ in range(w)] for _ in range(h)]
    names = ["xuong", "len", "trai", "phai"]

    for ry in range(4):
        for cx in range(4):
            frame = [[px[ry * FRAME + y][cx * FRAME + x] for x in range(FRAME)]
                     for y in range(FRAME)]
            new, n = retouch(frame, ry)
            print("  hang %-6s cot %d: tim thay %d con mat" % (names[ry], cx, n))
            for y in range(FRAME):
                for x in range(FRAME):
                    sheet[ry * FRAME + y][cx * FRAME + x] = new[y][x]

    write_png(DST, w, h, sheet)
    used = set()
    for row in sheet:
        for p in row:
            if p[3] != 0:
                used.add(p)
    print("So mau sau khi sua:", len(used))


if __name__ == "__main__":
    main()
