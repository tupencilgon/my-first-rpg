# Làm lại giao diện Aster

Bản trước chạy đúng nhưng nhìn rối. Tài liệu này ghi lại **vì sao nó rối** và
**đã sửa bằng cách nào**, để lần sau thêm màn hình mới không lặp lại.

Phần lõi (`game.gd`, `actor.gd`, `world.gd`, `content.gd`) **không đổi một dòng**.
Chỉ `hud.gd`, `ui_assets.gd` và bộ ảnh giao diện được viết lại.

---

## 1. Ba nguyên nhân thật sự

### a. Icon là ảnh 1254×1254 vẽ vào ô 38px

Đây là nguyên nhân lớn nhất, và nó là lỗi **kỹ thuật**, không phải lỗi thẩm mỹ.

Mỗi icon do ImageGen tạo ra là ảnh vuông 1254 pixel. Giao diện vẽ chúng ở
khoảng 34–40 pixel. Godot thu nhỏ bằng lọc song tuyến (*linear*) và trong file
`.import` có dòng `mipmaps/generate=false`. Nghĩa là mỗi điểm ảnh trên màn hình
chỉ lấy trung bình **2×2 điểm** trong số hơn **1000 điểm** của ảnh gốc. Phần lớn
bức ảnh bị vứt đi một cách ngẫu nhiên, và kết quả là một vệt nâu nhòe.

Hai bước sửa:

1. `tools/make_ui_art.gd` thu nhỏ sẵn bằng **Lanczos** xuống 96px, cắt bỏ viền
   rỗng cho chủ thể đầy khung, rồi thêm **viền tối 3px** quanh silhouette để
   icon nổi lên trên mọi nền — đúng lý do pixel art luôn có viền 1px.
2. Bật `mipmaps/generate=true` cho ảnh trong `assets/ui/`, và đặt
   `texture_filter = LINEAR_WITH_MIPMAPS` trên gốc giao diện.

Ảnh gốc trong `assets/arpg_v2/` **không bị đụng tới**. Muốn tạo lại bộ nhỏ:

```bash
godot --headless --path . --script res://tools/make_ui_art.gd
```

Dung lượng ảnh giao diện: **26 MB → 0,9 MB**.

`tests.gd` giờ có một mục kiểm tra chặn lỗi này quay lại:
mọi icon phải rộng ≤ 128px.

### b. Trang trí dùng khắp nơi nên không đánh dấu được gì

Bản cũ đắp khung viền chạm trổ lên **mọi thứ**: bảng trạng thái, nhật ký, bản đồ
nhỏ, thanh kỹ năng — và bên trong thanh kỹ năng lại là bảy ô cũng chạm trổ.
Khung lồng trong khung. Khi mọi thứ đều được viền vàng thì không cái nào nổi bật,
và mắt không biết nhìn vào đâu.

Quy tắc mới:

| Thành phần | Khung |
|---|---|
| Cửa sổ (túi đồ, lò rèn, hội thoại, bản đồ) | Khung chạm trổ `panel.png` |
| Thông tin trên màn hình chơi | Phẳng, mờ 74%, viền 1px gần như vô hình |
| Ô vật phẩm / ô kỹ năng | Phẳng, vuông, viền 1px |
| Thanh kỹ năng | **Không có khung bao** — từng ô đã là khung |

Màu vàng chỉ dùng cho tiêu đề, ô đang chọn và số liệu quan trọng.

### c. Bố cục đặt bằng toạ độ chết

Mọi thứ được đặt bằng toạ độ tuyệt đối trên lưới 960×540 (`Vector2(744,12)`,
`Vector2(223,449)`…). Đổi độ phân giải là lệch hết, và không có căn lề nhất quán
giữa các khối.

Giờ mỗi khối neo vào một góc màn hình, và cửa sổ **tự co lại vừa đúng nội dung**
rồi tự căn giữa.

---

## 2. Những lỗi cụ thể đã sửa

| Lỗi | Sửa |
|---|---|
| Tên bản đồ hiện **hai lần**: một dòng thả nổi giữa màn hình, một dòng nữa ngay dưới | Tên vùng chuyển vào tiêu đề bản đồ nhỏ. Thông báo thành **bảng ngắn ở giữa trên**, tự mờ dần rồi tắt |
| Ô Q và ô R nhìn **trống trơn**, chỉ còn con số | Lớp phủ hồi chiêu che gần hết ô. Giờ số giây nằm trên đĩa tối nhỏ ở giữa, icon vẫn thấy |
| Số bình hồi phục đè lên icon | Thành **huy hiệu tròn ở góc trên phải** ô |
| Chữ phím tắt (J, SPACE, Q…) chật trong ô | Vẽ **bên dưới** ô |
| Túi đồ: hai món đồ nằm lọt thỏm trong một mảng đen lớn | **Lưới ô vuông 6 cột**; ô trống vẫn vẽ ra để nhìn rõ là "chưa có gì" |
| Bốn bộ trang phục dùng chung một icon giáp, không phân biệt nổi | Tô icon theo **màu riêng của từng bộ** |
| Ô hội thoại: nút "Tiếp tục" bị cắt mất, hiện thanh cuộn | Cửa sổ tự co vừa nội dung; ô thoại neo **xuống đáy màn hình** theo chuẩn thể loại |
| Lò rèn: tám công thức làm tràn khung, cắt mất nút "Rèn" | Danh sách công thức **cuộn riêng** trong ô của nó |
| Nút đóng dùng `close.png` — vẽ ra **hai thanh kiếm bắt chéo**, dễ nhầm với nút tấn công | Thay bằng dấu ✕ |
| Chân dung + tên + 3 thanh + một dòng chữ HP riêng chiếm 324×102 | Số HP nằm **trong** thanh máu; cả khối còn 264px ngang |
| Bản đồ nhỏ: vật cản là một đám ô xám rời rạc | Nền sáng hơn vật cản, để khối tường đọc ra là khối đặc |
| Màn hình đầu: một dải trống và một đường kẻ không ngăn cách gì | Cửa sổ không có tên thì không vẽ hàng tiêu đề |

---

## 3. Kiểm chứng

```bash
godot --headless --path . res://scenes/arpg.tscn -- --arpg-test
```

**455 mục, 0 lỗi** — bộ kiểm tra của bản trước chạy nguyên vẹn sau khi viết lại
giao diện. Đó là bằng chứng phần lõi không bị đụng tới.

Chụp ảnh từng màn để nhìn tận mắt:

```bash
godot --path . --script res://tools/capture_ui.gd --resolution 1280x720
```

Ảnh lưu ở `%APPDATA%/Godot/app_userdata/My First RPG/ui_shots/`.

---

## 4. Còn lại

- **Đồ hoạ quái và nhân vật lệch nhau.** Kael là sprite pixel 32px; quái là
  tranh AI mượt, to hơn nhiều. Đây là vấn đề *art*, không phải giao diện, nhưng
  nó là thứ dễ nhận ra nhất còn lại trên màn hình chơi.
- **`assets/arpg_v2/icons/` và `assets/arpg_v2/ui/` (26 MB) giờ không còn được
  đọc lúc chạy** — chúng là ảnh gốc để tạo lại bộ nhỏ. Khi nào làm export thật
  thì nên loại hai thư mục này khỏi gói.
- Ba icon `hide`, `map`, `quest` đều ra hình cuộn giấy nên dễ lẫn. Trong túi đồ
  có tên đi kèm nên không sao; nếu sau này dùng ở chỗ chỉ có icon thì cần vẽ lại.
- Chưa làm bố cục cảm ứng cho điện thoại — bản này vẫn là bàn phím + chuột.
