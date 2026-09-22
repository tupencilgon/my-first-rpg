# Bộ mẫu hình ảnh Aster — v01

Ngày: 22/09/2026.
Công cụ: imagegen tích hợp, không dùng CLI/API bên ngoài.
File: aster-style-v01.png.
Trạng thái: bản phác định hướng; chưa là asset dùng trực tiếp trong Godot.

## Nội dung

Một cảnh làng cháy, Kael nhìn trước/sau/nghiêng, ghế gỗ, khăn mẹ và bốn mẫu vật liệu. Kael tóc nâu, áo xanh cháy xém; khăn mẹ tạm chọn đỏ nhạt. Đây là lựa chọn mỹ thuật đề xuất, không thêm tình tiết cốt truyện.

## Đánh giá

Bản mẫu truyền đạt được không khí làng cháy, lối đi dễ đọc và sự tương phản giữa Kael với nền. Cần giản lược tóc, mặt và bề mặt vật liệu để phù hợp ô nhân vật 32×32. Mẫu nền chứa đá/gỗ/hoa nổi bật nên chỉ tham khảo vật liệu, không cắt ra làm tile lặp. Góc nhìn một số công trình có độ chéo lớn, cần đưa về top-down nhất quán khi sản xuất. Khăn cần làm rõ góc cháy. Ảnh nền đặc, chưa có các lớp Body/Outfit riêng và chưa kiểm tra animation.

Không thay đổi asset chạy game hay dữ liệu bản đồ. Bản sao trong project: docs/art/concepts/aster-style-v01.png.

## Đầu ra sản xuất

- PNG RGBA: sheet nhân vật 128×128, lưới 4×4, ô 32×32; các lớp tách riêng.
- PNG: atlas tile, đạo cụ, vật phẩm, UI và hiệu ứng theo kích thước của kế hoạch.
- PNG xem trước: bảng asset và cảnh ghép.
- Markdown: thông số, prompt, tình trạng kiểm tra và cách sử dụng.
- Tài nguyên Godot .tres/.tscn được bổ sung ở bước tích hợp khi cần.
- Không cam kết file .aseprite nhiều layer từ ảnh PNG; bản này không có nguồn Aseprite.

## Bước tiếp theo

Làm mẫu Kael đúng ô 32×32 và kiểm tra khớp Body/Outfit trước khi nhân rộng đủ bốn hướng/animation. Ảnh định hướng không được tính là hoàn tất bộ sprite.

## Prompt đã dùng

Use case: stylized-concept. Asset type: ONE cohesive pixel-art art-direction board for an original Godot top-down RPG, a preview reference NOT a production sprite atlas. Create a polished landscape board with a large top-down gameplay-style scene on the left and neatly separated character/prop studies on the right, restrained dark neutral background, no text or labels. Scene: Aster, a modest medieval mountain village the morning after a fire. Charred wooden house frame, low broken stone walls, ash ground transitioning into a dirt footpath and muted moss green grass, a few conifers, a simple EMPTY wooden chair beside a ruined home, quiet sparse smoke. A readable clear walking route; intimate restrained grief, no gore, no bodies, no enemies, no dramatic flames. Kael is a teenage boy with short chestnut brown hair, blue weathered tunic with a singed hem, brown trousers and boots, no weapon or helmet. Use compact large-headed JRPG proportions fitting a 32x32 logical sprite, uncomplicated face, consistent dark selective outline. Right studies: same Kael in front, back and side standing views, a standalone simple wooden chair, a small folded faded warm red mother's scarf with one scorched corner, and four square texture swatches showing grass, dirt, ash, charred timber. All studies share materials/palette with scene. Genuine crisp low-resolution pixel-art appearance, uniform square pixel clusters, limited muted 32-48 color aesthetic, 3 tones per material, upper-left lighting, no painterly brushwork, no blur, no smooth gradients, no tiny noisy detail, no isometric perspective, no modern objects, no UI or typography. Composition should feel like a thoughtfully art-directed small indie game, not a realistic illustration. Character and props easily distinguishable from ground. Keep scale and pixel density consistent throughout.

