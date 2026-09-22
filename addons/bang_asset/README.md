# Bảng Asset HD

Panel nằm ở **cột bên phải** cửa sổ Godot. Nếu không thấy, vào
**Project → Project Settings → Plugins** và bật `Bang Asset HD`.

## Nó làm gì

**1. Liệt kê mọi PNG trong `assets/hd/`**
Thả một file PNG vào thư mục đó rồi bấm **Quét lại** — nó hiện ra ngay, kèm
ảnh thu nhỏ.

**2. Cho biết asset to bao nhiêu lần Kael**
Đây là phần quan trọng nhất. Sau khi bỏ lưới 32px, **chiều cao Kael (126px) là
đơn vị đo duy nhất còn lại** của dự án. Panel hiện thẳng dòng:

```
= 5.3 × Kael cao  ·  625 × 668 trong game
```

Đổi số **Phóng to** thì dòng đó cập nhật ngay. Nhờ vậy bạn biết một ngôi nhà
5,3 lần Kael là hợp lý, còn 12 lần thì sai — trước khi đặt nó vào bản đồ.

**3. Biến ảnh thành prop dùng được, một nút bấm**

| Nút | Làm gì |
|---|---|
| **Tạo prop** | Sinh file `.tscn` trong `scenes/props_hd/` |
| **Thêm vào scene** | Tạo prop rồi đặt luôn vào scene đang mở, cạnh nhân vật |

Prop sinh ra đã đúng hai quy ước của dự án:
- **Gốc toạ độ ở chân** vật thể (đáy ảnh, giữa ngang) → Y-sort so sánh đúng
- **Va chạm chỉ bao phần chân** → mái nhà và tán cây thì đi dưới được

Số **Phần chân chặn đường** quyết định bao nhiêu phần trăm chiều cao là đặc.
Nhà thì 60%, cây thì khoảng 15% (chỉ gốc), bia mộ thì 100%.

## Vì sao không làm một ứng dụng riêng

Godot **đã là** công cụ chỉnh vị trí và kích thước tốt nhất — kéo chuột là thấy
ngay, có snap, có undo, có nhiều cửa sổ. Làm lại một panel như vậy chỉ ra một
bản kém hơn.

Chỗ Godot thật sự thiếu là hai việc: **biến một ảnh PNG thành prop đúng quy
ước**, và **kiểm tra tỉ lệ giữa các asset**. Panel này làm đúng hai việc đó,
rồi giao phần còn lại cho Godot.

## Quy trình dùng thực tế

1. AI tạo ảnh → lưu thành PNG
2. Chạy `python tools/check_asset.py <ảnh>` nếu muốn biết ảnh có vấn đề gì
3. Thả PNG vào `assets/hd/`
4. Trong Godot bấm **Quét lại** → thấy ảnh hiện ra
5. Chỉnh **Phóng to** tới khi dòng "× Kael cao" hợp lý
6. Bấm **Thêm vào scene**
7. Kéo chuột trong Godot để đặt đúng chỗ

Bước 6 tạo file scene nên lần sau muốn thêm cái nữa thì kéo thẳng từ
`scenes/props_hd/` trong khung FileSystem, không cần qua panel.

## Giới hạn

- Va chạm sinh ra là **một hình chữ nhật**. Vật thể cần nhiều khối (như ngôi
  nhà cho đi vào được qua mặt trước) thì phải mở file scene ra sửa tay.
- Chỉ đọc `assets/hd/`, không đọc thư mục con.
- Bỏ qua `kael_hd.png` và `aster_ground.png` vì chúng không phải prop.
