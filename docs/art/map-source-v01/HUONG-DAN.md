# Aster — bộ ảnh nguồn map tách lớp v01

Bộ này dùng cho làng sau đám cháy, theo demo trong DESIGN.md. Tạo bằng imagegen tích hợp. Giữ nguyên ảnh nguồn; không tự convert, thu nhỏ, vẽ lại pixel, ghi đè atlas hoặc bản đồ hiện có.

## Những gì đã có

| File | Nội dung | Kích thước nguồn |
|---|---|---|
| 01_ground_base.png | Nền và bố cục đường đi, suối cạn, các vùng đặt nhà | 1254×1254 |
| 02_ground_materials.png | 16 mẫu vật liệu, bố cục 4×4 | 1254×1254 |
| 03_buildings.png | 2 nhà cháy không mái, tường ngang/dọc/góc, cửa, gỗ đổ, đống vụn: 8 mẫu | 1536×1024 |
| 04_burnt_trees.png | 3 cây cháy theo mức độ, gốc cây, thân đổ, bụi khô: 6 mẫu | 1536×1024 |
| 05_props.png | Ghế Edren, thùng, hòm, xe, 2 bia mộ, 2 hàng rào, khăn, ngựa gỗ, gỗ vụn, đá: 12 mẫu | 1448×1086 |
| 06_overhead_parts.png | 2 mảng mái, xà ngang, 2 cụm cành/tán, cành nhỏ: 6 mẫu | 1536×1024 |

File 03–06 có nền alpha trong suốt. Kiểm tra lấy mẫu cho thấy cũng có alpha trung gian; khi chuyển sang pixel art cần kiểm tra độ đục, làm sạch viền và bỏ quầng nếu có. Không tự động coi mọi pixel alpha > 0 là vật thể.

**Đây là bộ ảnh nguồn theo nhóm lớp, không phải PSD có layer, không phải sáu lớp cùng tọa độ có thể chồng lên khớp ngay, và chưa là atlas pixel 32px thành phẩm.** Các mái/cành ở file 06 là thư viện chi tiết độc lập, chưa đo khớp từng nhà/cây ở file 03/04.

## Bố cục map đề xuất

Dùng 01 để tham khảo bố cục; khi dựng lại có thể đặt canvas 40×40 ô, mỗi ô 32px = 1280×1280. Ảnh nguồn thực tế là 1254×1254, không phải 1280×1280 và không khớp dữ liệu map hiện tại.

- Góc tây nam: suối cạn, chỗ Kael tỉnh dậy.
- Đường đất từ suối đi vào khoảng trống giữa làng.
- Hai bên đường: nhà cháy. Đặt nhà Kael ở phía tây; nhà Edren ở phía đông với khoảng trống trước ghế.
- Nhánh đông bắc: lối lên nghĩa trang. Chừa vùng trống để đặt bốn mộ gia đình Edren, dùng lại hai mẫu bia.
- Cây cháy ở rìa và giữa các khu nhà, giữ đường chính thoáng khoảng 2–3 tile.
- Ghế Edren giữ nguyên vị trí cả hai ngày; chỉ bỏ NPC khỏi ghế.
- Không có hang động hoặc vùng chiến đấu trong bộ demo này.

Đây là bố trí gợi ý cho lần vẽ tiếp theo, không phải yêu cầu xóa/vẽ lại bản đồ đang có.

## Thứ tự lớp khi ghép

| Lớp | Đặt gì | Quy tắc |
|---|---|---|
| Ground | Đất, tro, nền sàn, lòng suối | Nằm dưới mọi vật thể |
| GroundDetail | Vệt cháy, đất mới, mảnh vụn phẳng | Không chặn đường trừ khi cố ý |
| Objects + nhân vật | Ghế, thùng, gốc cây, bia mộ, thân nhà và NPC | Sắp trước/sau theo vị trí chân; va chạm chỉ ở phần chạm đất |
| Overhead | Mái, cành/tán cần che người đi phía dưới | Chỉ tách phần thực sự cần che; không đặt mọi cây ở lớp luôn nổi trước nhân vật |
| FX | Khói, than hồng | Làm riêng sau; chưa nằm trong gói này |
| UI | Chữ, chỉ dẫn tương tác | Không vẽ vào ảnh map |

Một cây nguyên trong file 04 có thể dùng như một object sắp thứ tự theo gốc. Nếu cần tách tán, cắt từ CHÍNH cây đó và giữ chung canvas/anchor để khớp; đừng ghép tùy ý tán file 06 lên thân file 04 rồi cho rằng sẽ khít.

Tương tự, nhà cháy có tường trước che lối đi cần tách phần tường trước trong công cụ vẽ. Hai nhà nguyên là nguồn thiết kế; chưa có va chạm hay logic đi vào nhà. Ảnh PNG không lưu va chạm, vị trí NPC hoặc nhiệm vụ.

Project hiện có Ground và Blocking. Bảng lớp trên là đề xuất tổ chức khi tích hợp; mình chưa thêm node hoặc sửa scene. Va chạm phụ thuộc cấu hình tile/object, không chỉ tên lớp.

## Kích thước đích gợi ý sau khi bạn convert

Giữ cùng mật độ pixel 32px với Kael. Kích thước canvas phải phù hợp vật thể, không thu mọi thứ về 32×32.

| Loại | Canvas đích tham khảo | Điểm neo |
|---|---|---|
| Tile mặt đất | 32×32 | Lưới tile |
| Ghế, thùng, hòm, bia nhỏ, bụi, gốc cây | 32×32 hoặc 32×64 nếu cao | Giữa chân vật thể |
| Khăn / ngựa gỗ | 32×32, hình nhỏ trong ô | Điểm tiếp đất |
| Hàng rào/gỗ đổ | 64×32 hoặc 32×64 | Chân đoạn rào |
| Xe | 64×64 | Giữa vùng bánh chạm đất |
| Cây | 64×96 hoặc 96×128 | Giữa gốc |
| Nhà | 128×128 hoặc 128×160 | Chân công trình; cần tách phần trước/sau khi dùng |
| Mái/cành | Theo canvas công trình/cây ghép cùng | Chung anchor với phần dưới |

Số pixel cụ thể cần chốt khi nhìn cạnh Kael. Các sheet nguồn không có ô cắt đồng đều và khoảng trống được tạo tự do; cần chọn từng vật thể.

## Cách chuyển bằng LibreSprite / Aseprite

1. Mở ảnh nguồn, khoanh chọn MỘT vật thể, sao chép sang file trong suốt mới. Giữ bản gốc.
2. Thu nhỏ giữ tỷ lệ, dùng Nearest Neighbor để làm bản tham khảo. Không thu nhỏ nguyên cả sheet rồi lấy mỗi ô làm asset.
3. Đưa vật thể vào canvas đích, căn gốc/chân. Sửa chi tiết và giảm số màu ở độ phóng lớn bằng bút 1px.
4. Xem ở 100% cạnh nhân vật 32×32. Thống nhất kích thước đá, vân gỗ, nét viền và hướng sáng trên trái.
5. Dọn pixel thừa và alpha. Với sprite/tile đặc, dùng nền trong suốt và phần vật thể đủ đục; tránh quầng sáng tối bám theo ảnh.
6. Tile nền: thử lặp 3×3, chỉnh cả bốn mép. Hai mẫu chuyển vật liệu ở hàng cuối file 02 chỉ minh họa, CHƯA phải bộ autotile đủ cạnh/góc.
7. Nếu tách mái/tán: nhân đôi cùng canvas, giữ phần dưới ở lớp một và phần trên ở lớp hai. Đừng tự crop sát từng lớp làm mất điểm căn.
8. Lưu nguồn chỉnh sửa nhiều lớp trong định dạng ứng dụng; xuất PNG riêng từng lớp/từng asset.
9. Khi ghép Godot, chọn nearest, thêm va chạm cho phần chân, thử nhân vật đi trước/sau. Không sửa tọa độ tile cũ khi thay hình.

## Kiểm tra đã làm và còn lại

Đã xem từng ảnh; sửa lại nền để loại bụi/cây nổi; kiểm tra kích thước PNG và lấy mẫu alpha; giữ riêng các nhóm hình. Chưa kiểm tra tính liền mạch tile, grid thật, palette giới hạn, anchor, mái khớp nhà hoặc va chạm trong game — những bước đó thuộc khâu convert/tích hợp bạn muốn tự làm.

Màu khăn đỏ cháy đã theo mẫu trước. Ngựa gỗ là hình đề xuất cho đồ chơi của em, chưa phải thay đổi nội dung cốt truyện.

Bản sao bộ nguồn lưu tại docs/art/map-source-v01 trong project. Không thay main.tscn hay assets/tiles/terrain.png.

