# Hướng "giả pixel art" — phân tích và bản thử

> Bản thử chạy được: mở `scenes/prototype_hd.tscn` rồi nhấn **F6**.
> `F5` vẫn chạy bản chính 32px. Hai hướng chạy song song, so sánh trực tiếp.

---

## Ý tưởng

Chỉ **art** trông như pixel art. Cấu trúc bên dưới không bị ràng buộc bởi lưới
pixel. Nhờ vậy art do AI tạo vào game trực tiếp, **không cần chuyển đổi**.

## Chỉ có ba thứ thay đổi về kỹ thuật

| | Bản chính | Bản giả pixel art |
|---|---|---|
| Độ phân giải gốc | 640×360 | 1920×1080 |
| Phóng to | **số nguyên** (×3 = 1080p) | **phân số** |
| Mặt đất | TileMap 32px | một ảnh vẽ sẵn |

Dòng quan trọng nhất là cái thứ hai. Phóng to theo số nguyên là thứ bắt mọi
pixel phải vuông vắn — cũng chính là thứ bắt art phải nằm đúng lưới. Bỏ nó đi
là bỏ luôn toàn bộ công đoạn chuyển đổi.

---

## Được gì

**Art vào game trực tiếp.** Ngôi nhà cháy 32px tôi phải viết code chấm từng
pixel và sửa ba lần. Bản HD chỉ là **một lần cắt** từ chính bảng ref của bạn.

**Chi tiết cao hơn.** Mặt nhân vật có mắt rõ hình quả hạnh, viền áo tua rua —
những thứ ở 32px phải bỏ.

**Art bạn đã có dùng được ngay.** Bộ turnaround, bảng nhà cửa, ảnh nền bản đồ,
bảng vật liệu — tất cả đang nằm trong `docs/art/`, không phải làm lại.

## Trả giá gì — nói thẳng

**1. Tính nhất quán trở thành việc của bạn.**
Lưới 32px tự bắt mọi thứ cùng tỉ lệ. Không có lưới, không gì cản một nhân vật
cao 126px đứng cạnh một ngôi nhà vẽ ở 800px. Phải **ghi ra quy tắc tỉ lệ** và
tự giữ. Đề xuất: Kael cao 126px, mọi thứ khác đo bằng "số lần chiều cao Kael".

**2. Va chạm phải đặt tay.**
TileMap cho va chạm miễn phí theo từng ô. Ảnh nền vẽ sẵn không cho gì cả. Mỗi
bức tường, mỗi chướng ngại đều là một khối tôi đặt bằng tay.

**3. Animation KHÔNG dễ hơn.**
Bộ ref HD chỉ có 4 tư thế đứng. Chu kỳ bước chân vẫn phải có frame, và chuyện
AI khó giữ nhất quán giữa các frame thì y nguyên — chỉ là ở cỡ 126px.
Trong bản thử tôi thay bằng một **nhịp nhún lên xuống 4 pixel**. Nó đọc ra
được là "đang đi", nhưng không phải animation thật.

**4. Mỗi khu vực là một bức vẽ mới.**
Tile cho phép dựng bản đồ bất kỳ kích thước từ 16 mảnh. Ảnh nền vẽ sẵn thì
làng Aster, hầm mỏ, và mọi khu sau này đều cần bức vẽ riêng.

**5. Bộ nhớ trên điện thoại.**
Một ảnh nền 1254×1254 tốn khoảng 6MB trong VRAM. Vài khu thì không sao, hàng
chục khu thì phải để ý.

---

## Cái gì còn dùng được, cái gì thành vô dụng

**Còn nguyên giá trị** — toàn bộ phần cấu trúc:
- Cách viết `player.gd` (đọc input, đổi hướng, gán frame)
- Y-sort và quy ước **gốc toạ độ ở chân** cho cả nhân vật lẫn vật thể
- `tools/check_asset.py`
- `DESIGN.md`, cốt truyện, phạm vi demo 10 cảnh

**Thành vô dụng** (vẫn nằm trong git, không mất):
- Bộ 16 tile 32px trong `terrain.png`
- Sprite 32px: `body_male`, `outfit_*`, `helmet_*`, `weapon_*`, `kael_v03`
- Hình học của hệ thống trang bị phân lớp (ý tưởng còn đúng, số đo thì không)
- `tools/retouch_kael_face.py`

---

## Đề xuất

**Đi theo hướng này.** Lý do đơn giản: bạn tạo art bằng AI, và công đoạn
chuyển đổi là chỗ đã gây tắc hai lần. Một quy trình bạn không dùng thì kém giá
trị hơn một thẩm mỹ kém thuần khiết hơn mà bạn thật sự dùng.

**Nhưng đừng dùng ảnh nền vẽ sẵn cho mặt đất.** Bản thử làm vậy để chứng minh
nó chạy được, còn cho làng Aster thì nên dùng **tile HD 128px**:

- Bảng `02_ground_materials.png` của bạn đã là atlas 4×4 — chỉ cần đổi cỡ về
  512×512 là thành 16 tile 128px. Đó là phép đổi cỡ thuần cơ học.
- Tile 128px **không cần** là pixel art thật, nên vẫn không có công đoạn chuyển
  đổi nào.
- Đổi lại được: va chạm miễn phí theo ô, và dựng bản đồ rộng bao nhiêu cũng
  được từ 16 mảnh.

Ảnh nền vẽ sẵn thì để dành cho những cảnh đặc biệt dùng một lần.

Tức là: **tile HD cho mặt đất + prop HD đặt lên trên + ảnh vẽ sẵn cho cảnh
đặc biệt.**

---

## Nếu chốt hướng này, cần làm

1. Ghi quy tắc tỉ lệ vào `DESIGN.md` (Kael = 126px là đơn vị gốc)
2. Đổi `project.godot`: 1920×1080, bỏ phóng to số nguyên
3. Đổi cỡ `02_ground_materials.png` → atlas 512×512 (16 tile 128px)
4. TileSet mới 128px, khai báo ô nào chặn đường
5. Cắt prop từ `03_buildings`, `04_burnt_trees`, `05_props`
6. Vẽ lại bản đồ Aster trên lưới 128px
7. Sinh chu kỳ bước chân HD cho Kael (việc art, không phải việc code)
