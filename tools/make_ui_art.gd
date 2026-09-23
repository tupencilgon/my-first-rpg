extends SceneTree
## Lam lai bo anh giao dien: thu nho DUNG CACH tu anh goc ImageGen.
##
## VI SAO CAN FILE NAY
## Anh goc la 1254x1254. Giao dien ve chung o khoang 34-40 px. Godot thu nho
## bang loc song tuyen (linear) va KHONG bat mipmap, nghia la moi diem anh tren
## man hinh chi lay trung binh 2x2 diem trong so hon 1000 diem nguon. Ket qua la
## icon nat ra thanh vet mo - day chinh la nguyen nhan "UI xau".
##
## Cach sua: thu nho san bang Lanczos xuong dung co dung, cat bo vien rong cho
## chu the day khung, roi vien toi quanh silhouette de icon noi len tren moi nen.
##
## Chay:  godot --headless --path . --script res://tools/make_ui_art.gd
## Anh goc trong assets/arpg_v2/ KHONG bi dong toi.

const SRC := "res://assets/arpg_v2/"
const OUT := "res://assets/ui/"

## Vien toi quanh icon. Day la thu giup icon doc duoc tren nen sang lan nen toi -
## cung ly do pixel art luon co vien 1px.
const OUTLINE := Color(0.043, 0.035, 0.031, 0.93)
const OUTLINE_PX := 3

const ICONS := [
	"sword", "bow", "staff", "armor", "shield", "dodge", "nova", "potion",
	"herb", "ore", "hide", "gold", "bag", "map", "forge", "quest",
	"close", "settings",
]


func _initialize() -> void:
	DirAccess.make_dir_recursive_absolute(OUT)
	DirAccess.make_dir_recursive_absolute(OUT + "icons")

	for name in ICONS:
		_icon(SRC + "icons/%s.png" % name, OUT + "icons/%s.png" % name, 96)

	# Chan dung: cat sat mat roi thu nho. Ve o 64-72px nen 192 la du gap doi.
	_icon(SRC + "ui/portrait.png", OUT + "portrait.png", 192, false)

	# Khung cua so: giu nguyen khung hinh (KHONG cat) vi no la anh nine-patch -
	# cat vien la hong goc bo.
	_plain(SRC + "ui/panel.png", OUT + "panel.png", 256, 256)

	# Tranh man hinh dau: ve to nen giu do phan giai cao.
	_plain(SRC + "ui/title.png", OUT + "title.png", 1280, 853)

	print("\nXong. Anh moi nam trong assets/ui/")
	quit()


## Thu nho mot icon: cat vien rong -> vuong -> Lanczos -> them vien toi.
func _icon(src: String, dst: String, size: int, add_outline: bool = true) -> void:
	var img := _load(src)
	if img == null:
		return

	# fix_alpha_edges to mau cho vung trong suot bang mau lan can. Neu khong lam,
	# Lanczos se keo mau den tu cac diem trong suot vao, tao quang toi quanh vat.
	img.fix_alpha_edges()

	# Cat bo vien rong: anh AI thuong chua chu the o giua voi vien trong rat day.
	# Cat di thi chu the day khung, nho ra gap ruoi ma khong doi kich thuoc o.
	var used := img.get_used_rect()
	if used.size.x > 4 and used.size.y > 4:
		# Noi rong thanh hinh vuong quanh tam de khong bop meo ty le.
		var side: int = maxi(used.size.x, used.size.y)
		var cx: int = used.position.x + used.size.x / 2
		var cy: int = used.position.y + used.size.y / 2
		var pad := int(side * 0.06)          # chua mot chut cho vien toi
		side += pad * 2
		img = img.get_region(Rect2i(cx - side / 2, cy - side / 2, side, side))

	img.resize(size, size, Image.INTERPOLATE_LANCZOS)
	if add_outline:
		img = _outline(img)
	_save(img, dst)


## Thu nho don thuan, giu nguyen bo cuc - dung cho nine-patch va tranh nen.
func _plain(src: String, dst: String, w: int, h: int) -> void:
	var img := _load(src)
	if img == null:
		return
	img.fix_alpha_edges()
	img.resize(w, h, Image.INTERPOLATE_LANCZOS)
	_save(img, dst)


## Ve mot vong toi quanh silhouette. Lam tren anh DA thu nho nen vien day deu
## dung OUTLINE_PX diem, khong phu thuoc kich thuoc anh goc.
func _outline(img: Image) -> Image:
	var w := img.get_width()
	var h := img.get_height()

	# Danh dau o nao co vat the. Nguong 0.35 de rau alpha mo khong tinh la vat.
	var solid := []
	solid.resize(w * h)
	for y in h:
		for x in w:
			solid[y * w + x] = img.get_pixel(x, y).a > 0.35

	var out := Image.create(w, h, false, Image.FORMAT_RGBA8)
	for y in h:
		for x in w:
			if solid[y * w + x]:
				out.set_pixel(x, y, img.get_pixel(x, y))
				continue
			# O trong: neu gan vat the thi to vien.
			var near := false
			for dy in range(-OUTLINE_PX, OUTLINE_PX + 1):
				for dx in range(-OUTLINE_PX, OUTLINE_PX + 1):
					if dx * dx + dy * dy > OUTLINE_PX * OUTLINE_PX:
						continue
					var nx := x + dx
					var ny := y + dy
					if nx < 0 or ny < 0 or nx >= w or ny >= h:
						continue
					if solid[ny * w + nx]:
						near = true
						break
				if near:
					break
			out.set_pixel(x, y, OUTLINE if near else Color(0, 0, 0, 0))
	return out


func _load(path: String) -> Image:
	var abs := ProjectSettings.globalize_path(path)
	var img := Image.load_from_file(abs)
	if img == null:
		printerr("Khong doc duoc ", path)
		return null
	if img.is_compressed():
		img.decompress()
	img.convert(Image.FORMAT_RGBA8)
	return img


func _save(img: Image, dst: String) -> void:
	var abs := ProjectSettings.globalize_path(dst)
	var err := img.save_png(abs)
	if err != OK:
		printerr("Khong luu duoc ", dst, " (", err, ")")
		return
	print("  -> %s  %d x %d" % [dst, img.get_width(), img.get_height()])
