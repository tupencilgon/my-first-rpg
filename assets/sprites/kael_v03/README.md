# Kael — bộ di chuyển v03

Giống hệt `kael_v02` **trừ khuôn mặt**. Sinh ra bằng
`python tools/retouch_kael_face.py` (đọc v02, ghi v03).

## Đã sửa gì

| | v02 | v03 |
|---|---|---|
| Mắt (hướng xuống) | 1px × 2px, cột 13 và 18 | **2px × 2px**, cột 13–14 và 17–18 |
| Mắt (hướng nghiêng) | 1px | **2px**, nới về phía trước mặt |
| Mắt (hướng lên) | không có | không có (đúng — nhìn từ sau đầu) |
| Miệng | không có | **2px**, cột 15–16, hàng 15 |
| Số màu | 20 | 21 (thêm màu miệng) |

## Vì sao phải sửa

v02 **có** mắt, nhưng mỗi mắt rộng đúng 1 pixel và dùng chính màu viền
(`#160f0c`). Ở cỡ game — 1 pixel sprite = 3 pixel màn hình — chúng dính vào
bóng tóc hai bên và khuôn mặt đọc ra như một mảng da trống.

Nới mắt lên 2px chừa được khoảng da ở cả hai bên (cột 12 và 19), nên mắt tách
hẳn khỏi mép tóc.

## Cách script tìm ra mắt

Không viết cứng toạ độ. Nó tìm theo **dấu hiệu hình học**: một pixel tối mà
hai bên trái/phải đều là màu da, nằm trong vùng mặt (hàng 10–18), và xếp thành
cột liên tục cao ít nhất 2 pixel.

Nhờ vậy nó chạy đúng cho cả 16 frame dù đầu nhân vật xê dịch giữa các frame.

Ba điều kiện trên đều cần thiết — bản đầu chỉ dùng điều kiện "tối, hai bên là
da" thì bắt nhầm khe giữa hai bàn tay và mép tóc chọc vào mặt: hướng xuống ra
3 mắt, hướng lên ra 1 mắt.

## Kiểm tra

- Số mắt tìm được: hướng xuống 2, hướng lên 0, mỗi hướng nghiêng 1 — nhất quán
  cả 4 cột của mỗi hàng
- Đọc lại dữ liệu pixel để xác nhận mắt ở cột 13–14 và 17–18, miệng ở 15–16,
  đối xứng quanh tâm 15,5
- `tools/check_asset.py`: 128×128, đúng độ phân giải gốc, không viền mờ,
  21 màu, nền trong suốt
- Chạy trong Godot, chụp đủ 4 hướng

## Giới hạn

Vẫn là sprite **đã mặc sẵn quần áo** — chưa tách Body/Outfit. Không chồng lớp
Outfit lên file này. Chu kỳ bước ở hướng xuống và lên vẫn ít chuyển động hơn
hai hướng nghiêng; đó là vấn đề của bản gốc, script này không sửa.
