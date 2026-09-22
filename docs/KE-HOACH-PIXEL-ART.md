# Kế hoạch pixel art — My First RPG

Ngày lập: 22/09/2026. Người phụ trách hình ảnh: Codex.

## 1. Mục tiêu và phạm vi

Codex đảm nhiệm toàn bộ quá trình làm pixel art: định hướng hình ảnh, thiết kế nhân vật, sprite và animation, tile môi trường, công trình, vật thể, vật phẩm, hiệu ứng, giao diện, xuất file và kiểm tra khi đưa vào Godot. Người dùng định hướng nội dung và góp ý hình ảnh; không cần tự vẽ lại ảnh AI để hoàn thành asset.

Mốc sản xuất đầu tiên là **toàn bộ art cho demo 10 cảnh trong DESIGN.md**. Sau demo mới mở rộng sang phần còn lại của Chương 0. Chương I trở đi chưa có thiết kế chi tiết trong thư mục, nên chỉ lập quy trình tiếp nhận, không tự bịa danh sách asset hoặc tuyên bố đã bao quát toàn bộ game chưa được viết.

Tài liệu này là kế hoạch; chưa có art thành phẩm mới. Quy chuẩn đã tồn tại được giữ nguyên. Các lựa chọn mỹ thuật và số lượng bổ sung bên dưới là đề xuất ban đầu, được điều chỉnh sau bộ mẫu đầu tiên.

## 2. Kết quả đọc project

- Đã đọc README.md, DESIGN.md, CLAUDE.md, cốt truyện Chương 0, cấu hình project, hai scene, hai script, công cụ sinh và kiểm tra art; đã xem sprite Body, Outfit và atlas địa hình.
- Project khai báo Godot 4.7, GDScript, GL Compatibility; khung hình gốc 640×360, phóng nguyên lần, lọc nearest.
- Có di chuyển bốn hướng, va chạm, camera, joystick cảm ứng, bốn lớp Body / Outfit / Helmet / Weapon. Đây là nhận xét từ mã nguồn, chưa phải kết quả chạy thử trong lượt lập kế hoạch.
- Có sáu PNG nhân vật/trang bị và một atlas địa hình 128×128 gồm 16 tile. Tất cả là placeholder; có file không có nghĩa là đã đạt chất lượng art cuối.
- main.tscn đã chứa dữ liệu bản đồ ở Ground và Blocking. Phải giữ công sức vẽ hiện có; không sinh lại hoặc ghi đè map.
- Chưa có các scene/hệ thống hội thoại, NPC, nhặt đồ, trạng thái cốt truyện, chuyển ngày, menu và lưu/tải trong các file đã kiểm tra.
- Demo theo DESIGN.md không có chiến đấu hay hầm mỏ. Câu “demo gồm 1 làng + 1 hang động” trong CLAUDE.md không khớp mô tả chi tiết; kế hoạch lấy DESIGN.md làm căn cứ.
- Bảng art hiện tại chưa tính đầy đủ cạnh nối địa hình, module nhà, tư thế kể chuyện và trạng thái giao diện. Không dùng con số khoảng 140 frame cũ làm tổng khối lượng cuối.

## 3. Định hướng hình ảnh đề xuất

**Trung cổ miền núi, buồn và lặng sau thảm họa; hình rõ ở kích thước nhỏ.** Giữ tỷ lệ nhân vật phù hợp ô 32×32 hiện có. Kael phải đọc được là thiếu niên; Edren cần tuổi tác và dáng ngồi riêng, không chỉ là Kael đổi màu áo.

- Rừng: xanh rêu, đất nâu, đá xám lạnh. Nền có ít chi tiết tương phản mạnh.
- Aster cháy: nâu than, tro xám, gỗ đen; điểm ấm nhỏ ở than hồng. Không phủ đen toàn cảnh làm mất đường đi.
- Cập nhật theo người dùng: cây cối quanh làng cũng cháy xém, thân đen, cành khô, tán nâu tro thưa; có nhiều mức cháy, không dùng cây xanh nguyên vẹn giữa vùng cháy.
- Nghĩa trang: xanh xám, đất mới, đá nhạt; nhiều khoảng trống hơn làng.
- Nhân vật và đồ tương tác có độ tương phản tách nền. Màu nhấn của khăn mẹ được giữ nhất quán giữa đồ trên đất, icon và mọi cảnh xuất hiện.
- Ánh sáng mặc định từ trên trái. Mỗi vật liệu dùng khoảng 3–4 sắc độ; khởi đầu với bảng màu chung khoảng 32–48 màu, không bắt mọi asset phải sử dụng toàn bộ.
- Viền có chọn lọc, cụm pixel rõ; không làm mịn, gradient mềm hay nhiễu li ti trên sprite/tile. Hiệu ứng khói có quy tắc riêng.
- Giữ cách kể chuyện Edren bằng ghế trống và bia mộ, đúng bản thảo không có hình ảnh mô tả trực tiếp cái chết.

## 4. Quy chuẩn file và tương thích

| Loại | Quy chuẩn |
|---|---|
| Sprite di chuyển phân lớp | PNG RGBA 128×128; 4 cột × 4 hàng, mỗi ô 32×32 |
| Hướng | Hàng 0 xuống, 1 lên, 2 trái, 3 phải |
| Chu kỳ đi | Đứng – bước chân thứ nhất – đứng – bước chân còn lại; frame 0 dùng khi đứng yên; hiện phát 8 frame/giây |
| Khớp lớp | Bám GEOM và điểm chân hiện có; kiểm tra cả 16 ô, không chỉ hướng trước |
| Tư thế kể chuyện | File riêng, ô 32×32; có thể chứa sprite ghép sẵn cho tư thế cố định, không chèn vào sheet đi bộ |
| Tile cũ | Giữ atlas 128×128 và nguyên tọa độ 16 ô khi thay hình |
| Tile mới | Atlas riêng; ô 32×32, thêm source mới khi tích hợp, không xáo lại atlas cũ |
| Vật thể lớn | Kích thước bội số 32, như 32×64, 64×64, 64×96; mật độ pixel như nhân vật |
| Đồ nhặt/icon | Canvas 32×32 trong suốt; hình có thể nhỏ hơn ô |
| Giao diện | Khung chia 9 vùng co giãn; nút có các trạng thái cần thiết, chữ render riêng |
| Nền trong suốt | Sprite, props, icon dùng alpha sạch; không có nền caro được vẽ vào ảnh |
| Phóng to xem | Nearest ×2/×3; kiểm tra thêm ở kích thước gốc |

Lưu ý: cùng kích thước ảnh chỉ bảo đảm cách cắt frame, không tự bảo đảm quần áo khớp người. Nếu đổi hình thể, phải cập nhật tất cả lớp bị ảnh hưởng. Cũng không thể thêm animation nằm/ngồi chỉ bằng thay PNG: code hiện chỉ biết đi và đứng.

Giữ vùng va chạm gần chân; vật thể cao cần phân biệt phần chân chặn đường và phần tán/mái che nhân vật. Hiện thứ tự lớp nhân vật là cố định, nên trang bị về sau cần kiểm tra vũ khí ở phía trước/sau theo hướng.

## 5. Danh mục sản xuất demo

Các số dưới đây là ngân sách asset ban đầu, không phải số đã hoàn thành. “Ô” là một frame/layer hoặc một tile 32×32; một file có thể chứa nhiều ô. Không cộng file, tư thế, module và ô sprite thành một tổng thiếu nhất quán.

### A. Nhân vật

| Mã | Hạng mục | Khối lượng ban đầu | Mức ưu tiên |
|---|---|---|---|
| CHAR-01 | Kael body hoàn thiện | 16 ô | Bắt buộc |
| CHAR-02 | Trang phục cháy xém | 16 ô, khớp CHAR-01 | Bắt buộc |
| CHAR-03 | Kael nằm, chống tay, quỳ, đứng dậy | 4–6 ô, một hướng dàn cảnh | Bắt buộc cho mở đầu |
| CHAR-04 | Kael tìm trong đổ nát/nhặt đồ | 4–6 ô, một hướng dàn cảnh | Bắt buộc nếu dựng động tác |
| NPC-01 | Edren body và outfit riêng | 2 sheet = 32 ô phân lớp | Bắt buộc |
| NPC-02 | Edren ngồi cúi đầu | 2–4 ô ghép sẵn, khớp ghế | Bắt buộc |
| NPC-03 | Ba dân làng có hội thoại | 3 outfit = 48 ô; dùng chung body phù hợp | Bắt buộc |
| NPC-04 | Một dân làng nền để đủ 5 NPC cùng Edren | 1 outfit = 16 ô | Sau nhóm hội thoại |
| NPC-05 | Tư thế ngồi, bị thương, tìm kiếm cho dân làng | 6–12 ô dùng theo bố cục cảnh | Sau bộ mẫu |

NPC khác tuổi/giới hoặc hình thể không phù hợp body chung sẽ có body riêng; không dùng lại dáng Kael bằng mọi giá. Chỉ thêm sheet cần cho NPC thực sự xuất hiện. Chân dung hội thoại chưa bắt buộc; không sản xuất hàng loạt khi giao diện chưa cần.

### B. Địa hình và công trình

| Mã | Hạng mục | Khối lượng ban đầu |
|---|---|---|
| ENV-01 | Làm lại atlas hiện tại | 16 ô, giữ tọa độ |
| ENV-02 | Biến thể cỏ, đất, tro, sỏi để giảm lặp | 8–12 ô |
| ENV-03 | Cạnh/góc nối cỏ–đất, đất–tro, lòng suối cạn | 24–48 ô, chốt sau thử ghép |
| ENV-04 | Lòng suối cạn, bờ, mép dốc | 12–20 ô/module nhỏ, tránh trùng ENV-03 |
| ENV-05 | Nhà cháy: móng, tường vỡ, cửa, cột, xà, mái sập | 16–24 module; mỗi module có thể chiếm nhiều ô |
| ENV-06 | Cây rừng, cây cháy, gốc cây, đá, bụi | 8–12 props nhiều kích thước |
| ENV-07 | Nghĩa trang: lối đi, rào, cổng, đất mộ mới | 8–12 module/props, dùng lại nền phù hợp |

Nhà Kael và nhà Edren dùng chung vật liệu nhưng có hình dáng đủ khác để nhận ra. Tán cây, mái và đồ cao không ép tất cả thành một tile chặn kín. Hoa, đá lẻ, nấm và vật thể nổi bật tách khỏi nền lặp.

### C. Đạo cụ và vật phẩm cốt truyện

- PROP-01: đống đổ nát nhà Kael, hai trạng thái trước/sau tìm kiếm.
- PROP-02: ghế Edren, một asset giữ nguyên vị trí giữa ngày đầu và ngày sau; sprite Edren là lớp riêng.
- PROP-03: khu mộ gia đình Edren: bốn dấu mộ có thể dùng chung 2–3 mẫu bia; tên xuất hiện trong hội thoại, không nhét chữ khó đọc lên tile.
- ITEM-01: khăn mẹ cháy một góc, một sprite trên đất + một icon 32×32.
- ITEM-02: đồ chơi gỗ, một sprite trên đất + một icon 32×32; hình cụ thể là quyết định mỹ thuật cần chốt trong bộ mẫu.
- PROP-04: 6–10 đồ cảnh như xe hỏng, bánh xe, thùng vỡ, bao vải, cọc rào và gỗ vụn.

### D. Giao diện và hiệu ứng

- UI-01: khung hội thoại, bảng tên, dấu tiếp tục, lựa chọn thường/chọn/nhấn.
- UI-02: bảng xem kỷ vật, ô vật phẩm, con trỏ và nút đóng/quay lại.
- UI-03: chỉ dẫn tương tác PC và nút cảm ứng; thiết kế vùng bấm phù hợp trước khi chốt phần hình.
- UI-04: menu chính, tạm dừng, lưu/tải và các trạng thái nút; ưu tiên dùng chung thành phần.
- UI-05: bố cục mở đầu, chuyển ngày, kết demo; chữ hiển thị bằng font có đủ dấu tiếng Việt.
- FX-01: khói 4–6 frame và than hồng 3–4 frame, hạn chế số điểm phát.
- FX-02: dấu báo tương tác 2–4 frame nếu dấu tĩnh chưa đủ rõ; không lấp lánh liên tục làm mất không khí.
- BRAND-01: icon game và hình menu hoàn thiện sau khi phong cách đã ổn định. Chưa tự đặt tên thương mại mới.

## 6. Mười cảnh và bộ art tương ứng

| Cảnh | Asset chủ đạo | Điều cần nhìn rõ |
|---|---|---|
| 1. Tỉnh dậy | Suối cạn, đá/bờ, Kael nằm và đứng lên | Người chơi thấy ngay nhân vật |
| 2. Đường rừng | Cỏ/đất nối, cây, mép dốc | Đường về làng dễ đọc |
| 3. Làng cháy | Nhà cháy, tro, khói, NPC nền | Hậu quả thảm họa, lối đi không lẫn đống chặn |
| 4. Nhà Kael | Tường còn lại, đổ nát, khăn và đồ chơi | Nhà và đồ cần tìm có điểm nhận diện |
| 5. Hỏi dân làng | Ba NPC, hộp thoại, chỉ dẫn tương tác | NPC khác nhau bằng nhiều hơn màu áo |
| 6. Edren | Edren ngồi, ghế, nhà cháy, lựa chọn thoại | Dáng người và khoảng trống tạo cảm xúc |
| 7. Ngày hôm sau | Màn chuyển cảnh và chữ | Không cần vẽ thêm cả bộ làng |
| 8. Ghế trống | Cùng ghế và cùng bố cục cảnh 6 | Sự vắng mặt đủ rõ, không cần mô tả cái chết |
| 9. Nghĩa trang | Bốn mộ, đất mới, lối đi, hội thoại | Mộ gia đình Edren dễ tìm |
| 10. Kết demo | Màn đen và chữ | Theo DESIGN.md; không thêm cảnh Chương I |

## 7. Thứ tự thực hiện và điều kiện hoàn tất

1. **Bộ mẫu phong cách:** Kael mặc đồ cháy xém nhìn trước/sau/nghiêng, 4 tile đại diện, ghế Edren, khăn mẹ và một cảnh ghép mẫu. Mục tiêu là nhìn được nhân vật và môi trường cạnh nhau ở cỡ chơi thật. Có thể xem góp ý rồi sửa hướng mỹ thuật trước khi nhân rộng.
2. **Khóa chuẩn nhân vật:** hoàn thành đủ bốn hướng và lớp trang phục của Kael; thử bước đi, đứng và chân chạm đất. Chốt palette, silhouette, anchor và cách xuất.
3. **Bộ môi trường sử dụng được:** atlas cũ, cạnh nối, nhà cháy, rừng và nghĩa trang. Thử ghép mảng 3×3/5×5 để tìm đường nối và họa tiết lặp. Lập bảng mẫu để người dùng tiếp tục vẽ map trong editor.
4. **Bộ kể chuyện:** Edren, dân làng, động tác đặc biệt, ghế, mộ, đổ nát và kỷ vật. Đối chiếu đủ 10 cảnh, thử riêng cảnh ghế có người → ghế trống.
5. **Giao diện và hiệu ứng:** thử hội thoại tiếng Việt, lựa chọn dài, icon ở cỡ gốc và giao diện cảm ứng. Chỉ cần các thành phần phục vụ demo.
6. **Tích hợp và rà soát:** kiểm tra trong Godot, thứ tự trước/sau vật thể, va chạm, animation, khung hình PC và màn hình di động. Chạy lại đúng đoạn thay asset để tránh lỗi bị che bởi ảnh xem trước.
7. **Chốt gói demo:** mọi asset bắt buộc đã có file, đường dẫn, trạng thái kiểm tra và nơi sử dụng. Asset vẫn là concept hoặc còn lỗi không được đánh dấu hoàn tất.

Phụ thuộc phía lập trình: bước 4 cần trạng thái animation và NPC; bước 5 cần hội thoại và điều khiển; bước 6 cần cờ ngày/nhặt đồ. Nếu hệ thống chưa có, xem trước art trong scene kiểm tra riêng, ghi rõ chưa tích hợp vào luồng chơi. Việc nhận phần art không tự đồng nghĩa các hệ thống gameplay đã được làm xong.

## 8. Quy trình tạo và quản lý asset

Codex làm cả concept và khâu đưa ảnh về dạng dùng được trong game. Dùng công cụ tạo ảnh cho bản phác và raster theo từng hạng mục; không coi một tấm ảnh trông giống pixel art là sprite sheet hoàn thiện. Kiểm tra kết quả, chỉnh sửa có mục tiêu, tách/căn frame và chuẩn hóa khi cần. Nếu công cụ không giữ đúng lưới hoặc hình thể, ghi rõ asset chưa đạt và tiếp tục sửa, không giao phần vẽ lại cho người dùng như điều kiện mặc định.

Mỗi asset đi qua: **cần làm → bản phác → đang hoàn thiện → đạt kiểm tra file → đạt kiểm tra trong game → hoàn tất**.

- Lưu ảnh tham chiếu, prompt và bản nháp tách khỏi thư mục asset đang được game sử dụng.
- Bản mới dùng hậu tố phiên bản cho tới khi được chọn làm bản sử dụng; giữ khả năng quay lại bản cũ.
- PNG thành phẩm nằm trong assets/sprites, assets/tiles và các thư mục props, items, ui, fx được bổ sung khi sản xuất.
- Mỗi đợt có bảng xem trước và bản ghi: mã asset, kích thước, ô/frame, palette, anchor, đường dẫn, cảnh dùng, trạng thái kiểm tra.
- Không chạy công cụ gen_placeholder_art.py để ghi đè art thật. Khi bắt đầu tích hợp, cần thêm bảo vệ hoặc tách đầu ra placeholder trước khi sử dụng lại công cụ đó.
- Không sinh lại main.tscn. Việc thêm asset/TileSet và scene thử phải giữ dữ liệu map người dùng đã vẽ.
- Sau thay đổi code/scene/asset, kiểm tra và mở editor theo hướng dẫn project; chỉ lập tài liệu không cần mở thêm editor.

## 9. Tiêu chí kiểm tra

1. Đúng kích thước, hướng, số frame, trong suốt và đường dẫn.
2. Body/Outfit không lệch, không hở bất thường, không rung đầu/chân ngoài chủ ý; nhân vật không bị cắt mép ô.
3. Tile nối liền; cỏ/tro không có chi tiết lặp gây chú ý; tile cũ giữ nguyên ý nghĩa và tọa độ.
4. Sprite đọc rõ ở 100%; bản phóng lớn không thay thế kiểm tra trong cảnh thật.
5. Vật nhặt nổi vừa đủ; đường đi và vùng chặn khớp hình; cây/mái che đúng thứ tự.
6. Khung thoại đủ chỗ tiếng Việt có dấu, lựa chọn dài và nút cảm ứng; chữ không bị vẽ cứng vào ảnh.
7. Hiệu ứng không che lời thoại, điểm tương tác hoặc gây nhấp nháy quá mức.
8. Công cụ check_asset.py chỉ là bước kiểm tra cơ học: giới hạn số màu/kích thước không chứng minh ảnh đẹp, frame đúng hoặc animation tốt. Không tự resize một concept rồi đánh dấu đạt.
9. Import/chạy Godot không lỗi là điều kiện kỹ thuật; vẫn cần xem hình và animation. Chỉ tuyên bố thử trên Android/iOS khi thực sự có thiết bị hoặc môi trường kiểm thử tương ứng.

## 10. Mở rộng sau demo

Thứ tự tiếp theo bám Chương 0: NPC chủ chốt (Mara, Leni khi xuất hiện, trưởng làng, thợ rèn, thầy thuốc, chủ trọ, thợ săn) → sinh hoạt/tutorial và vật phẩm quest → bộ chiến đấu Kael → rừng/quái thường → hầm mỏ, elite, boss → các trạng thái Aster phục hồi → thương nhân, kẻ áo đen, manh mối và cảnh rời làng.

Trước khi vẽ animation chiến đấu phải chốt cơ chế, vũ khí, số hướng, tầm đánh và thời điểm va chạm. Chưa lấy các sheet kiếm/cung placeholder làm cam kết đủ cho chiến đấu. Đêm tấn công chỉ cần bộ art riêng nếu được dựng thành cảnh chơi/cutscene, thay vì kể bằng chữ.

Mỗi khu vực/chương mới sẽ có danh mục tương tự demo: nhân vật, môi trường, đạo cụ, animation, UI, FX và trạng thái theo truyện. Hình quảng bá, icon cửa hàng và ảnh giới thiệu làm sau khi có cảnh game hoàn thiện; âm thanh thuộc kế hoạch phát triển riêng.

**Bước sản xuất kế tiếp: bộ mẫu phong cách ở mốc 1, dùng làm chuẩn cho toàn bộ art demo.**
