# Kael — bộ di chuyển v01

## File dùng được

- kael_walk_v01.png: PNG RGBA 128×128, 4 cột × 4 hàng, ô 32×32, nền trong suốt, tối đa 24 màu đặc.
- Hàng: xuống, lên, trái, phải. Cột: đứng, bước A, đứng, bước B. Hai ô đứng dùng cùng hình để giữ tư thế ổn định.
- 16 file frame rời đi kèm. Hướng trái đối xứng từ hướng phải, không phải thiết kế bất đối xứng riêng.
- kael_frames.tres trong project: bốn animation walk_* tốc độ 8 fps và bốn idle_*.
- Scene thử: res://scenes/art_preview/kael_preview.tscn. Mở scene rồi F6; WASD hoặc phím mũi tên di chuyển. F5 vẫn chạy bản đồ hiện có.

## Phạm vi và giới hạn

Đây là bản nhân vật mặc sẵn đồ, dùng được trong scene thử. Chưa tách Body/Outfit; không chồng outfit cũ lên PNG này. Chưa thay nhân vật của main.tscn. Bộ mũ, vũ khí và trang phục cũ chưa được kiểm tra tương thích với hình thể mới. Các dáng nghiêng còn thay đổi nhẹ góc thân giữa bước, cần tinh chỉnh mỹ thuật ở bản sau nếu muốn chuyển động chặt hơn. Không có chạy nhanh, tấn công hoặc động tác cốt truyện trong gói này.

Ảnh AI gốc đã được cắt theo vùng nhân vật, bỏ phần thừa giữa hàng, căn chân ở y30, chuẩn hóa mỗi frame cao 29 pixel, xuất nearest-neighbor, alpha nhị phân và bảng màu 24 màu. Đây là công đoạn đóng gói/chuẩn hóa, không phải chứng minh ảnh AI gốc đã nằm đúng lưới. Đã xem sheet sau chuẩn hóa và ảnh render Godot.

## Kiểm tra

Godot 4.7.2 import thành công. Scene xác nhận 4 hướng × 4 frame 32×32. Bài thử đầu vào kiểm tra di chuyển đúng hướng, frame thay đổi trong khi đi và về idle frame 0 khi thả phím. Đã chụp ảnh bằng OpenGL Compatibility trên máy này. Chưa kiểm tra trên điện thoại và chưa ghép vào map chính.

## Công cụ và prompt

Tạo hình bằng imagegen tích hợp, chuẩn hóa PNG cục bộ và thử bằng Godot.

Production sprite sheet for the referenced Kael character, full body dressed in singed blue tunic, brown pants, brown boots, chestnut hair. ONE square PNG with real transparent background, exactly FOUR columns and FOUR rows, 16 sprites total, equal square cells, no gaps between cells and no margins around sheet. Logical canvas 128x128 pixels, each cell 32x32 pixels; if generating enlarged, use EXACT integer nearest-neighbor magnification of this logical grid. Each character centered at x16 in cell, feet baseline y30, top hair y2, head width about 16 pixels, body width 12 pixels. Strict 20-color palette, flat pixel clusters, minimal details, no gradients, no antialias. ROW 1 all FACE DOWN/front, ROW 2 all FACE UP/back showing back of head and back of tunic with NO face, ROW 3 all FACE LEFT/profile, ROW 4 all FACE RIGHT/profile. COLUMNS same walking cycle in every row: 1 neutral standing feet together arms relaxed, 2 left leg steps forward with opposing arm swing, 3 neutral passing stance feet together, 4 right leg steps forward with opposing arm swing. Make steps DISTINCT with boot displacement and natural counter-swing, not identical duplicates. Keep head size, costume, character height and root anchor absolutely consistent across all 16 frames. No weapons, no shadow, no floor, no checkerboard painted into image, no labels or lines. This is usable animation sheet layout, not concept board. Simplify the reference drastically to actual 32x32 character; reference only establishes identity and outfit. Output exact 128x128 PNG if possible.

