"""
Kiem tra va chuyen doi anh (thuong la do AI tao) thanh asset dung chuan game.

CACH DUNG
    python tools/check_asset.py <anh.png>
        -> chi kiem tra, bao cho biet anh da dung duoc chua

    python tools/check_asset.py <anh.png> --size 32x32
        -> kiem tra roi thu nho ve dung kich thuoc

    python tools/check_asset.py <anh.png> --size 128x128 --key ffffff
        -> them: bien mau trang thanh nen trong suot

    python tools/check_asset.py <anh.png> --size 128x128 --flatten-alpha
        -> them: ep alpha ve nhi phan (0 hoac 255)

    python tools/check_asset.py <anh.png> --size 32x32 -o assets/tiles/da.png
        -> chi dinh noi luu

VI SAO CAN FILE NAY

Anh AI tao ra thuong TRONG GIONG pixel art chu khong PHAI pixel art:
  - to gap nhieu lan (1024x1024 thay vi 32x32)
  - vien bi lam mo (khu rang cua) nen khong co canh sac
  - hang nghin mau thay vi vai chuc
  - nen mau dac thay vi nen trong suot

Script nay noi cho ban biet anh dang sai o dau, va lam ho phan co hoc
(thu nho, bo nen). Phan con lai - ve lai cho sac net - van phai lam tay
trong Aseprite. Khong co cach tu dong nao vuot qua duoc chuyen do.

Script chi doc duoc file PNG. Anh JPG/WEBP thi mo bang Aseprite hoac
Paint roi luu lai thanh PNG truoc.
"""

import os
import struct
import sys
import zlib
from collections import Counter

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from gen_placeholder_art import write_png


# ---------------------------------------------------------------- doc PNG
def read_png(path):
    """Doc file PNG ve dang list[hang][cot] = (r, g, b, a)."""
    data = open(path, "rb").read()
    if data[:8] != b"\x89PNG\r\n\x1a\n":
        raise ValueError("Khong phai file PNG")

    i, idat, width, height, depth, ctype = 8, b"", 0, 0, 8, 6
    while i < len(data):
        length = struct.unpack(">I", data[i:i + 4])[0]
        tag, body = data[i + 4:i + 8], data[i + 8:i + 8 + length]
        if tag == b"IHDR":
            width, height, depth, ctype = struct.unpack(">IIBB", body[:10])
        elif tag == b"IDAT":
            idat += body
        elif tag == b"IEND":
            break
        i += 12 + length

    if depth != 8 or ctype not in (2, 6):
        raise ValueError(
            "Chi ho tro PNG 8-bit mau RGB hoac RGBA (anh nay: depth=%d, type=%d).\n"
            "   Mo bang Aseprite hoac Paint roi luu lai thanh PNG thuong." % (depth, ctype))

    channels = 4 if ctype == 6 else 3
    raw = zlib.decompress(idat)
    stride = width * channels
    rows, prev = [], bytearray(stride)

    # PNG nen tung hang bang mot trong 5 "bo loc" - phai giai nguoc lai.
    for y in range(height):
        f = raw[y * (stride + 1)]
        line = bytearray(raw[y * (stride + 1) + 1:(y + 1) * (stride + 1)])
        for x in range(stride):
            a = line[x - channels] if x >= channels else 0
            b = prev[x]
            c = prev[x - channels] if x >= channels else 0
            if f == 1:
                line[x] = (line[x] + a) & 255
            elif f == 2:
                line[x] = (line[x] + b) & 255
            elif f == 3:
                line[x] = (line[x] + ((a + b) >> 1)) & 255
            elif f == 4:
                p = a + b - c
                pa, pb, pc = abs(p - a), abs(p - b), abs(p - c)
                pr = a if (pa <= pb and pa <= pc) else (b if pb <= pc else c)
                line[x] = (line[x] + pr) & 255
        prev = line
        rows.append([tuple(line[x * channels:x * channels + channels]) + ((255,) if channels == 3 else ())
                     for x in range(width)])
    return width, height, rows


# ---------------------------------------------------------------- phan tich
def _blocks_uniform(px, w, h, n):
    """Anh co chia duoc thanh cac o vuong n x n dong mau khong?"""
    for by in range(0, h, n):
        for bx in range(0, w, n):
            first = px[by][bx]
            for y in range(by, by + n):
                row = px[y]
                for x in range(bx, bx + n):
                    if row[x] != first:
                        return False
    return True


def detect_block_size(px, w, h):
    """Tim kich thuoc 'pixel that' cua anh.

    Mot anh pixel art 32x32 phong to len 512x512 se gom nhung o 16x16 dong
    mau. Neu tim duoc o nhu vay thi thu nho lai KHONG mat gi ca.

    Neu ket qua la 1 nghia la anh khong nam tren luoi nao -> day la anh
    thuong, khong phai pixel art, thu nho se ra mot dong be bet.
    """
    g = 1
    small = min(w, h)
    divisors = [n for n in range(1, small + 1) if w % n == 0 and h % n == 0]
    for n in reversed(divisors):
        if _blocks_uniform(px, w, h, n):
            return n
    return g


# Alpha tu nguong nay tro len thi coi la DAC.
#
# Vi sao khong doi dung 255: nhieu cong cu xuat anh (vi du sprite slicer) tra
# ve alpha 252-253 cho pixel that ra la dac hoan toan. Neu chi nhan 255 thi
# bao cao sai het: "73% pixel mo vien" va "chi co 5 mau" - trong khi anh hoan
# toan binh thuong, chi lech alpha vai don vi.
NEAR_OPAQUE = 250


def analyze(path):
    w, h, px = read_png(path)
    flat = [p for row in px for p in row]

    colors = Counter(flat)
    # Dem mau theo RGB, BO QUA alpha. Neu khong thi cung mot mau nhung alpha
    # 253 va 252 se bi dem thanh hai mau khac nhau.
    opaque = [(p[0], p[1], p[2]) for p in flat if p[3] >= NEAR_OPAQUE]
    semi = sum(1 for p in flat if 0 < p[3] < NEAR_OPAQUE)
    nearly = sum(1 for p in flat if NEAR_OPAQUE <= p[3] < 255)
    clear = sum(1 for p in flat if p[3] == 0)

    # Doan mau nen: mau xuat hien nhieu nhat o vien anh.
    border = [px[0][x] for x in range(w)] + [px[h - 1][x] for x in range(w)] \
        + [px[y][0] for y in range(h)] + [px[y][w - 1] for y in range(h)]
    bg = Counter(border).most_common(1)[0]

    return {
        "path": path, "w": w, "h": h, "px": px,
        "block": detect_block_size(px, w, h),
        "colors": len(colors),
        "opaque_colors": len(set(opaque)),
        "semi": semi, "nearly": nearly, "clear": clear,
        "bg_color": bg[0], "bg_ratio": bg[1] / len(border),
    }


# ---------------------------------------------------------------- bao cao
OK, WARN, BAD = "  [OK]  ", "  [!]   ", "  [SAI] "


def report(a, target=None):
    w, h, block = a["w"], a["h"], a["block"]
    print("\n=== %s ===" % os.path.basename(a["path"]))
    print("%sKich thuoc anh: %dx%d" % (OK, w, h))

    # 1. Luoi pixel
    #
    # block > 1  : anh pixel art bi phong to -> thu nho lai duoc, khong mat gi
    # block == 1 : moi pixel la mot pixel rieng. Hai kha nang:
    #                - anh da o dung do phan giai goc (tot)
    #                - anh muot/anh AI khong nam tren luoi nao (xau)
    #              Phan biet bang kich thuoc va so mau.
    native = block == 1 and max(w, h) <= 256 and a["opaque_colors"] <= 64
    if block > 1:
        print("%sLuoi pixel that: %dx%d (moi 'pixel' to %d don vi)"
              % (OK, w // block, h // block, block))
    elif native:
        print("%sDa o dung do phan giai goc - moi pixel la mot pixel that." % OK)
    else:
        print("%sKHONG nam tren luoi pixel nao." % BAD)
        print("        Anh %dx%d voi %d mau -> day la anh muot, khong phai pixel art."
              % (w, h, a["opaque_colors"]))
        print("        Thu nho se be bet.")
        print("        -> Dung anh nay lam BAN PHAC trong Aseprite roi ve de len.")

    # 2. Vien ban trong suot
    #
    # Phep do nay CHI nhin kenh trong suot (alpha). Anh bi mo mau nhung van
    # dac hoan toan se khong bi bat o day - cai do do muc 1 (luoi pixel) bat.
    if a["semi"] > 0:
        pct = 100.0 * a["semi"] / (w * h)
        tag = WARN if pct < 5 else BAD
        print("%s%d pixel co vien ban trong suot (%.1f%%)." % (tag, a["semi"], pct))
        print("        Pixel art that gan nhu khong co pixel nao nhu vay.")
    elif a["nearly"] > 0:
        print("%s%d pixel co alpha %d-254 thay vi 255." % (WARN, a["nearly"], NEAR_OPAQUE))
        print("        Nhin bang mat thi khong thay, nhung Godot van pha mau voi")
        print("        nen mot chut. Nhieu cong cu xuat anh hay bi loi nay.")
        print("        Chay lai voi  --flatten-alpha  de ep het ve 0 hoac 255.")
    elif block == 1 and not native:
        print("%sKhong co vien ban trong suot - nhung anh van mo mau (xem muc tren)." % WARN)
    else:
        print("%sKhong co vien ban trong suot." % OK)

    # 3. So mau
    n = a["opaque_colors"]
    if n <= 48:
        print("%sSo mau: %d - hop ly cho pixel art." % (OK, n))
    elif n <= 256:
        print("%sSo mau: %d - hoi nhieu, nen gom ve duoi 48 mau." % (WARN, n))
    else:
        print("%sSo mau: %d - qua nhieu." % (BAD, n))
        print("        Dau hieu ro nhat cua anh AI chua xu ly.")

    # 4. Nen trong suot
    #
    # Tile nen (co, da, nuoc) thi dac hoan toan la DUNG. Chi sprite nhan vat,
    # NPC, vat pham moi bat buoc phai co nen trong suot.
    if a["clear"] == 0:
        print("%sKhong co vung trong suot nao." % WARN)
        print("        Dung neu day la TILE NEN. Sai neu la sprite nhan vat/vat pham.")
        r, g, b, _ = a["bg_color"]
        print("        Mau vien pho bien nhat: #%02x%02x%02x (%.0f%% duong vien)."
              % (r, g, b, 100 * a["bg_ratio"]))
        print("        Neu day la nen can bo, chay lai voi:  --key %02x%02x%02x" % (r, g, b))
    else:
        print("%sCo %d pixel trong suot - da tach nen." % (OK, a["clear"]))

    # 5. Kich thuoc dich
    if target:
        tw, th = target
        if (w, h) == (tw, th):
            print("%sDa dung kich thuoc dich %dx%d." % (OK, tw, th))
        elif w % tw == 0 and h % th == 0 and w // tw == h // th:
            f = w // tw
            if block >= f:
                print("%sThu nho %d lan ve %dx%d: KHONG mat gi." % (OK, f, tw, th))
            else:
                print("%sThu nho %d lan ve %dx%d se MAT chi tiet (luoi that chi %dpx)."
                      % (WARN, f, tw, th, block))
        else:
            print("%s%dx%d khong chia chan ve %dx%d." % (BAD, w, h, tw, th))
            print("        Cat hoac phong anh ve boi so nguyen cua %dx%d truoc." % (tw, th))


# ---------------------------------------------------------------- chuyen doi
def convert(a, target, key=None, flatten=False):
    w, h, px = a["w"], a["h"], a["px"]
    tw, th = target

    if (w, h) != (tw, th):
        if w % tw or h % th or w // tw != h // th:
            print("\nKhong chuyen doi duoc: kich thuoc khong chia chan.")
            return None
        f = w // tw
        # Lay pixel goc trai-tren cua moi o. Voi anh pixel art that thi ca o
        # dong mau nen lay o dau cung the; voi anh mo thi day la cach giu
        # duoc mau sac net nhat (khong trung binh -> khong tao mau moi).
        px = [[px[y * f][x * f] for x in range(tw)] for y in range(th)]

    if flatten:
        # Ep alpha ve nhi phan: >=128 thanh dac hoan toan, con lai thanh trong
        # suot hoan toan. Pixel art khong bao gio can gia tri o giua.
        n = 0
        for y in range(th):
            for x in range(tw):
                r, g, b, al = px[y][x]
                if al >= 128:
                    if al != 255:
                        px[y][x] = (r, g, b, 255)
                        n += 1
                elif al != 0:
                    px[y][x] = (0, 0, 0, 0)
                    n += 1
        print("\nDa ep alpha ve nhi phan: sua %d pixel." % n)

    if key is not None:
        n = 0
        for y in range(th):
            for x in range(tw):
                r, g, b, _al = px[y][x]
                if (r, g, b) == key:
                    px[y][x] = (0, 0, 0, 0)
                    n += 1
        print("\nDa bo nen: %d pixel thanh trong suot." % n)

    return px


# ---------------------------------------------------------------- main
def parse_args(argv):
    if not argv:
        print(__doc__)
        sys.exit(1)
    opts = {"path": argv[0], "size": None, "key": None, "out": None, "flatten": False}
    i = 1
    while i < len(argv):
        arg = argv[i]
        if arg == "--size":
            i += 1
            opts["size"] = tuple(int(v) for v in argv[i].lower().split("x"))
        elif arg == "--key":
            i += 1
            v = argv[i].lstrip("#")
            opts["key"] = (int(v[0:2], 16), int(v[2:4], 16), int(v[4:6], 16))
        elif arg == "--flatten-alpha":
            opts["flatten"] = True
        elif arg in ("-o", "--out"):
            i += 1
            opts["out"] = argv[i]
        else:
            print("Khong hieu tham so:", arg)
            sys.exit(1)
        i += 1
    return opts


def main():
    o = parse_args(sys.argv[1:])
    if not os.path.isfile(o["path"]):
        print("Khong tim thay file:", o["path"])
        sys.exit(1)

    try:
        a = analyze(o["path"])
    except ValueError as e:
        print("Loi doc anh:", e)
        sys.exit(1)

    report(a, o["size"])

    if o["size"] is None:
        print("\n(Them --size 32x32 de chuyen doi luon.)")
        return

    # Da dung kich thuoc va khong can bo nen -> khong co gi de lam.
    # Tranh viec ghi ra mot file trung lap khong ai can.
    if (a["w"], a["h"]) == tuple(o["size"]) and o["key"] is None and not o["flatten"]:
        print("\nAnh da dung chuan roi - khong can chuyen doi gi.")
        return

    px = convert(a, o["size"], o["key"], o["flatten"])
    if px is None:
        sys.exit(1)

    out = o["out"]
    if out is None:
        base, _ext = os.path.splitext(o["path"])
        out = "%s_%dx%d.png" % (base, o["size"][0], o["size"][1])
    write_png(out, o["size"][0], o["size"][1], px)
    print("\nDa luu. Mo file nay trong Aseprite de don not phan con lai.")


if __name__ == "__main__":
    main()
