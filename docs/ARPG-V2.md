# Aster v2 — Giao diện & quái vật

Bản nâng cấp ngày 23/09/2026 cho **Aster — Tro tàn & Hy vọng**. Giữ tiến độ lưu của bản trước, cốt truyện Chương 0, 3 vùng và 10 bản đồ.

## Chơi bản mới

Giải nén **Aster-v2-Windows.zip**, mở **CHOI-GAME.cmd** hoặc **Aster.exe** trong thư mục vừa giải nén. Giữ file `Aster.pck` cạnh `Aster.exe`. Chọn **Tiếp tục hành trình** để dùng bản lưu trước; chỉ chọn hành trình mới nếu muốn chơi lại.

## Những gì đã thay đổi

- Màn hình đầu với tranh Aster mới; giao diện da sẫm, đồng cũ và ánh lửa theo bối cảnh làng tro tàn.
- Chân dung, thanh máu/thể lực/kinh nghiệm, nhật ký thu gọn, bản đồ nhỏ và thanh kỹ năng có báo hồi chiêu.
- Túi đồ chia thẻ, ô vật phẩm, thông tin trang bị và nút sử dụng; cửa sổ rèn, bản đồ vùng, hội thoại, tạm dừng và hồi sinh được bố trí lại.
- **18 icon được tạo riêng**: kiếm, né, xung kích, bình máu, túi, bản đồ, khiên, vàng, quặng, da, thảo dược, cung, trượng, áo giáp, rèn, nhiệm vụ, đóng và cài đặt.
- **7 bộ sprite quái mới**: sói, dơi, bọ tinh thạch, cướp, bóng sương, thú hắc thạch và kẻ giữ ấn. Mỗi bộ có 4 hướng và 8 khung mỗi hướng: đứng, hai bước đi, chuẩn bị đánh, ra đòn, bị đánh, gục và nằm chết — tổng cộng **224 khung**. Hoạt ảnh được nối với trạng thái chiến đấu thực tế.

## Điều khiển nhanh

| Phím | Thao tác |
|---|---|
| WASD / mũi tên | Di chuyển |
| J / chuột trái | Tấn công theo hướng nhân vật |
| Space | Né |
| F / chuột phải | Giữ đỡ; canh thời điểm để parry |
| Q | Xung kích |
| R | Uống bình máu |
| E | Nói chuyện, tương tác, qua lối chuyển bản đồ |
| I / Tab | Túi đồ, đổi trang bị |
| M | Bản đồ vùng |
| Esc | Đóng cửa sổ / tạm dừng |

Đi đến vật phẩm dưới đất để nhặt. Gặp thợ rèn tại Aster để nâng vũ khí, rèn, may áo và chế bình. Xem `HUONG-DAN-CHOI.md` để biết đầy đủ cơ chế và nội dung.

## Nguồn hình ảnh

30 ảnh PNG mới trong `assets/arpg_v2/` được tạo bằng công cụ **ImageGen tích hợp**, gồm 5 ảnh giao diện, 18 icon và 7 atlas quái. Ba tài liệu `arpg-v2-ui-prompts.md`, `arpg-v2-icon-prompts.md`, `arpg-v2-monster-prompts.md` lưu yêu cầu tạo ảnh và thông tin nguồn. Gói **Aster-v2-Art.zip** chứa ảnh gốc cùng các tài liệu này.

Bố cục lấy cảm hứng từ thanh trạng thái, ô kỹ năng và túi chia thẻ của game nhập vai như Ngọc Rồng Online, Ninja School; hình ảnh mới mang concept Aster. Các ảnh bản đồ người dùng cung cấp và hình nhân vật có sẵn vẫn được sử dụng. Lần nâng cấp này tạo mới UI và quái, không thay toàn bộ art bản đồ hoặc bộ hoạt ảnh nhân vật chính.

## Lưu game & kiểm tra

Bản lưu vẫn ở `%APPDATA%/Godot/app_userdata/My First RPG/aster_arpg_save_v1.json`. Bộ kiểm tra dùng file riêng, không ghi đè bản lưu chơi thật.

Kiểm tra tự động bao phủ di chuyển, chiến đấu, loot, trang bị, rèn, nhiệm vụ, lưu/tải, khung atlas, hướng nhìn, chuyển trạng thái quái và thao tác cửa sổ mới. Ảnh kiểm tra được chụp trực tiếp trong Godot. Sprite dùng số khung cơ bản, phù hợp bản chơi hiện tại; chưa phải hoạt ảnh vẽ tay nhiều khung như bản thương mại.
