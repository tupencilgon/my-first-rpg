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
- **KHÔNG đưa ước lượng thời gian** (bao nhiêu giờ / tuần / tháng / năm để làm xong).
  Người dùng đã yêu cầu rõ. Claude viết 100% code, nên những con số đó không còn ý nghĩa.
  Vẫn được nói một việc **phụ thuộc việc khác** hoặc **cần chia nhỏ**, nhưng nói bằng
  thứ tự và số lượng công việc, không bằng thời gian.
- Ước lượng khối lượng art thì đếm bằng **số ô sprite**, không đổi sang giờ vẽ

## Thiết kế game

Các quyết định đã chốt nằm trong `DESIGN.md` — đọc trước khi đề xuất tính năng hay art.
Tóm tắt: top-down RPG. Nhân vật chính **Kael (nam, cố định)**, làng **Aster**, mẹ **Elara**.
Trang bị hiện lên ngoại hình bằng
**sprite phân lớp** (Body / Outfit / Helmet / Weapon, mỗi lớp 1 file PNG 128×128
cùng bố cục 4×4, cùng chỉ số frame). Demo gồm 1 làng + 1 hang động.

**Demo KHÔNG có chiến đấu** — là mục 2+3+5 của Chương 0: Kael tỉnh dậy → về làng cháy →
đào bới tìm mẹ và em → gặp Edren → hôm sau chỉ còn chiếc ghế trống → nghĩa trang. ~15 phút.
Đừng đề xuất quái/máu/sát thương/hầm mỏ cho demo; chúng ở ngoài phạm vi.

Ý tưởng mới ngoài phạm vi demo → ghi vào mục 2 của `DESIGN.md` (phần "chưa có"), không làm ngay.
Cốt truyện đầy đủ ở `docs/cot-truyen/` — đọc trước khi bàn nội dung.

Bản đồ vẽ bằng 2 node TileMapLayer trong `main.tscn`: `Ground` (đi qua được) và
`Blocking` (chặn đường). Bộ tile ở `assets/tiles/terrain.tres`.
KHÔNG viết script sinh lại bản đồ — người dùng vẽ tay trong editor, chạy lại script
sẽ xoá sạch công sức của họ.

**KHÔNG ghi đè trọn file `main.tscn`.** Dữ liệu bản đồ nằm trong thuộc tính
`tile_map_data` của hai node TileMapLayer — ghi đè cả file là xoá sạch bản đồ.
Muốn thêm node thì dùng Edit chèn vào, đừng dùng Write. (Claude đã mắc lỗi này
một lần và phải lấy lại `tile_map_data` từ git.)

## Vật thể (prop)

Vật thể lớn — nhà, cây, giếng, bia mộ — là **PNG riêng**, không ghép từ tile.
Ảnh ở `assets/props/`, scene ở `scenes/props/`.

Quy ước: **gốc toạ độ của prop nằm ở CHÂN nó** (đáy ảnh, giữa chiều ngang), nên
Sprite2D đặt `offset = (-rộng/2, -cao)`. Nhân vật cũng lấy gốc ở chân
(`offset = (0, -16)`). Hai bên phải cùng quy ước, nếu không Y-sort so sánh lệch.

Vùng va chạm chỉ bao quanh **phần chân** — tán cây và mái nhà thì người chơi đi
dưới được.

Mọi prop và người chơi phải là **con trực tiếp** của node `World`
(`y_sort_enabled = true`). Y-sort chỉ sắp xếp con trực tiếp; lồng thêm một lớp
Node2D ở giữa là mất tác dụng.

## Quy ước kỹ thuật

- **GDScript thụt đầu dòng bằng TAB**, không dùng space (Godot báo lỗi nếu trộn lẫn)
- Sprite sheet nhân vật: 4 cột (frame đi bộ) × 4 hàng (hướng: 0=xuống, 1=lên, 2=trái, 3=phải)
- **Lưới pixel: 32×32** (tile 32px, sprite nhân vật 32×32, độ phân giải gốc 640×360)
- Mọi asset mới phải cùng lưới 32px — trộn mật độ pixel là lỗi nhìn ra ngay
- Độ phân giải gốc phóng to theo số nguyên (×3 = 1080p) — không phá vỡ thiết lập này
- Vật thể dễ nhận ra (hoa, đá, nấm) KHÔNG được nhét vào tile nền: sẽ lặp thành lưới đều
- Renderer **GL Compatibility** để chạy được trên điện thoại đời cũ
- Mọi lớp sprite nhân vật phải cùng kích thước 128×128 và cùng bố cục 4×4, phần trống để trong suốt
- Art trong `assets/` là placeholder sinh bằng `tools/gen_placeholder_art.py`; khi thay art thật phải **giữ nguyên kích thước ảnh** để không phải sửa code
