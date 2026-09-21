# Thiết kế game — bản demo

> Tài liệu này chốt những gì **ràng buộc art và code**. Nó cố tình ngắn.
> Mọi thứ không ảnh hưởng tới art hay code thì chưa cần quyết định.

---

## 1. Một câu

> Một thợ rèn trẻ ở ngôi làng miền núi. Hầm mỏ dưới làng bỗng trào lên quái
> vật, cậu phải tự rèn lấy vũ khí và xuống hang tìm hiểu chuyện gì đang xảy ra.

Đây là bản nháp — bạn sửa thoải mái. Câu này chỉ có một nhiệm vụ: quyết định
phong cách art (ở đây là **trung cổ, làng quê, hang mỏ**), và giải thích được
vì sao người chơi lại quan tâm tới trang bị.

Lưu ý: câu pitch này được chọn để **khớp với cơ chế bạn đã quyết**. Thợ rèn →
tự làm trang bị → trang bị hiện lên người → có lý do để xuống hang lấy quặng.
Cốt truyện phục vụ gameplay, không phải ngược lại.

---

## 2. Core loop — 30 giây lặp đi lặp lại

```
Xuống hang  →  gặp quái  →  đánh cận chiến  →  nhặt quặng
     ↑                                              ↓
     └────  xuống sâu hơn  ←  rèn/nâng trang bị  ←  về làng
```

Đây là phần quan trọng nhất của cả tài liệu. Nếu vòng lặp này chơi không
sướng thì art đẹp cỡ nào cũng không cứu được.

**Cách kiểm tra:** làm vòng lặp này bằng hình vuông màu trước. Nếu đánh quái
bằng hình vuông mà vẫn thấy đã tay thì mới đáng vẽ art.

---

## 3. Danh sách động từ

Đây là thứ đẻ ra bảng kê art ở mục 5.

| Động từ | Cần animation? | Ghi chú |
|---|---|---|
| Đi bộ 4 hướng | Có | Đã làm xong |
| Đứng yên | Tái dùng frame 0 | Không tốn art thêm |
| Tấn công cận chiến | Có | 4 hướng |
| Bị đánh | Có | 4 hướng, ngắn |
| Chết | Có | 1 animation dùng chung |
| Nhặt đồ | Không | Chạm vào là nhặt |
| Nói chuyện NPC | Không | Chỉ hiện hộp thoại |
| Mở rương | Có | Animation của cái rương, không phải nhân vật |
| Trang bị đồ | Không | Trong menu |
| Rèn / nâng cấp | Không | Trong menu tại lò rèn |

---

## 4. Kiến trúc sprite phân lớp — QUYẾT ĐỊNH QUAN TRỌNG NHẤT

Bạn muốn **mũ, giáp, quần hiện lên người**, và **vũ khí chỉ xuất hiện khi
chiến đấu**. Làm được, nhưng phải làm đúng cách.

### Cách sai (đừng làm)

Vẽ mỗi tổ hợp trang bị thành một sprite sheet hoàn chỉnh. Chi phí là **phép
nhân**: 3 bộ giáp × 3 mũ = 9 sheet đầy đủ. Thêm một cái mũ nữa là thành 12.

### Cách đúng: xếp lớp (paper doll)

Nhân vật là **nhiều Sprite2D chồng lên nhau**, tất cả cùng dùng một chỉ số
frame:

```
Player (CharacterBody2D)
├─ Sprite2D  "Body"     ← thân thể trần, luôn hiện
├─ Sprite2D  "Outfit"   ← giáp + quần (1 lớp)
├─ Sprite2D  "Helmet"   ← mũ
└─ Sprite2D  "Weapon"   ← vũ khí, chỉ hiện khi đang chiến đấu
```

Mỗi lớp là một file PNG riêng, **cùng kích thước 128×128, cùng bố cục 4×4**,
phần không có gì thì để trong suốt. Code chỉ cần gán cùng một `frame` cho cả
bốn lớp là xong — đúng logic bạn đang có trong `player.gd`, chỉ nhân lên 4.

Chi phí trở thành **phép cộng**: 3 bộ giáp + 3 mũ = 6 file, vẫn ra 9 vẻ ngoài.

| Số bộ giáp × số mũ | Cách sai | Cách đúng |
|---|---|---|
| 2 × 2 | 4 sheet | 4 sheet |
| 3 × 3 | 9 sheet | 6 sheet |
| 5 × 5 | 25 sheet | 10 sheet |
| 8 × 8 | 64 sheet | 16 sheet |

Càng về sau càng chênh. Đây là lý do phải quyết định **trước khi vẽ**.

### Một điều chỉnh tôi đề nghị

Bạn nói "mũ, giáp, quần" là ba món. Tôi đề nghị **gộp giáp và quần thành một
lớp "bộ đồ"**, giữ mũ riêng.

Lý do: quần ở góc nhìn top-down chiếm rất ít pixel và gần như không ai để ý,
nhưng tách nó ra thì tốn thêm nguyên một bộ 46 frame cho mỗi món. Gộp lại tiết
kiệm khoảng một phần ba khối lượng art mà người chơi không nhận ra khác biệt.

Chỉ số trong game vẫn có thể tách riêng mũ / giáp / quần bình thường — chỉ
phần **hình ảnh** là gộp.

Bạn không đồng ý thì nói, tôi tách thành ba lớp, code y hệt, chỉ tốn art hơn.

---

## 5. Bảng kê art cho bản demo

Một "frame" = một ô 32×32 trong sprite sheet.

### Nhân vật chính

| Lớp | Nội dung | Frame |
|---|---|---|
| Body | đi 16 + tấn công 16 + bị đánh 8 + chết 6 | **46** |
| Outfit | 46 frame cho mỗi bộ đồ | 46 × số bộ |
| Helmet | 46 frame mỗi mũ (vùng vẽ nhỏ, nhanh hơn ~3 lần) | 46 × số mũ |
| Weapon | chỉ frame tấn công + cầm | 20 × số vũ khí |

Demo gợi ý: **2 bộ đồ, 2 mũ, 2 vũ khí** → 46 + 92 + 92 + 40 = **270 frame**.

### Phần còn lại

| Hạng mục | Ước tính |
|---|---|
| 3 loại quái (đi + đánh + chết) | ~90 frame |
| Tile làng (cỏ, đường, tường, mái, nước, hàng rào) | ~40 tile |
| Tile hang (đá, sàn, nhũ đá, quặng) | ~25 tile |
| 4 NPC (chỉ cần đứng + đi chậm) | ~32 frame |
| Icon UI (item, máu, nút bấm) | ~20 icon |

**Tổng demo: khoảng 480 ô art.**

Với người mới vẽ pixel art, tốc độ thực tế khoảng 4–8 ô mỗi giờ khi đã có
animation. Tức là **60–120 giờ vẽ** cho bản demo. Con số này nghe nản nhưng
biết trước vẫn hơn.

**Cách sống sót:** làm 1 bộ đồ, 1 mũ, 1 vũ khí, 1 loại quái trước. Chơi được
đã. Rồi thêm dần. Đừng vẽ hết 480 ô rồi mới ghép vào game.

---

## 6. Phạm vi demo

**Có trong demo:**
- 1 ngôi làng (4 NPC, 1 lò rèn, vài ngôi nhà)
- 1 hang động (3 tầng, 3 loại quái)
- Chiến đấu cận chiến
- Trang bị nhìn thấy được (mũ + bộ đồ + vũ khí)
- Rèn/nâng cấp trang bị tại làng
- Lưu/tải game
- Menu chính

**Chưa có trong demo (ghi ra để khỏi quên, và để khỏi làm sớm):**
- Nhiều khu vực hơn
- Nhiệm vụ phụ
- Hệ thống chế tạo phức tạp
- Ngày/đêm
- Thời tiết
- Nhiều nhân vật chơi được

> Mỗi khi nảy ra ý tưởng mới, ghi vào mục này chứ đừng làm ngay. Ba tháng sau
> đọc lại, phần lớn sẽ tự thấy không cần.

---

## 7. Thứ tự làm

1. TileMapLayer — dựng làng và hang bằng tile tạm
2. Hệ thống sprite phân lớp cho nhân vật (mục 4)
3. State machine cho nhân vật: đi / tấn công / bị đánh / chết
4. Một loại quái, một kiểu AI đơn giản
5. Máu, sát thương, chết, hồi sinh
6. Nhặt đồ + túi đồ
7. Trang bị + hiện lên ngoại hình
8. NPC + hộp thoại
9. Lò rèn / nâng cấp
10. Lưu/tải, menu chính, âm thanh
11. Export PC + Android

Art thật chen vào bất cứ lúc nào sau bước 5 — khi gameplay đã đứng vững.
