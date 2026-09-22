# Kael v02 — sửa mắt và bước đi ngang

- PNG walk: 128×128, 16 frame 32×32; idle: 128×32, 4 hướng từ trái sang phải (xuống/lên/trái/phải).
- Hai mắt hướng xuống tại x13 và x18, y12–13; giữ phần đầu giống nhau qua bốn frame.
- Hướng ngang giữ cùng đầu/thân, chân trước/sau đổi pha đối xứng, chân xa tối hơn. Không dùng lại hai hình contact giống nhau như bản cũ.
- Chu kỳ ngang: contact A, passing A, contact B, passing B. Tư thế đứng dùng sheet riêng. Vẫn là animation 4 frame có tính giật từng nấc của pixel art; chưa có 8-frame walk hoặc arm swing hoàn thiện.
- Tay ngang còn giữ cố định để ưu tiên ổn định thân và nhịp chân; đây là giới hạn mỹ thuật còn lại, không tuyên bố chuyển động đã hoàn hảo.
- Bản mặc sẵn đồ; không tương thích tự động với trang bị phân lớp cũ. Không sửa bản đồ chính.

## Kiểm tra

Godot 4.7.2 import và chạy thành công. Bài thử xác nhận di chuyển đúng bốn hướng, frame tiến khi đi và về idle khi thả phím. Đã xem ảnh render. Trang xem-animation.html có bản mới và v01 cạnh nhau để so sánh ở cùng tốc độ.

## Nguồn

Imagegen tích hợp tạo bản sửa; khâu chuẩn hóa và sửa lưới runtime giữ 24 màu, alpha 0/255. Hướng trái là đối xứng hướng phải. Bản v01 được giữ nguyên để so sánh.

## Prompt

Repair this actual low-resolution game sprite sheet, preserving Kael's identity and 4x4 layout. CRITICAL fixes: top row front/down view must have TWO clearly visible dark eyes, symmetric at the same height, with skin-colored face around both eyes, move fringe away from eyes just enough. Both eyes must survive reduction to 32x32. Keep exactly the SAME front face and head pixels in all four columns. Side walk rows currently limp and turn torso toward camera: redraw those two rows as strict side profiles with SAME head, face, shoulder/torso angle, hair, body height and hip position across all four columns. Only arms and legs change. LEFT row (third) faces left in ALL frames; RIGHT row (fourth) faces right in ALL frames. Four walking phases: column1 contact pose with near leg forward and far leg back, column2 passing pose legs crossing under hips, column3 opposite contact pose with far leg forward and near leg back, column4 opposite passing pose. Equal stride distances and equal leg lengths; both legs visible in contact poses, darker far leg, counter-swing arms. Frame3 must NOT duplicate frame1: swap near/far leg positions, preserve symmetric gait. Apply that same balanced gait to front and back rows too. Minimal motion head never changes shape or size. Preserve compact 32x32 logical pixel art, blue singed tunic and brown boots. Exactly 4 equal columns and 4 equal rows, per-cell same center and foot baseline. REAL transparent background, remove gray preview cell backgrounds, no ground shadows, no grid lines, no text. Maximum 24 colors, crisp square pixels, no gradients or smoothing. Prefer exact 128x128 PNG output; otherwise exact uniformly enlarged 128x128 grid. This is sprite repair not a new character design.

