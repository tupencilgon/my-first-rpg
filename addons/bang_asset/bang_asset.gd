@tool
extends VBoxContainer

## Bang Asset HD - hien trong cot ben phai cua Godot.
##
## Lam ba viec:
##   1. Liet ke moi anh PNG trong assets/hd/
##   2. Voi moi anh, cho biet no CAO BAO NHIEU LAN Kael - day la thuoc do ti le
##      duy nhat cua du an sau khi bo luoi 32px
##   3. Bien mot anh thanh prop scene co san va cham va goc toa do o chan,
##      roi tha thang vao scene dang mo
##
## Them mot anh PNG vao assets/hd/ roi bam "Quet lai" la no hien ra ngay.

const ASSET_DIR := "res://assets/hd"
const PROP_DIR := "res://scenes/props_hd"

## Chieu cao Kael = don vi do luong goc cua ca du an. Moi asset khac deu do
## bang "bao nhieu lan Kael". Day la thu thay the cho luoi 32px da bo.
const KAEL_HEIGHT := 126.0

## Nhung file khong phai prop, khong liet ke.
const SKIP := ["kael_hd.png", "aster_ground.png"]

var plugin: EditorPlugin

var _list: VBoxContainer
var _status: Label


func _ready() -> void:
	name = "Asset HD"
	custom_minimum_size = Vector2(320, 0)
	add_theme_constant_override("separation", 6)
	_build()
	_refresh()


func _build() -> void:
	var head := Label.new()
	head.text = "Đơn vị gốc: Kael cao %d px" % int(KAEL_HEIGHT)
	head.add_theme_font_size_override("font_size", 12)
	add_child(head)

	var hint := Label.new()
	hint.text = "Mọi asset đo bằng “số lần chiều cao Kael”.\nĐó là thước đo thay cho lưới 32px đã bỏ."
	hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	hint.add_theme_font_size_override("font_size", 10)
	hint.modulate = Color(1, 1, 1, 0.6)
	add_child(hint)

	var btn := Button.new()
	btn.text = "Quét lại assets/hd"
	btn.pressed.connect(_refresh)
	add_child(btn)

	_status = Label.new()
	_status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_status.add_theme_font_size_override("font_size", 10)
	add_child(_status)

	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	add_child(scroll)

	_list = VBoxContainer.new()
	_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_list.add_theme_constant_override("separation", 8)
	scroll.add_child(_list)


func _refresh() -> void:
	for child in _list.get_children():
		child.queue_free()

	var dir := DirAccess.open(ASSET_DIR)
	if dir == null:
		_status.text = "Không mở được %s" % ASSET_DIR
		return

	var files: Array[String] = []
	for f in dir.get_files():
		# Godot them .import cho moi anh; chi lay file .png that.
		if f.ends_with(".png") and not SKIP.has(f):
			files.append(f)
	files.sort()

	if files.is_empty():
		_status.text = "Chưa có asset nào trong assets/hd/.\nThả file PNG vào đó rồi bấm Quét lại."
		return

	_status.text = "%d asset" % files.size()
	for f in files:
		_list.add_child(_make_row(f))


func _make_row(file_name: String) -> Control:
	var path := "%s/%s" % [ASSET_DIR, file_name]
	var tex: Texture2D = load(path)
	if tex == null:
		var bad := Label.new()
		bad.text = "Không đọc được %s" % file_name
		return bad

	var size := tex.get_size()

	var box := PanelContainer.new()
	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 4)
	box.add_child(col)

	# --- Hang tren: anh nho + thong tin ---
	var top := HBoxContainer.new()
	col.add_child(top)

	var thumb := TextureRect.new()
	thumb.texture = tex
	thumb.custom_minimum_size = Vector2(72, 72)
	thumb.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	thumb.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	top.add_child(thumb)

	var info := VBoxContainer.new()
	info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	info.add_theme_constant_override("separation", 0)
	top.add_child(info)

	var name_label := Label.new()
	name_label.text = file_name.get_basename()
	name_label.add_theme_font_size_override("font_size", 11)
	info.add_child(name_label)

	var size_label := Label.new()
	size_label.text = "%d × %d px" % [int(size.x), int(size.y)]
	size_label.add_theme_font_size_override("font_size", 10)
	size_label.modulate = Color(1, 1, 1, 0.6)
	info.add_child(size_label)

	var ratio_label := Label.new()
	ratio_label.add_theme_font_size_override("font_size", 10)
	info.add_child(ratio_label)

	# --- Hang giua: phong to + phan chan dac ---
	var scale_spin := SpinBox.new()
	scale_spin.min_value = 0.25
	scale_spin.max_value = 6.0
	scale_spin.step = 0.05
	scale_spin.value = 1.0
	col.add_child(_labelled("Phóng to", scale_spin))

	var solid_spin := SpinBox.new()
	solid_spin.min_value = 5
	solid_spin.max_value = 100
	solid_spin.step = 5
	solid_spin.value = 60
	solid_spin.suffix = "%"
	col.add_child(_labelled("Phần chân chặn đường", solid_spin))

	# Cap nhat dong ti le moi khi doi he so phong to.
	var update_ratio := func() -> void:
		var h: float = size.y * scale_spin.value
		var w: float = size.x * scale_spin.value
		ratio_label.text = "= %.1f × Kael cao  ·  %d × %d trong game" % [
				h / KAEL_HEIGHT, int(w), int(h)]
	update_ratio.call()
	scale_spin.value_changed.connect(func(_v): update_ratio.call())

	# --- Hang duoi: hai nut ---
	var buttons := HBoxContainer.new()
	col.add_child(buttons)

	var make_btn := Button.new()
	make_btn.text = "Tạo prop"
	make_btn.tooltip_text = "Sinh file scene trong %s, gốc toạ độ ở chân, kèm vùng va chạm." % PROP_DIR
	make_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	make_btn.pressed.connect(func(): _on_make(path, scale_spin.value, solid_spin.value))
	buttons.add_child(make_btn)

	var add_btn := Button.new()
	add_btn.text = "Thêm vào scene"
	add_btn.tooltip_text = "Tạo prop rồi đặt luôn vào scene đang mở."
	add_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	add_btn.pressed.connect(func(): _on_add(path, scale_spin.value, solid_spin.value))
	buttons.add_child(add_btn)

	return box


func _labelled(text: String, control: Control) -> Control:
	var row := HBoxContainer.new()
	var label := Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", 10)
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(label)
	control.custom_minimum_size = Vector2(88, 0)
	row.add_child(control)
	return row


## Sinh mot prop scene tu anh. Tra ve duong dan scene, hoac "" neu that bai.
##
## Quy uoc bat buoc cua du an: goc toa do nam o CHAN vat the (day anh, giua
## chieu ngang). Nho vay Y-sort so sanh dung voi nhan vat - nhan vat cung lay
## goc o chan.
func _make_prop(tex_path: String, scale: float, solid_pct: float) -> String:
	var tex: Texture2D = load(tex_path)
	if tex == null:
		push_error("Bang Asset: không đọc được %s" % tex_path)
		return ""

	var tw: float = tex.get_size().x
	var th: float = tex.get_size().y

	var body := StaticBody2D.new()
	body.name = tex_path.get_file().get_basename()

	var sprite := Sprite2D.new()
	sprite.name = "Sprite2D"
	sprite.texture = tex
	sprite.centered = false
	sprite.scale = Vector2(scale, scale)
	# offset tinh trong khong gian ANH, sau do bi scale nhan len - nen chan
	# vat the roi dung vao goc toa do bat ke he so phong to la bao nhieu.
	sprite.offset = Vector2(-tw / 2.0, -th)
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	body.add_child(sprite)
	sprite.owner = body

	# Vung va cham chi bao phan CHAN. Mai nha va tan cay thi nguoi choi di
	# duoi duoc - giong y quy uoc cua prop 32px.
	var solid_h: float = th * scale * solid_pct / 100.0
	var shape := RectangleShape2D.new()
	shape.size = Vector2(tw * scale * 0.86, solid_h)

	var col := CollisionShape2D.new()
	col.name = "VaCham"
	col.shape = shape
	col.position = Vector2(0, -solid_h / 2.0)
	body.add_child(col)
	col.owner = body

	var packed := PackedScene.new()
	if packed.pack(body) != OK:
		push_error("Bang Asset: đóng gói scene thất bại")
		body.free()
		return ""

	DirAccess.make_dir_recursive_absolute(PROP_DIR)
	var out := "%s/%s.tscn" % [PROP_DIR, body.name]
	var err := ResourceSaver.save(packed, out)
	body.free()
	if err != OK:
		push_error("Bang Asset: lưu %s thất bại (%d)" % [out, err])
		return ""
	return out


func _on_make(tex_path: String, scale: float, solid_pct: float) -> void:
	var out := _make_prop(tex_path, scale, solid_pct)
	if out.is_empty():
		_status.text = "Tạo prop thất bại — xem Output."
		return
	_status.text = "Đã tạo %s" % out
	if plugin != null:
		EditorInterface.get_resource_filesystem().scan()


func _on_add(tex_path: String, scale: float, solid_pct: float) -> void:
	var root := EditorInterface.get_edited_scene_root()
	if root == null:
		_status.text = "Chưa mở scene nào. Mở một scene 2D rồi thử lại."
		return

	var out := _make_prop(tex_path, scale, solid_pct)
	if out.is_empty():
		_status.text = "Tạo prop thất bại — xem Output."
		return

	var packed: PackedScene = ResourceLoader.load(out, "", ResourceLoader.CACHE_MODE_REPLACE)
	var inst: Node = packed.instantiate()

	# Uu tien dat vao node World vi do la node bat y_sort_enabled. Dat ngoai
	# World thi vat the se khong sap xep dung voi nhan vat.
	var parent: Node = root.get_node_or_null("World")
	if parent == null:
		parent = root

	parent.add_child(inst)
	inst.owner = root

	# Dat canh nhan vat cho de tim, thay vi goc (0,0) o ngoai man hinh.
	var player: Node = root.get_node_or_null("World/Player")
	if player is Node2D and inst is Node2D:
		(inst as Node2D).global_position = (player as Node2D).global_position + Vector2(200, 0)

	_status.text = "Đã thêm %s vào %s. Kéo chuột để chỉnh vị trí." % [inst.name, parent.name]
	EditorInterface.get_resource_filesystem().scan()
