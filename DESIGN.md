# Thiết kế game — bản demo

> Tài liệu này chốt những gì **ràng buộc art và code**. Nó cố tình ngắn.
> Mọi thứ không ảnh hưởng tới art hay code thì chưa cần quyết định.

---

## 1. Câu chuyện

> Sau một đêm ngôi làng bị tấn công, mẹ và em trai mất tích. Nhân vật chính
> lên đường tìm tung tích họ. Manh mối đầu tiên dẫn xuống hầm mỏ dưới làng.

Bối cảnh: **trung cổ, làng quê miền núi**. Đó là tất cả những gì art cần biết
lúc này.

Người chơi chọn **bản nam hoặc nữ** ở đầu game.

**Chưa chốt** (và chưa cần chốt): ai tấn công làng, vì sao, mẹ và em trai giờ ở
đâu, kết thúc ra sao. Những thứ đó không ràng buộc một pixel nào — viết sau.

---

## 2. Core loop — 30 giây lặp đi lặp lại

```
Xuống hang  →  gặp quái  →  đánh (cận chiến / bắn cung)  →  nhặt quặng
     ↑                                                          ↓
     └────  xuống sâu hơn  ←  rèn/nâng trang bị  ←  về làng  ←──┘
```

Đây là phần quan trọng nhất của cả tài liệu. Nếu vòng lặp này chơi không
sướng thì art đẹp cỡ nào cũng không cứu được.

**Cách kiểm tra:** làm vòng lặp này bằng hình vuông màu trước. Nếu đánh quái
bằng hình vuông mà vẫn thấy đã tay thì mới đáng vẽ art.

---

## 3. Danh sách động từ

Đây là thứ đẻ ra bảng kê art ở mục 6.

| Động từ | Cần animation? | Ghi chú |
|---|---|---|
| Đi bộ 4 hướng | Có | ✅ Đã xong |
| Đứng yên | Tái dùng frame 0 | Không tốn art thêm |
| Chém cận chiến | Có | 4 hướng |
| Giương cung bắn | Có | 4 hướng — **animation khác hẳn chém** |
| Bị đánh | Có | 4 hướng, ngắn |
| Chết | Có | 1 animation dùng chung |
| Nhặt đồ | Không | Chạm vào là nhặt |
| Nói chuyện NPC | Không | Chỉ hiện hộp thoại |
| Mở rương | Có | Animation của cái rương, không phải nhân vật |
| Trang bị đồ | Không | Trong menu |
| Rèn / nâng cấp | Không | Trong menu tại lò rèn |

---

## 4. Sprite phân lớp — ✅ ĐÃ DỰNG XONG

Nhân vật là **4 Sprite2D chồng lên nhau**, tất cả dùng chung một chỉ số frame:

```
Player (CharacterBody2D)
├─ Body     ← thân thể: da, tóc, mặt. Lớp duy nhất có VIỀN.
├─ Outfit   ← bộ đồ = giáp + quần (đã chốt gộp làm một)
├─ Helmet   ← mũ
└─ Weapon   ← vũ khí, chỉ hiện khi đang chiến đấu
```

Mỗi lớp là một PNG **128×128, bố cục 4×4**, phần trống để trong suốt.
`player.gd` gán cùng một `frame` cho cả bốn lớp — xem hàm `_apply_frame()`.

Chi phí art là **phép cộng** chứ không phải phép nhân:

| Số bộ đồ × số mũ | Không phân lớp | Có phân lớp |
|---|---|---|
| 3 × 3 | 9 sheet | 6 sheet |
| 5 × 5 | 25 sheet | 10 sheet |
| 8 × 8 | 64 sheet | 16 sheet |

### Ràng buộc bắt buộc

1. Mọi lớp **cùng 128×128, cùng bố cục 4×4**.
2. Mọi lớp dùng chung bộ toạ độ trong `GEOM` (xem `tools/gen_placeholder_art.py`).
   Lệch một pixel là quần áo lệch khỏi người.
3. **Bản nam và bản nữ phải cùng dáng người.** Chỉ khác tóc và mặt.

Ý số 3 là ràng buộc đắt nhất trong tài liệu này. Nếu hai dáng người khác nhau,
**mọi bộ đồ và mọi cái mũ phải vẽ hai lần** — nhân đôi toàn bộ khối lượng art
trang bị, mãi mãi. Giữ chung dáng người thì bản nữ chỉ tốn thêm đúng một lớp
Body, còn toàn bộ trang bị dùng chung.

### Thử ngay trong game

Chạy game rồi bấm:

| Phím | Tác dụng |
|---|---|
| `1` | Đổi nam / nữ |
| `2` | Đổi bộ đồ (không có → vải → da) |
| `3` | Bật/tắt mũ sắt |
| `4` | Đổi vũ khí (kiếm / cung) |
| `5` | Vào/ra chế độ chiến đấu (rút/cất vũ khí) |

Đây là phím tạm để kiểm tra hệ thống, sẽ bỏ khi có menu trang bị thật.

---

## 5. Về vũ khí tầm xa (cung)

Bạn hỏi cung có phức tạp không. Câu trả lời tách làm ba phần:

**Code: rẻ, bạn đúng.** Mũi tên là một `Area2D` bay theo hướng, chạm thì gây
sát thương rồi tự huỷ. Khoảng 50 dòng. Đây là phần dễ nhất.

**Art: đắt hơn bạn tưởng.** Không phải chỉ thêm cái cung vào lớp Weapon.
Động tác **giương cung khác hoàn toàn động tác chém** — nên lớp **Body** cần
thêm một bộ animation tấn công thứ hai, nhân cho cả bản nam và nữ:

- +16 frame bắn cung cho Body nam
- +16 frame bắn cung cho Body nữ
- +20 frame cho lớp Weapon kiểu cung
- +4 frame mũi tên bay

**Thiết kế: đây mới là chỗ thật sự tốn.** Bắn xa phá vỡ thiết kế quái vật
cận chiến. Nếu người chơi bắn được từ ngoài tầm nhìn của quái thì mọi con quái
chỉ biết lao vào đánh giáp lá cà đều trở nên vô hại — người chơi chỉ việc lùi
và bắn. Phải xử lý bằng một trong ba cách:

1. Quái lao tới rất nhanh, buộc người chơi phải rút kiếm
2. Có quái biết bắn lại
3. Mũi tên là tài nguyên hữu hạn, phải nhặt lại

Không cần quyết định ngay bây giờ, nhưng phải quyết trước khi làm quái.

**Kết luận:** giữ cung trong demo được, nhưng **làm kiếm trước cho xong hẳn**
rồi mới thêm cung. Đừng làm song song hai hệ thống chiến đấu khi chưa hệ thống
nào chạy trọn vẹn.

---

## 6. Bảng kê art cho bản demo

Một "frame" = một ô 32×32.

### Nhân vật chính

| Lớp | Nội dung | Frame |
|---|---|---|
| Body nam | đi 16 + chém 16 + bị đánh 8 + chết 6 | 46 |
| Body nữ | như trên | 46 |
| Bắn cung | +16 cho mỗi Body | 32 |
| Outfit | 46 × 2 bộ — **dùng chung cả nam lẫn nữ** | 92 |
| Helmet | 46 × 2 mũ — **dùng chung** | 92 |
| Weapon | kiếm 20 + cung 20 + mũi tên 4 | 44 |
| | **Tổng nhân vật** | **352** |

### Phần còn lại

| Hạng mục | Ước tính |
|---|---|
| 3 loại quái (đi + đánh + chết) | ~90 |
| Tile làng (cỏ, đường, tường, mái, nước, hàng rào) | ~40 |
| Tile hang (đá, sàn, nhũ đá, quặng) | ~25 |
| 4 NPC (chỉ cần đứng + đi chậm) | ~32 |
| Icon UI (vật phẩm, máu, nút) | ~20 |

**Tổng demo: khoảng 560 ô art.**

Hai thứ vừa thêm (bản nữ + cung) chỉ làm tăng từ ~480 lên ~560, tức **+17%**.
Nếu không có hệ thống phân lớp, riêng việc thêm bản nữ đã nhân đôi toàn bộ
art trang bị.

### Về việc dùng AI để vẽ

AI đẩy nhanh được **concept, tile nền, và icon vật phẩm tĩnh** — những thứ
không đòi hỏi nhất quán giữa các frame.

Chỗ AI yếu đúng vào chỗ dự án này cần nhất: **các frame animation liên tiếp
phải nhất quán từng pixel, và các lớp phải khớp nhau tuyệt đối.** Ảnh AI tạo
ra thường chỉ *trông giống* pixel art — viền bị khử răng cưa, kích thước pixel
không đều, bảng màu trôi giữa các lần tạo. Ghép bốn lớp như vậy lên nhau sẽ
lệch.

Cách dùng thực tế: **AI ra concept → vẽ lại trên lưới thật trong Aseprite.**
Vẫn nhanh hơn vẽ từ đầu nhiều, nhưng đừng tính là xong ngay khi AI xuất ảnh.

---

## 7. Phạm vi demo

**Có trong demo:**
- 1 ngôi làng (4 NPC, 1 lò rèn, vài ngôi nhà)
- 1 hang động / hầm mỏ (3 tầng, 3 loại quái)
- Chiến đấu cận chiến + cung
- Nhân vật nam/nữ
- Trang bị nhìn thấy được (mũ + bộ đồ + vũ khí)
- Rèn/nâng cấp trang bị tại làng
- Lưu/tải game, menu chính

**Chưa có trong demo** (ghi ra để khỏi quên, và để khỏi làm sớm):
- Các khu vực tiếp theo của hành trình tìm mẹ và em trai
- Nhiệm vụ phụ
- Hệ thống chế tạo phức tạp
- Ngày/đêm, thời tiết

> Mỗi khi nảy ra ý tưởng mới, ghi vào mục này chứ đừng làm ngay. Ba tháng sau
> đọc lại, phần lớn sẽ tự thấy không cần.

---

## 8. Thứ tự làm

1. ~~Hệ thống sprite phân lớp~~ ✅ **xong**
2. **TileMapLayer** — dựng làng và hang bằng tile ← *đang ở đây*
3. State machine cho nhân vật: đi / chém / bị đánh / chết
4. Một loại quái, AI đơn giản
5. Máu, sát thương, chết, hồi sinh
6. Nhặt đồ + túi đồ
7. Menu trang bị thật (thay 5 phím tạm ở mục 4)
8. **Rồi mới** thêm cung + mũi tên + chỉnh lại AI quái
9. NPC + hộp thoại
10. Lò rèn / nâng cấp
11. Lưu/tải, menu chính, âm thanh
12. Export PC + Android

Art thật chen vào bất cứ lúc nào sau bước 5 — khi gameplay đã đứng vững.
