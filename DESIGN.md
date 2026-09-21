# Thiết kế game — bản demo

> Tài liệu này chốt những gì **ràng buộc art và code**. Nó cố tình ngắn.
> Mọi thứ không ảnh hưởng tới art hay code thì chưa cần quyết định.

---

## 1. Câu chuyện

> Sau một đêm ngôi làng bị tấn công, mẹ và em trai mất tích. Nhân vật chính
> lên đường tìm tung tích họ. Manh mối đầu tiên dẫn xuống hầm mỏ dưới làng.

Bối cảnh: **trung cổ, làng quê miền núi**. Đó là tất cả những gì art cần biết.

Người chơi chọn **bản nam hoặc nữ** ở đầu game.

---

## 2. Hai giai đoạn — QUAN TRỌNG

Bản đầu tiên **không có chiến đấu**. Đây là quyết định tốt và tài liệu này
được sắp xếp lại quanh nó.

### Bản 1 — Khám phá, không chiến đấu

Người chơi đi lại trong làng, nói chuyện với dân làng, nhặt đồ, và xuống hầm
mỏ tìm manh mối. Không có quái, không có máu, không có vũ khí.

**Core loop:**

```
Khám phá  →  tìm manh mối / vật phẩm  →  nói chuyện với NPC
    ↑                                            ↓
    └────────  mở ra khu vực mới  ←──────────────┘
```

**Vì sao nên làm bản này trước:**
- Cắt khoảng **57% khối lượng art** (xem mục 5)
- Không phải cân bằng độ khó — phần khó nhất của thiết kế game
- Vẫn học đủ: TileMap, va chạm, NPC, hội thoại, nhặt đồ, lưu game, menu, export
- **Vẫn là một game hoàn chỉnh chơi được** — có thể phát hành ngay

### Bản 2 — Thêm chiến đấu

Chỉ bắt đầu sau khi bản 1 chạy trọn vẹn từ menu chính tới màn hình kết thúc.
Khi đó thêm: quái, máu, sát thương, chém cận chiến, rồi cuối cùng mới là cung.

---

## 3. Danh sách động từ

| Động từ | Bản | Cần animation? |
|---|---|---|
| Đi bộ 4 hướng | 1 | ✅ Đã xong |
| Đứng yên | 1 | Tái dùng frame 0 |
| Nói chuyện NPC | 1 | Không — chỉ hiện hộp thoại |
| Nhặt đồ | 1 | Không — chạm vào là nhặt |
| Mở rương / cửa | 1 | Animation của vật, không phải nhân vật |
| Chém cận chiến | 2 | Có, 4 hướng |
| Bị đánh | 2 | Có, 4 hướng |
| Chết | 2 | Có |
| Giương cung bắn | 2 | Có — **khác hẳn động tác chém** |

---

## 4. Sprite phân lớp — ✅ ĐÃ DỰNG XONG

Nhân vật là **4 Sprite2D chồng lên nhau**, tất cả dùng chung một chỉ số frame:

```
Player (CharacterBody2D)
├─ Body     ← thân thể: da, tóc, mặt. Lớp duy nhất có VIỀN.
├─ Outfit   ← bộ đồ = giáp + quần (đã chốt gộp làm một)
├─ Helmet   ← mũ
└─ Weapon   ← vũ khí, chỉ hiện khi chiến đấu (để dành cho bản 2)
```

Mỗi lớp là một PNG **128×128, bố cục 4×4**, phần trống để trong suốt.
`player.gd` gán cùng một `frame` cho cả bốn lớp — xem `_apply_frame()`.

Chi phí art là **phép cộng** chứ không phải phép nhân: 3 bộ đồ + 3 mũ = 6 file
nhưng ra 9 vẻ ngoài.

### Ràng buộc bắt buộc

1. Mọi lớp **cùng 128×128, cùng bố cục 4×4**.
2. Mọi lớp dùng chung toạ độ trong `GEOM` (`tools/gen_placeholder_art.py`).
   Lệch một pixel là quần áo lệch khỏi người.
3. **Bản nam và bản nữ phải cùng dáng người.** Chỉ khác tóc và mặt.

Ý số 3 là ràng buộc đắt nhất trong tài liệu này. Nếu hai dáng khác nhau, **mọi
bộ đồ và mọi cái mũ phải vẽ hai lần**, vĩnh viễn.

### Phím tạm để thử (sẽ bỏ khi có menu trang bị thật)

`1` nam/nữ · `2` bộ đồ · `3` mũ · `4` kiếm/cung · `5` rút/cất vũ khí

---

## 5. Bảng kê art

### Bản 1 — không chiến đấu

| Hạng mục | Frame |
|---|---|
| Body nam + nữ (chỉ cần đi bộ: 16 frame mỗi bản) | 32 |
| Outfit × 2 bộ (dùng chung nam/nữ) | 32 |
| Helmet × 2 (dùng chung) | 32 |
| 4 NPC (đứng + đi chậm) | 32 |
| Tile làng (nhà, mái, hàng rào, cây, giếng...) | ~40 |
| Tile hầm mỏ (đá, quặng, gỗ chống, đuốc) | ~25 |
| Vật thể (rương, thùng, biển hiệu, cửa) | ~30 |
| Icon UI (vật phẩm, nút, khung hội thoại) | ~15 |
| | **~240** |

### Bản 2 — thêm chiến đấu

| Hạng mục | Frame |
|---|---|
| Body: chém + bị đánh + chết (×2 bản) | 60 |
| Outfit + Helmet cho các animation mới | 120 |
| Bắn cung (×2 bản) + cung + mũi tên | 76 |
| 3 loại quái | ~90 |
| | **+320** |

**Tổng nếu làm cả hai: ~560.** Bỏ chiến đấu khỏi bản đầu cắt được **57%**.

### Về việc dùng AI để vẽ

AI đẩy nhanh được **concept, tile nền, và icon vật phẩm tĩnh** — những thứ
không đòi hỏi nhất quán giữa các frame.

Chỗ AI yếu đúng vào chỗ dự án này cần nhất: **các frame animation liên tiếp
phải nhất quán từng pixel, và bốn lớp phải khớp nhau tuyệt đối.** Ảnh AI thường
chỉ *trông giống* pixel art — viền bị khử răng cưa, kích thước pixel không đều,
bảng màu trôi giữa các lần tạo.

Cách dùng thực tế: **AI ra concept → vẽ lại trên lưới thật trong Aseprite.**

---

## 6. Bộ tile hiện có

Tất cả tile nằm chung trong **một** file `assets/tiles/terrain.png` (gọi là
*atlas*), được `assets/tiles/terrain.tres` (TileSet) cắt thành lưới 32×32.

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

## 7. Phạm vi demo

**Bản 1 có:**
- 1 ngôi làng (4 NPC, vài ngôi nhà vào được)
- 1 hầm mỏ để khám phá
- Hội thoại với NPC
- Nhặt và xem vật phẩm
- Lưu/tải game, menu chính
- Nhân vật nam/nữ, trang bị nhìn thấy được

**Chưa có** (ghi ra để khỏi quên, và để khỏi làm sớm):
- Chiến đấu, quái vật, máu — để bản 2
- Cung và mũi tên — để cuối bản 2
- Các khu vực tiếp theo của hành trình
- Nhiệm vụ phụ, chế tạo, ngày/đêm, thời tiết

> Mỗi khi nảy ra ý tưởng mới, ghi vào mục này chứ đừng làm ngay.

---

## 8. Thứ tự làm

**Bản 1:**

1. ~~Hệ thống sprite phân lớp~~ ✅
2. ~~TileSet + TileMapLayer + bản đồ khởi đầu~~ ✅
3. **Vẽ ngôi làng cho ra hồn** ← *đang ở đây, việc của bạn trong editor*
4. Y-sort — để nhân vật đi được ra sau nhà và cây
5. Chuyển đổi cảnh (đi từ làng xuống hầm mỏ và ngược lại)
6. NPC + hộp thoại
7. Nhặt đồ + túi đồ
8. Menu trang bị thật (thay 5 phím tạm ở mục 4)
9. Lưu/tải, menu chính, âm thanh
10. Export PC + Android

**Bản 2:** state machine chiến đấu → quái → máu/sát thương → chém → cung.
