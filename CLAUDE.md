# Hướng dẫn cho Claude khi làm việc trong project này

## Quy tắc bắt buộc: luôn bật Godot sau khi xong

**Mỗi khi thay đổi xong code, scene hoặc asset, phải tự động mở Godot editor cho người dùng xem — không cần hỏi, không bắt họ tự gõ lệnh.**

Chạy ngầm (background) để không chặn phiên làm việc:

```
& $godot -e --path "D:\GameDev\projects\my-first-rpg"
```

Nếu editor đã mở sẵn thì không mở thêm cửa sổ thứ hai — Godot tự nhận project đang mở.

## Đường dẫn Godot

```
C:\Users\PC\AppData\Local\Microsoft\WinGet\Packages\GodotEngine.GodotEngine_Microsoft.Winget.Source_8wekyb3d8bbwe\Godot_v4.7.2-stable_win64.exe
```

Lệnh `godot` cũng dùng được trong terminal mới (winget đã thêm alias vào PATH).

## Các lệnh hay dùng

| Việc | Lệnh |
|---|---|
| Mở editor | `godot -e --path .` |
| Chạy game | `godot --path .` |
| Kiểm tra lỗi không cần cửa sổ | `godot --headless --path . --quit-after 180` |
| Import lại asset | `godot --headless --path . --import --quit-after 200` |
| Tạo lại art tạm | `python tools/gen_placeholder_art.py` |

**Lưu ý:** `godot --path .` (không có `-e`) **chạy game**, không mở editor.

## Cách làm việc với người dùng

Người dùng **chưa từng lập trình bao giờ** và trao đổi bằng **tiếng Việt**.

- Trả lời bằng tiếng Việt
- Code phải có chú thích tiếng Việt giải thích *tại sao*, không chỉ *cái gì*
- Chia việc thành bước nhỏ, mỗi bước phải chạy thử được ngay
- Luôn tự kiểm chứng (chạy headless, chụp ảnh render) trước khi nói "xong"
- Giữ phạm vi nhỏ — đây là game đầu tay, mục tiêu là *hoàn thành*, không phải *hoành tráng*

## Quy ước kỹ thuật

- **GDScript thụt đầu dòng bằng TAB**, không dùng space (Godot báo lỗi nếu trộn lẫn)
- Sprite sheet nhân vật: 4 cột (frame đi bộ) × 4 hàng (hướng: 0=xuống, 1=lên, 2=trái, 3=phải)
- **Lưới pixel: 32×32** (tile 32px, sprite nhân vật 32×32, độ phân giải gốc 640×360)
- Mọi asset mới phải cùng lưới 32px — trộn mật độ pixel là lỗi nhìn ra ngay
- Độ phân giải gốc phóng to theo số nguyên (×3 = 1080p) — không phá vỡ thiết lập này
- Vật thể dễ nhận ra (hoa, đá, nấm) KHÔNG được nhét vào tile nền: sẽ lặp thành lưới đều
- Renderer **GL Compatibility** để chạy được trên điện thoại đời cũ
- Art trong `assets/` là placeholder sinh bằng `tools/gen_placeholder_art.py`; khi thay art thật phải **giữ nguyên kích thước ảnh** để không phải sửa code
