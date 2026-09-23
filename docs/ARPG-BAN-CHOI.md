# Aster — Tro tàn & Hy vọng

Bản ARPG chơi được trên Windows, mở rộng dự án Godot hiện có theo yêu cầu ngày 22/09/2026. Phạm vi ARPG mới thay thế giới hạn “demo không chiến đấu” trong DESIGN.md đối với scene `arpg.tscn`. Scene `main.tscn`, bản đồ vẽ tay và các ảnh nguồn vẫn được giữ nguyên.

## Mở game

Trong Godot: mở project và nhấn F5. Scene mặc định là `scenes/arpg.tscn`.

Trong gói Windows: mở `CHOI-GAME.cmd` hoặc `Aster.exe`, chọn **Bắt đầu hành trình mới**. Giữ `Aster.exe` và `Aster.pck` cùng thư mục. Gói kèm runtime Godot hiện có trên máy vì chưa cài export template; không cần cài Godot để chơi gói này.

## Điều khiển

| Phím | Tác dụng |
|---|---|
| WASD / mũi tên | Di chuyển; hướng nhìn theo hướng di chuyển gần nhất |
| J / chuột trái | Tấn công về hướng nhìn |
| Space | Né và bất tử ngắn |
| F / chuột phải | Đỡ phía trước; bấm ngay trước đòn đánh để parry |
| Q | Xung kích vòng tròn, 32 thể lực, hồi 5 giây |
| R | Bình hồi máu; hồi 65 HP, hồi chiêu 4 giây |
| E | Đối thoại, tương tác dấu vết, mở lối tắt, chuyển map |
| I / Tab | Túi đồ; đổi vũ khí và trang phục đã sở hữu |
| M | Bản đồ vùng đất, các đường nối |
| Esc | Tạm dừng; lưu; cẩm nang; về màn hình đầu; thoát |

Đồ rơi có màu và nằm trên đất. Đi tới để nhặt. Vòng đỏ là dấu báo đòn đánh của quái. Đòn đánh cần mục tiêu trong tầm, đúng hướng và không có tường chắn. Mũi tên kiểm tra va chạm theo từng bước để không xuyên tường/mục tiêu.

## Nội dung đã có

- **3 vùng, 10 map**: Aster, Rừng phía nam, Đồi tưởng niệm, hai tầng hầm mỏ; Đèo gió bắc, Trạm lữ hành; Đầm sương tím, Phế tích vọng âm, Điện hắc nhật.
- Chuỗi nhiệm vụ Chương 0: khăn và ngựa gỗ → Edren → dược thảo → hầm mỏ/boss → thương nhân và manh mối Elara → nhận kiếm của cha và lên đường.
- Edren có lựa chọn đối thoại, ngày sau để lại ghế trống và bia mộ. Không có cảnh mô tả trực tiếp cái chết. Nếu người chơi nghỉ sớm, nhánh ghế trống vẫn cho tiếp tục nhiệm vụ.
- NPC: trưởng làng, Edren, Mara, thầy thuốc, thợ rèn, chủ quán trọ, thợ săn, thương nhân và người bán hàng. Mara tái xuất tại Trạm lữ hành.
- Đánh thường, né, guard/parry, xung kích, thể lực, bình máu; đòn báo trước của quái; 2 boss. Sói, dơi, bọ tinh thạch, cướp và bóng sương.
- 4 vũ khí (kiếm gãy, kiếm của cha, cung, trượng), 4 trang phục; đồ hiển thị trên nhân vật. Nâng vũ khí tối đa +5, chế bình, mua bình, rèn vũ khí và may trang phục bằng tài nguyên.
- Lên cấp, kinh nghiệm, giảm sát thương theo giáp; trọng thương làm giảm tốc độ. Chết rồi hồi sinh tại Aster, mất 10% vàng.
- Hoạt ảnh cơ bản: đứng, đi 4 hướng, đánh, né, đỡ, hồi máu, bị đánh, gục, hồi sinh, trọng thương và mệt. Đi bộ dùng sprite có sẵn; trạng thái khác dùng chuyển động cơ thể/vũ khí và hiệu ứng vẽ trong engine. Chưa phải bộ sprite vẽ tay riêng cho mọi động tác.
- Lưu tự động, tải lại, giữ đồ trên đất và quái còn sống khi đổi map; nghỉ qua ngày hồi lại quái thường. Boss cốt truyện không hồi lại.
- Âm hiệu tổng hợp nhẹ cho đánh, kỹ năng, nhặt đồ và rèn; chưa có nhạc nền hoặc lồng tiếng.

## Ranh giới nội dung

File zip do người dùng cung cấp là nguồn Chương 0. Biên địa/Cõi sương sau khi lên đường là phần gameplay mở rộng được sáng tác cho bản này, không phải chương tiếp theo đã có trong file gốc. Chưa kết luận số phận Elara, em trai hay Leni. Nhân vật và quái vẫn dùng đồ họa/hoạt ảnh đơn giản, chưa phải bản phát hành thương mại hoàn thiện.

Bản này tập trung Windows, bàn phím và chuột. Chưa làm bố cục chiến đấu cảm ứng hoặc kiểm chứng Android/iOS. Bản đồ ARPG độc lập được dựng bằng dữ liệu; bản đồ TileMap cũ không bị sinh lại hay ghi đè.

## Lưu trữ và kiểm chứng

Bản lưu: `%APPDATA%/Godot/app_userdata/My First RPG/aster_arpg_save_v1.json`. Ghi qua file tạm rồi đổi tên. Bắt đầu mới có màn hình xác nhận khi đã có bản lưu.

Kiểm tra tích hợp: chạy Godot với `--headless --path <project> res://scenes/arpg.tscn -- --arpg-test`. Bộ kiểm tra đi qua đầu vào di chuyển, va chạm, đòn đánh, parry, né, bình, kỹ năng, rèn, nhiệm vụ, mọi map, lưu/tải, đồ rơi, hồi sinh và nghỉ sớm. Bản lưu thử dùng tên khác, không đụng bản lưu người chơi.

Đã chạy kiểm tra tích hợp và chụp trực tiếp màn hình game, túi đồ, lò rèn, đối thoại, chiến đấu. Kiểm tra tự động xác nhận hệ thống; cân bằng độ khó và cảm giác chơi vẫn cần thêm phản hồi khi chơi thực tế.
