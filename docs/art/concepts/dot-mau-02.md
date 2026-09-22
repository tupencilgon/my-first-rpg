# Đợt mẫu 02 — cây cháy xém và Kael bốn hướng

Ngày 22/09/2026. Tạo bằng imagegen tích hợp.

## Quyết định của người dùng

Cây cối quanh Aster cũng cháy xém. Áp dụng cho bộ môi trường làng sau thảm họa: thân đen, cành khô, tán thưa nâu tro, mức cháy không đồng đều. Không mặc định toàn bộ rừng ở mọi khu vực đều cháy.

## File và tình trạng

- aster-style-v02-scorched.png: bản concept cập nhật, cây và bụi cháy xém; giữ Kael, ghế và khăn. Quan sát thấy mẫu vật liệu cỏ bên phải cũng đổi theo cảnh dù prompt yêu cầu giữ các ô; phù hợp hướng cây cỏ cháy nhưng không dùng ô đó làm tile thành phẩm.
- kael-turnaround-v01-draft.png: mẫu đứng bốn hướng xuống/lên/trái/phải. Chưa phải sprite sheet sử dụng trong game. Ảnh 2172×724, không phải 128×32; chưa có grid chính xác, chưa tách Body/Outfit và chưa có bước đi. Không tự thu nhỏ rồi coi là đạt.

Cả hai được lưu tại docs/art/concepts trong project và sao sang outputs để xem. Không sửa scene, bản đồ hoặc asset runtime. Không có kiểm thử chạy game cho các bản concept này.

## Việc tiếp theo

Chuẩn hóa nhân vật về đúng ô 32×32, khớp hình thể hiện có, palette gọn và alpha sạch; sau đó mới tách lớp và hoàn thiện sheet 16 frame. Bộ cây cần các phiên bản cháy nhẹ/cháy nặng/trơ cành cùng mật độ pixel với nhân vật.

## Prompt chỉnh cây

Edit this RPG pixel-art style board. Change ALL trees and vegetation in the village scene to show clear fire damage: charcoal-black trunks, exposed burnt branches, broken sparse crowns, singed brown-gray needles, only small patches of dark desaturated surviving foliage. Vary severity naturally: several almost bare burnt trees, others partially scorched. Singe surrounding grass and shrubs to muted brown ash especially near ruined houses; remove fresh white flowers near burned areas. Keep path readable and tree silhouettes readable against ground. It is the morning AFTER a fire: no active flames. Preserve the board layout, every building, camera, Kael in scene and all three character studies, the chair, scarf, and right-hand material swatches. Preserve the pixel-art style, resolution and lighting. Do not add text, new characters or objects. User specifically wants trees also scorched.

## Prompt Kael

Create a single very low resolution pixel-art character turnaround sheet for Kael, original top-down RPG teenage boy. This must look like a nearest-neighbor enlarged 128x32 pixel canvas: four equal 32x32 logical cells side by side, rendered as uniform hard square pixel blocks. Exactly four standing sprites: facing DOWN/front, UP/back, LEFT, RIGHT in that order. Each sprite fits entirely within its own 32x32 logical cell, aligned to same foot baseline, centered x=16, head top y=2, soles y=30. Compact proportions, head about 16 pixels wide, body 12 pixels wide; chestnut brown short hair, simple two dark eye pixels front view, blue tunic with visibly singed ragged brown hem, brown trousers, dark brown boots, bare hands. This is the same character idea as the reference but SIMPLIFY drastically to true 32x32 sprite construction. Use at most 20 flat colors overall, dark brown one-pixel contour, 3 tones per material, no soft light, no gradients, no antialiasing, no texture noise, no subpixels, no smooth curves. Genuine transparent background, no ground shadows, no labels, no grid lines, no props, no weapons. Pixel blocks must all be the same size. Output only this one horizontal turnaround sheet, wide 4:1 composition if supported, no decorative board. Reference image is for character identity/colors only, not resolution or layout.

