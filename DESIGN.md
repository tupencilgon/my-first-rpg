# Thiết kế — bản demo

> Tài liệu này chốt những gì **ràng buộc art và code**. Nó cố tình ngắn.
> Cốt truyện đầy đủ nằm ở `docs/cot-truyen/`.

---

## 1. Nhân vật và bối cảnh

| | |
|---|---|
| Nhân vật chính | **Kael**, nam, thiếu niên |
| Mẹ | **Elara** — mất tích |
| Em trai | chưa đặt tên — mất tích |
| Làng | **Aster**, rừng phía nam, có tiệm rèn, quán trọ, nghĩa trang, hầm mỏ phía đông |
| Bối cảnh art | trung cổ, làng quê miền núi |

**Kael là cố định, không cho chọn nam/nữ.** Cốt truyện viết cho một nhân vật
nam cụ thể, dùng "cậu" xuyên suốt — cho chọn giới tính nghĩa là viết lại toàn bộ
hội thoại. Lớp `body_female` đã gỡ; code sinh art vẫn giữ (một dòng trong
`tools/gen_placeholder_art.py`) nếu sau này muốn bật lại.

---

## 2. Phạm vi demo — mục 2 + 3 + 5 của Chương 0

Demo **không phải cả Chương 0**. Chương 0 như đã viết cần hệ thống ngày/thời
gian, NPC đổi vị trí theo quest, hội thoại điều kiện, làng xây lại qua nhiều
trạng thái, dungeon có boss — với người mới lập trình là 1,5–3 năm.

Demo là một lát mỏng, **không có chiến đấu**, khoảng **15 phút**:

| # | Cảnh | Người chơi làm gì |
|---|---|---|
| 1 | Kael tỉnh dậy bên suối cạn | Màn hình đen → chữ → hiện ra, đứng dậy |
| 2 | Đường rừng về làng | Đi bộ, đoạn ngắn |
| 3 | Aster đã cháy | Đi qua làng, thấy dân làng ngồi im |
| 4 | Về nhà mình | Tương tác đống đổ nát → nhặt **khăn của mẹ** và **đồ chơi gỗ của em** |
| 5 | Hỏi dân làng | 3 NPC, hội thoại ngắn, không ai biết gì |
| 6 | Gặp **Edren** | Hội thoại dài, người chơi chọn 2–3 câu trả lời |
| 7 | "Ngày hôm sau" | Màn hình đen chuyển cảnh |
| 8 | Quay lại chỗ Edren | Chỉ còn **chiếc ghế trống** |
| 9 | Nghĩa trang | Đọc bia mộ Edren + vợ + 2 con → Kael: *"Giá như cháu biết phải nói gì với chú."* |
| 10 | Hết demo | Màn hình đen + chữ dẫn sang Chương I |

**Vì sao chọn đúng mấy cảnh này:** đây là phần cảm động nhất của Chương 0, và
nó tự đủ — có mở, có đóng. Ai chơi xong mà muốn biết chuyện gì tiếp theo thì
demo đã làm xong việc của nó.

**Chưa có trong demo** (ghi ra để khỏi làm sớm): chiến đấu, quái, máu, hầm mỏ,
Mara, hệ thống ngày, làng xây lại, quest thu thập, rèn/nâng cấp, trang bị đổi
được, Chương I trở đi.

---

## 3. Hệ thống cần code

| # | Hệ thống | Trạng thái |
|---|---|---|
| 1 | Di chuyển 4 hướng + va chạm | ✅ xong |
| 2 | Sprite phân lớp | ✅ xong |
| 3 | TileSet + TileMapLayer | ✅ xong |
| 4 | Vùng tương tác (`Area2D`) + phím tương tác | chưa |
| 5 | Hộp thoại (chữ hiện dần, bấm để tiếp) | chưa |
| 6 | Hội thoại có lựa chọn | chưa |
| 7 | Nhặt đồ + xem lại vật phẩm | chưa |
| 8 | Cờ trạng thái game (đã gặp Edren chưa, đang ngày mấy) | chưa |
| 9 | Chuyển cảnh + màn hình đen + chữ | chưa |
| 10 | Menu chính, lưu/tải | chưa |
| 11 | Âm thanh | chưa |
| 12 | Export PC + Android | chưa |

Không có hệ nào trong số này là khó. Cái khó là **làm cho xong cả 12 cái**.

---

## 4. Sprite phân lớp — ✅ ĐÃ DỰNG XONG

Nhân vật là **4 Sprite2D chồng lên nhau**, dùng chung một chỉ số frame:

```
Player (CharacterBody2D)
├─ Body     ← thân thể: da, tóc, mặt. Lớp duy nhất có VIỀN.
├─ Outfit   ← bộ đồ = giáp + quần gộp làm một
├─ Helmet   ← mũ
└─ Weapon   ← vũ khí, ẩn trong demo (để dành cho bản có chiến đấu)
```

Mỗi lớp là PNG **128×128, bố cục 4×4**, phần trống để trong suốt.
`player.gd` gán cùng một `frame` cho cả bốn lớp — xem `_apply_frame()`.

### NPC dùng lại chính hệ thống này

Đây là chỗ kiến trúc trả công lần thứ hai: **một NPC = Body có sẵn + một lớp
Outfit màu khác**. Năm dân làng không cần năm nhân vật mới, chỉ cần năm bộ đồ
khác màu — mà đổi màu một bộ đồ thì gần như miễn phí.

### Ràng buộc bắt buộc

1. Mọi lớp **cùng 128×128, cùng bố cục 4×4**
2. Mọi lớp dùng chung toạ độ trong `GEOM` (`tools/gen_placeholder_art.py`) —
   lệch một pixel là quần áo lệch khỏi người

### Phím tạm để thử

`1` đổi bộ đồ · `2` bật/tắt mũ · `3` đổi kiếm/cung · `4` rút/cất vũ khí

---

## 5. Art cần cho demo

### Đã có
Kael (body + 2 bộ đồ + mũ), 8 tile nền (cỏ, đường đất, sàn đá, sàn gỗ, nước,
tường đá, sàn hang, vách hang).

### Còn thiếu

| Hạng mục | Ước tính |
|---|---|
| Bộ đồ "quần áo cháy xém" cho Kael | 16 |
| 5 NPC = 5 bộ đồ khác màu (dùng lại Body) | 80 |
| Tile làng cháy (nhà cháy đen, tro, gỗ cháy, đường đầy mảnh vỡ) | ~15 |
| Tile nghĩa trang + rừng + suối | ~12 |
| Vật thể (đống đổ nát, ghế trống, bia mộ, khăn, đồ chơi gỗ) | ~10 |
| Khung hội thoại + icon vật phẩm | ~8 |
| | **~140** |

Ít hơn nhiều so với bản có chiến đấu (~560) vì bỏ được toàn bộ animation tấn
công, bị đánh, chết, và toàn bộ quái.

### Dùng AI để vẽ

**Map thì KHÔNG convert được.** Bản đồ không phải ảnh — nó là dữ liệu "ô (12,7)
dùng tem số 3". AI cho bạn một bức tranh; trong tranh không tồn tại khái niệm
"ô". Dùng AI vẽ **concept Aster sau đêm cháy** rồi nhìn đó mà dán tem.

**Asset thì được, nhưng qua xử lý.** Quy trình:

1. AI tạo ảnh concept
2. Chạy `python tools/check_asset.py <ảnh>` để biết ảnh sai chỗ nào
3. Mở Aseprite, đặt ảnh AI làm **lớp tham chiếu mờ** phía dưới
4. Vẽ đè lên trên lưới 32×32 thật
5. Xoá lớp tham chiếu

Ngoại lệ dùng được gần như trực tiếp: **icon vật phẩm tĩnh** và **tile nền** —
chúng không cần nhất quán qua nhiều frame.

---

## 6. Bộ tile hiện có

Tất cả tile nằm chung trong **một** file `assets/tiles/terrain.png` (*atlas*),
được `assets/tiles/terrain.tres` (TileSet) cắt thành lưới 32×32.

| Toạ độ | Tile | Chặn đường? |
|---|---|---|
| 0:0 | Cỏ | Không |
| 1:0 | Đường đất | Không |
| 2:0 | Sàn đá lát | Không |
| 3:0 | Sàn gỗ | Không |
| 0:1 | Nước | **Có** |
| 1:1 | Tường đá | **Có** |
| 2:1 | Sàn hang | Không |
| 3:1 | Vách hang | **Có** |

Thêm tile mới: thêm một dòng vào biến `ATLAS` trong
`tools/gen_placeholder_art.py`, chạy lại script, rồi khai báo ô mới trong
`terrain.tres` (hoặc qua giao diện TileSet của Godot).

---

## 7. Thứ tự làm

1. ~~Sprite phân lớp~~ ✅
2. ~~TileSet + TileMapLayer~~ ✅
3. ~~Công cụ kiểm tra asset AI~~ ✅
4. **Tile làng cháy** — cần trước khi vẽ được Aster
5. **Vẽ bản đồ Aster** ← việc của bạn trong editor
6. Vùng tương tác + phím tương tác
7. Hộp thoại
8. Hội thoại có lựa chọn
9. NPC (dùng lại sprite phân lớp)
10. Nhặt đồ
11. Cờ trạng thái + chuyển ngày
12. Nghĩa trang + bia mộ
13. Menu chính, lưu/tải, âm thanh
14. Export PC + Android

---

## 8. Nguyên tắc

- Mỗi bước phải **chạy thử được ngay**, đừng ôm việc lớn
- **Gameplay trước art** — art đẹp không cứu được game chưa chạy
- Ý tưởng mới → ghi vào mục 2 (phần "chưa có"), đừng làm ngay
- Game đầu tay nên **nhỏ đến mức buồn cười**. Mục tiêu là *hoàn thành*.
