# My First RPG

Game 2D pixel art top-down, làm bằng **Godot 4.7** + **GDScript**.
Mục tiêu nền tảng: **Windows/PC, Android, iOS**.

---

## 1. Cài Godot (làm 1 lần)

Godot không cần "cài đặt" theo kiểu thông thường — nó là 1 file `.exe` chạy thẳng.

```bash
winget install --id GodotEngine.GodotEngine -e
```

Hoặc tải thủ công: https://godotengine.org/download/windows — chọn bản **Godot 4.7.2 (Standard)**.

> **Standard hay .NET?** Chọn **Standard**. Bản .NET dành cho người viết C#. Bạn đang học
> GDScript nên không cần, và bản Standard export sang Android/iOS đơn giản hơn nhiều.

## 2. Mở project

1. Mở Godot → nút **Import** → trỏ tới file `project.godot` trong thư mục này.
2. Nhấn **F5** (hoặc nút ▶ góc trên bên phải) để chạy.

Lần mở đầu tiên Godot sẽ mất vài giây để import ảnh — bình thường.

Hoặc dùng terminal:

```bash
godot -e --path .
```

> **Chú ý:** phải có `-e` (viết tắt của *editor*). Nếu gõ `godot --path .` không kèm `-e`,
> Godot sẽ **chạy thẳng game** chứ không mở editor.

## 3. Điều khiển

| Nền tảng | Cách chơi |
|---|---|
| PC | `WASD` hoặc phím mũi tên |
| Tay cầm | D-pad |
| Điện thoại | Chạm & kéo ở **nửa trái màn hình** → joystick ảo hiện ra |

Phím tạm để thử hệ thống trang bị phân lớp: `1` đổi nam/nữ, `2` đổi bộ đồ,
`3` bật/tắt mũ, `4` đổi kiếm/cung, `5` vào/ra chế độ chiến đấu.

Muốn thử joystick ảo trên PC: chọn node `UI/TouchJoystick` trong Godot, bật
`Always Show` trong Inspector, rồi vào **Project → Project Settings → Input Devices →
Pointing** bật **Emulate Touch From Mouse**.

---

## 4. Cấu trúc thư mục

```
my-first-rpg/
├─ project.godot              cấu hình game (độ phân giải, renderer...)
├─ icon.svg                   icon hiện trên Godot & khi export
├─ scenes/
│  ├─ main.tscn               màn chơi: sàn, tường, người chơi, UI
│  └─ player.tscn             nhân vật (sprite + va chạm + camera)
├─ scripts/
│  ├─ player.gd               di chuyển & hoạt ảnh 4 hướng
│  └─ touch_joystick.gd       joystick ảo cho điện thoại
├─ assets/
│  ├─ sprites/*.png           các lớp sprite: body_*, outfit_*, helmet_*, weapon_*
│  └─ tiles/floor.png, wall.png
└─ tools/
   └─ gen_placeholder_art.py  script Python tạo art tạm (xem mục 6)
```

**Cách sprite sheet hoạt động:** mỗi lớp là ảnh 128×128, chia thành lưới 4×4.
Mỗi **hàng** là một hướng (0 = xuống, 1 = lên, 2 = trái, 3 = phải), mỗi **cột** là một
frame của chu kỳ bước chân. `player.gd` chỉ việc đổi số `frame` của Sprite2D.

---

## 5. Lộ trình học — làm theo thứ tự này

Mỗi bước nên hoàn thành và **chạy thử được** trước khi sang bước sau. Đừng ôm việc lớn.

### Tuần 1–2: Làm quen
- [ ] Chạy được game, đọc hết `scripts/player.gd`, hiểu từng dòng
- [ ] Đổi `speed` trong Inspector, xem nhân vật nhanh/chậm ra sao
- [ ] Tự thêm nút **chạy nhanh** khi giữ `Shift`
- [ ] Học chính thức: https://docs.godotengine.org/en/stable/getting_started/step_by_step/

### Tuần 3–4: Bản đồ thật
- [ ] Học **TileMapLayer** + **TileSet** (đây là công cụ vẽ map của Godot)
- [ ] Thay 4 bức tường cứng hiện tại bằng một map vẽ bằng TileMapLayer
- [ ] Thêm **Y-sort** để nhân vật đi được ra sau cái cây / ngôi nhà

### Tuần 5–6: Có "game" thật sự
- [ ] Thêm **NPC** đứng yên + vùng `Area2D` để phát hiện người chơi lại gần
- [ ] Làm **hộp thoại** hiện chữ khi nhấn nút tương tác
- [ ] Thêm **quái** đi tuần theo đường có sẵn
- [ ] Máu, sát thương, màn hình game over

### Tuần 7–8: Đóng gói
- [ ] Menu chính + nút thoát
- [ ] Lưu/tải game (`FileAccess` + JSON)
- [ ] Âm thanh (`AudioStreamPlayer`)
- [ ] Export ra PC và Android (mục 7)

> **Lời khuyên quan trọng:** game đầu tay nên **nhỏ đến mức buồn cười** — 1 căn phòng,
> 1 NPC, 1 con quái, 5 phút chơi. Game đầu tiên là để *học cách hoàn thành một game*,
> không phải để hay. Hầu hết người mới bỏ cuộc vì bắt đầu bằng một dự án quá lớn.

---

## 6. Vẽ pixel art

Art hiện tại là **placeholder** do script Python vẽ ra — xấu nhưng đúng kích thước,
đủ để bạn tập trung vào lập trình trước.

Khi vẽ art thật, chỉ cần **ghi đè file PNG** trong `assets/` với **đúng kích thước cũ**
(mỗi lớp sprite = 128×128, tile = 32×32). Không phải sửa một dòng code nào. Xem `DESIGN.md` mục 4 về hệ thống phân lớp.

| Công cụ | Giá | Ghi chú |
|---|---|---|
| **Aseprite** | ~$20 | Tiêu chuẩn ngành, đáng từng đồng. Có trên Steam. |
| **LibreSprite** | Miễn phí | Bản fork mã nguồn mở của Aseprite đời cũ |
| **Piskel** | Miễn phí | Chạy ngay trên web, hợp để thử |
| **Krita** | Miễn phí | Mạnh nhưng không chuyên pixel art |

Nguồn asset miễn phí để học: [itch.io/game-assets/free](https://itch.io/game-assets/free),
[kenney.nl](https://kenney.nl) (miễn phí hoàn toàn, dùng được cả cho game thương mại).

Chạy lại script tạo art tạm:

```bash
python tools/gen_placeholder_art.py
```

---

## 7. Export ra từng nền tảng

Trước khi export lần đầu: **Editor → Manage Export Templates → Download and Install**
(~1GB, tải 1 lần dùng mãi).

### Windows / Linux / macOS — dễ nhất
**Project → Export → Add → Windows Desktop → Export Project**. Xong, ra file `.exe`.

### Android — làm được ngay trên máy này
Cần chuẩn bị một lần:
1. Cài **OpenJDK 17** và **Android SDK** (cách nhanh nhất: cài Android Studio)
2. Trong Godot: **Editor → Editor Settings → Export → Android**, trỏ đường dẫn tới SDK
3. Tạo **debug keystore** (Godot có nút tạo sẵn)
4. **Project → Export → Add → Android** → Export ra file `.apk`

Chép `.apk` vào điện thoại và cài là chơi được. Để đưa lên Google Play cần thêm tài khoản
nhà phát triển (phí $25 một lần).

### iOS — đây là phần cần biết trước
**Bắt buộc phải có máy Mac chạy macOS + Xcode** để build và ký ứng dụng iOS. Đây là ràng
buộc của Apple, không có cách lách hợp pháp nào từ Windows. Ngoài ra cần **Apple Developer
Program: $99/năm**.

Ba lựa chọn khi tới lúc đó:
1. **Dịch vụ build cloud** — [Codemagic](https://codemagic.io) hoặc GitHub Actions với
   macOS runner. Bạn vẫn cần tài khoản Apple Developer nhưng không cần mua Mac.
2. **Mượn/mua Mac** — Mac mini M-series cũ là rẻ nhất.
3. **Bỏ qua iOS lúc đầu** — đây là lựa chọn tôi khuyên. Cứ làm PC + Android trước.
   Code và asset dùng chung 100%, thêm iOS sau không phải làm lại gì cả.

---

## 8. Ghi chú kỹ thuật

**Về Input Map:** project này đọc phím trực tiếp trong `player.gd` (dùng action `ui_*`
có sẵn của Godot + kiểm tra WASD bằng `Input.is_key_pressed`). Cách này chạy được ngay
không cần cấu hình gì. Khi đã quen Godot, nên chuyển sang khai báo action riêng trong
**Project Settings → Input Map** (`move_up`, `move_down`...) — đó là cách làm chuẩn và
cho phép người chơi đổi phím.

**Về độ phân giải:** game chạy ở độ phân giải gốc **640×360** với tile **32×32**, phóng to bằng số nguyên
(`scale_mode = integer`). Đây là thiết lập chuẩn cho pixel art — đảm bảo mọi pixel đều
vuông vắn, không bị nhòe hay méo. Muốn thấy nhiều cảnh hơn trên màn hình thì tăng con số
này trong `project.godot`.

**Về renderer:** dùng **GL Compatibility** thay vì Forward+. Nó chạy được trên hầu hết
điện thoại Android/iOS đời cũ, và với game 2D thì không mất gì về chất lượng.
