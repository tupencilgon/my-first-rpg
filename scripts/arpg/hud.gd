extends CanvasLayer
## Giao dien Aster.
##
## BO CUC THEO NEO (anchor), KHONG THEO TOA DO CHET.
## Ban cu dat moi thu bang toa do tuyet doi tren luoi 960x540, nen doi do phan
## giai la lech het. O day moi khoi duoc neo vao mot goc man hinh.
##
## PHAN VUNG MAN HINH:
##   goc tren trai   - trang thai nhan vat, roi nhat ky nhiem vu
##   goc tren phai   - ban do nho (kem ten vung va so ngay)
##   giua tren       - bang bao ngan, tu tat
##   giua duoi       - goi y tuong tac, roi thanh ky nang
##   giua man hinh   - de TRONG cho nguoi choi nhin thay game

const Content = preload("res://scripts/arpg/content.gd")
const UI = preload("res://scripts/arpg/ui_assets.gd")

const VIEW := Vector2(960, 540)
const EDGE := 14.0          # khoang cach tu mep man hinh
const PANEL_W := 264.0      # be ngang cot trai


## O vuong ve icon. Dung cho ca thanh ky nang lan luoi tui do.
##
## Vi sao tu ve thay vi dung Button.icon: can chong bon lop len nhau theo dung
## thu tu - icon, lop phu hoi chieu, so giay con lai, huy hieu so luong - va
## Button khong lam duoc viec do.
class Slot extends Button:
	var action_icon: Texture2D
	var icon_size := 32.0
	var key_hint := ""          # ve BEN DUOI o, khong ve trong o
	var count_text := ""        # huy hieu goc tren phai
	var cooldown_ratio := 0.0
	var cooldown_text := ""
	var dimmed := false         # chua so huu / khong dung duoc
	var tint := Color.WHITE     # to mau icon - dung de phan biet cac bo do

	func _draw() -> void:
		var font := get_theme_default_font()

		if action_icon != null:
			var box := Rect2((size.x - icon_size) * 0.5, (size.y - icon_size) * 0.5, icon_size, icon_size)
			var shade_color := tint
			if dimmed:
				shade_color.a *= 0.34
			draw_texture_rect(action_icon, box, false, shade_color)

		# Lop phu hoi chieu dang lop nuoc rut dan tu tren xuong.
		if cooldown_ratio > 0.001:
			var h := size.y * clampf(cooldown_ratio, 0.0, 1.0)
			draw_rect(Rect2(1, size.y - h - 1, size.x - 2, h), Color(0.02, 0.02, 0.03, 0.68), true)

		if cooldown_text != "":
			var centre := Vector2(size.x * 0.5, size.y * 0.5)
			draw_circle(centre, 13.0, Color(0.02, 0.02, 0.03, 0.72))
			draw_string(font, Vector2(0, centre.y + 5), cooldown_text,
					HORIZONTAL_ALIGNMENT_CENTER, size.x, 13, Color("fff0c7"))

		# Huy hieu so luong: dia toi o goc, so vang o giua. Nho vay so khong
		# bao gio de len icon nhu ban cu.
		if count_text != "":
			var at := Vector2(size.x - 9, 9)
			draw_circle(at, 9.5, Color(0.04, 0.035, 0.03, 0.95))
			draw_arc(at, 9.5, 0, TAU, 20, UI.GOLD_DIM, 1.0, true)
			draw_string(font, Vector2(at.x - 14, at.y + 4), count_text,
					HORIZONTAL_ALIGNMENT_CENTER, 28, 11, UI.GOLD)

		if key_hint != "":
			draw_string(font, Vector2(0, size.y + 11), key_hint,
					HORIZONTAL_ALIGNMENT_CENTER, size.x, UI.F_MICRO, UI.TEXT_DIM)


var game: Node
var root: Control

# --- cua so ---
var menu: PanelContainer
var shade: ColorRect
var menu_box: VBoxContainer
var menu_kind := ""
## Phan khung cua cua so (le + hang tieu de). Do bang so that luc dung cua so
## thay vi doan, de _fit_menu cat dung do cao.
var menu_chrome := Vector2(58, 92)

# --- thanh trang thai ---
var hp_bar: ProgressBar
var stamina_bar: ProgressBar
var xp_bar: ProgressBar
var hp_text: Label
var hero_label: Label
var level_label: Label
var state_label: Label

# --- nhat ky ---
var quest_panel: PanelContainer
var quest_title: Label
var quest_detail: Label
var quest_step: Label
var quest_body: VBoxContainer
var quest_toggle: Button
var quest_collapsed := false

# --- ban do nho ---
var mini: Control
var mini_caption: Label
var mini_day: Label

# --- thong bao ---
var hint: PanelContainer
var hint_label: Label
var banner: PanelContainer
var banner_label: Label
var banner_time := 0.0

var hotbar_slots: Array[Slot] = []
var skill_buttons: Array[Button] = []

# --- hoi thoai ---
var dialogue_lines: Array = []
var dialogue_index := 0
var dialogue_end: Callable
var dialogue_choices: Array = []
var dialogue_text: Label
var dialogue_title := ""

var inventory_tab := "equipment"
var inventory_selected := -1
var smith_selected := 0


func _ready() -> void:
	root = Control.new()
	root.name = "AsterHUD"
	# MIPMAP la nua con lai cua viec sua icon: ngay ca anh 96px ve o 32px cung
	# can mipmap, neu khong Godot chi lay mau 2x2 diem va anh bi ram.
	root.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(root)
	var theme := Theme.new()
	UI.apply_theme(theme)
	root.theme = theme
	_build_status()
	_build_quest()
	_build_minimap()
	_build_banner()
	_build_hotbar()


# ================================================================ tren trai
func _build_status() -> void:
	var box := _hud_panel(Vector2(EDGE, EDGE), PANEL_W)

	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 9)
	box.add_child(row)

	var frame := PanelContainer.new()
	frame.custom_minimum_size = Vector2(52, 52)
	frame.add_theme_stylebox_override("panel", UI.slot_box())
	row.add_child(frame)
	var face := TextureRect.new()
	face.texture = UI.texture("portrait")
	face.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	face.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	face.mouse_filter = Control.MOUSE_FILTER_IGNORE
	frame.add_child(face)

	var col := VBoxContainer.new()
	col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	col.add_theme_constant_override("separation", 3)
	row.add_child(col)

	var name_row := HBoxContainer.new()
	name_row.add_theme_constant_override("separation", 7)
	col.add_child(name_row)
	hero_label = _label("KAEL", UI.F_LEAD, UI.TEXT)
	name_row.add_child(hero_label)
	level_label = _label("Cấp 1", UI.F_TINY, UI.GOLD_DIM)
	level_label.vertical_alignment = VERTICAL_ALIGNMENT_BOTTOM
	name_row.add_child(level_label)
	state_label = _label("", UI.F_TINY, UI.BAD)
	state_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	state_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	state_label.vertical_alignment = VERTICAL_ALIGNMENT_BOTTOM
	name_row.add_child(state_label)

	# Thanh mau day nhat, the luc mong hon, kinh nghiem mong nhat. Do day cua
	# thanh cho biet no quan trong toi dau - khong can nhan chu.
	var hp_stack := Control.new()
	hp_stack.custom_minimum_size = Vector2(0, 13)
	hp_stack.mouse_filter = Control.MOUSE_FILTER_IGNORE
	col.add_child(hp_stack)
	hp_bar = _bar(UI.HP, 13)
	hp_bar.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	hp_stack.add_child(hp_bar)
	# So HP nam TRONG thanh mau, khong chiem them mot dong rieng.
	hp_text = _label("", UI.F_MICRO, Color("f8efe4"))
	hp_text.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	hp_text.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hp_text.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	hp_stack.add_child(hp_text)

	stamina_bar = _bar(UI.STAMINA, 6)
	col.add_child(stamina_bar)
	xp_bar = _bar(UI.XP, 3)
	col.add_child(xp_bar)


func _build_quest() -> void:
	quest_panel = _hud_panel(Vector2(EDGE, EDGE + 84), PANEL_W)
	var stack := VBoxContainer.new()
	stack.add_theme_constant_override("separation", 5)
	quest_panel.add_child(stack)

	var head := HBoxContainer.new()
	stack.add_child(head)
	var cap := _label("NHIỆM VỤ", UI.F_MICRO, UI.GOLD_DIM)
	cap.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	cap.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	head.add_child(cap)
	quest_toggle = Button.new()
	quest_toggle.text = "−"
	quest_toggle.custom_minimum_size = Vector2(22, 18)
	quest_toggle.focus_mode = Control.FOCUS_NONE
	quest_toggle.tooltip_text = "Thu gọn nhật ký"
	_ghost(quest_toggle)
	quest_toggle.pressed.connect(_toggle_quest)
	head.add_child(quest_toggle)
	quest_panel.mouse_filter = Control.MOUSE_FILTER_PASS

	quest_body = VBoxContainer.new()
	quest_body.add_theme_constant_override("separation", 3)
	stack.add_child(quest_body)
	quest_title = _label("", UI.F_BODY, UI.TEXT)
	quest_title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	quest_body.add_child(quest_title)
	quest_detail = _label("", UI.F_TINY, UI.TEXT_DIM)
	quest_detail.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	quest_body.add_child(quest_detail)
	quest_step = _label("", UI.F_TINY, UI.GOLD)
	quest_body.add_child(quest_step)


func _toggle_quest() -> void:
	quest_collapsed = not quest_collapsed
	quest_body.visible = not quest_collapsed
	quest_toggle.text = "+" if quest_collapsed else "−"
	quest_toggle.tooltip_text = "Mở nhật ký" if quest_collapsed else "Thu gọn nhật ký"


# ================================================================ tren phai
func _build_minimap() -> void:
	var box := _hud_panel(Vector2(VIEW.x - EDGE - 176, EDGE), 176)
	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 4)
	box.add_child(col)

	# Ten vung nam O DAY, khong tha noi giua man hinh nhu ban cu. Chu tha noi
	# tren mat dat thi vua kho doc vua che mat game.
	var head := HBoxContainer.new()
	col.add_child(head)
	mini_caption = _label("", UI.F_TINY, UI.GOLD)
	mini_caption.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	mini_caption.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	head.add_child(mini_caption)
	mini_day = _label("", UI.F_MICRO, UI.TEXT_DIM)
	mini_day.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	head.add_child(mini_day)

	mini = Control.new()
	mini.custom_minimum_size = Vector2(0, 104)
	mini.mouse_filter = Control.MOUSE_FILTER_IGNORE
	mini.draw.connect(_draw_minimap)
	col.add_child(mini)


# ================================================================ thong bao
func _build_banner() -> void:
	banner = PanelContainer.new()
	banner.mouse_filter = Control.MOUSE_FILTER_IGNORE
	banner.add_theme_stylebox_override("panel",
			UI.flat(Color(0.05, 0.042, 0.036, 0.88), UI.GOLD_DIM, 3, 1, 16))
	banner.visible = false
	root.add_child(banner)
	banner_label = _label("", UI.F_BODY, Color("f4e5c2"))
	banner_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	banner.add_child(banner_label)


func _build_hotbar() -> void:
	# Goi y tuong tac nam ngay tren thanh ky nang, co nen toi rieng de doc duoc
	# tren bat ky mat dat nao.
	hint = PanelContainer.new()
	hint.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hint.add_theme_stylebox_override("panel",
			UI.flat(Color(0.04, 0.035, 0.03, 0.84), Color(0, 0, 0, 0), 3, 0, 13))
	hint.visible = false
	root.add_child(hint)
	hint_label = _label("", UI.F_BODY, Color("ffe6ae"))
	hint.add_child(hint_label)

	# KHONG boc thanh ky nang trong mot khung nua: tung o da la khung roi.
	# Khung long trong khung chinh la thu lam ban cu trong roi mat.
	var row := HBoxContainer.new()
	row.name = "Hotbar"
	row.add_theme_constant_override("separation", 7)
	row.mouse_filter = Control.MOUSE_FILTER_PASS
	root.add_child(row)

	var specs := [
		["sword", "J", "Đánh", func(): game.player.attack()],
		["dodge", "SPACE", "Né", func(): game.player.dodge()],
		["nova", "Q", "Xung kích", func(): game.player.skill()],
		["shield", "F", "Đỡ / parry", func(): notify("Giữ F hoặc chuột phải để đỡ và parry")],
		["potion", "R", "Bình hồi phục", func(): game.player.heal()],
		["bag", "I", "Túi đồ", inventory],
		["map", "M", "Bản đồ", atlas],
	]
	for spec in specs:
		var b := Slot.new()
		b.custom_minimum_size = Vector2(48, 48)
		b.key_hint = str(spec[1])
		b.tooltip_text = "%s  [%s]" % [spec[2], spec[1]]
		b.action_icon = UI.icon(str(spec[0]))
		b.icon_size = 32.0
		b.focus_mode = Control.FOCUS_NONE
		b.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		b.add_theme_stylebox_override("normal", UI.slot_box())
		b.add_theme_stylebox_override("hover", UI.slot_box("hover"))
		b.add_theme_stylebox_override("pressed", UI.slot_box("selected"))
		var action: Callable = spec[3]
		b.pressed.connect(action)
		row.add_child(b)
		hotbar_slots.append(b)
		skill_buttons.append(b)

	var bar_w := 48.0 * 7 + 7.0 * 6
	row.size = Vector2(bar_w, 48)
	row.position = Vector2((VIEW.x - bar_w) * 0.5, VIEW.y - 74)


# ================================================================ moi khung hinh
func _process(dt: float) -> void:
	if not is_instance_valid(game) or not is_instance_valid(game.player):
		return
	var p = game.player

	hp_bar.value = p.hp / p.max_hp * 100.0
	stamina_bar.value = p.stamina / p.max_stamina * 100.0
	xp_bar.value = float(game.xp) / maxf(1.0, float(game.level * 65)) * 100.0
	hp_text.text = "%d / %d" % [p.hp, p.max_hp]
	level_label.text = "Cấp %d" % game.level
	if p.hp / p.max_hp < 0.25:
		state_label.text = "TRỌNG THƯƠNG"
		state_label.add_theme_color_override("font_color", UI.BAD)
	elif p.stamina < 22:
		state_label.text = "MỆT"
		state_label.add_theme_color_override("font_color", UI.TEXT_DIM)
	else:
		state_label.text = ""

	quest_title.text = Content.QUESTS[game.quest][0]
	quest_detail.text = Content.QUESTS[game.quest][1]
	quest_step.text = "Dược thảo  %d / 3" % game.bag.herb if game.quest == 2 else ""
	quest_step.visible = quest_step.text != ""

	mini_caption.text = Content.MAPS[game.map_id].name
	mini_day.text = "Ngày %d" % game.day

	var text: String = game.near_hint() if menu_kind == "" and p.hp > 0 else ""
	hint_label.text = text
	hint.visible = text != ""
	if hint.visible:
		hint.position = Vector2((VIEW.x - hint.size.x) * 0.5, VIEW.y - 104)

	banner_time -= dt
	banner.visible = banner_time > 0.0 and menu_kind == ""
	if banner.visible:
		banner.position = Vector2((VIEW.x - banner.size.x) * 0.5, 22)
		# Mo dan trong nua giay cuoi thay vi bien mat dot ngot.
		banner.modulate.a = clampf(banner_time / 0.6, 0.0, 1.0)

	if hotbar_slots.size() >= 7:
		_slot_state(0, p.attack_cd / maxf(0.01, Content.WEAPONS[game.weapon].delay), p.attack_cd)
		var dash: float = p.state_time if p.state == "dash" else 0.0
		_slot_state(1, dash / 0.22, dash)
		_slot_state(2, p.skill_cd / 5.0, p.skill_cd)
		_slot_state(4, p.heal_cd / 4.0, p.heal_cd)
		hotbar_slots[4].count_text = str(game.bag.potion)
		hotbar_slots[4].dimmed = game.bag.potion <= 0

	mini.queue_redraw()


func _slot_state(index: int, ratio: float, seconds: float) -> void:
	var s := hotbar_slots[index]
	s.cooldown_ratio = clampf(ratio, 0.0, 1.0)
	s.cooldown_text = "%.1f" % seconds if seconds > 0.05 else ""
	s.queue_redraw()


func notify(value: String) -> void:
	banner_label.text = value
	banner_time = 3.0
	banner.modulate.a = 1.0


func _draw_minimap() -> void:
	var box := mini.size
	# Nen sang hon vat can, de khoi tuong doc ra la KHOI DAC chu khong phai
	# mot dam o vuong xam roi rac nhu ban cu.
	mini.draw_rect(Rect2(Vector2.ZERO, box), Color("232a26"), true)
	if not is_instance_valid(game.world):
		mini.draw_rect(Rect2(Vector2.ZERO, box), UI.LINE, false, 1.0)
		return
	var k := box / Vector2(1280, 960)
	for r in game.world.blockers:
		mini.draw_rect(Rect2(r.position * k, r.size * k), Color("14100d"), true)
	for g in game.world.gates:
		mini.draw_circle(g[1] * k, 3.0, UI.GOLD)
	for n in game.world.interactables:
		mini.draw_circle(n.pos * k, 2.0, Color("6fb3a4"))
	for e in game.enemies:
		if is_instance_valid(e) and e.hp > 0:
			mini.draw_circle(e.position * k, 2.0, UI.BAD)
	var me: Vector2 = game.player.position * k
	mini.draw_circle(me, 3.5, Color("fff6d8"))
	mini.draw_arc(me, 6.0, 0, TAU, 18, Color(1, 0.96, 0.85, 0.5), 1.0, true)
	mini.draw_rect(Rect2(Vector2.ZERO, box), Color(UI.LINE.r, UI.LINE.g, UI.LINE.b, 0.9), false, 1.0)


func is_pointer_over_hud() -> bool:
	if menu_kind != "":
		return true
	var hovered := get_viewport().gui_get_hovered_control()
	return hovered != null and (hovered == root or root.is_ancestor_of(hovered)) \
			and hovered.mouse_filter != Control.MOUSE_FILTER_IGNORE


# ================================================================ tien ich
func _label(value: String, font_size: int = UI.F_BODY, color: Color = UI.TEXT) -> Label:
	var l := Label.new()
	l.text = value
	l.add_theme_font_size_override("font_size", font_size)
	l.add_theme_color_override("font_color", color)
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return l


func _bar(color: Color, height: int) -> ProgressBar:
	var b := ProgressBar.new()
	b.custom_minimum_size = Vector2(0, height)
	b.show_percentage = false
	var bg := UI.flat(Color("100e0d"), Color(0, 0, 0, 0.55), 2, 1, 0)
	var fill := UI.flat(color, color, 2, 0, 0)
	for skin in [bg, fill]:
		skin.content_margin_top = 0
		skin.content_margin_bottom = 0
		skin.content_margin_left = 0
		skin.content_margin_right = 0
	b.add_theme_stylebox_override("background", bg)
	b.add_theme_stylebox_override("fill", fill)
	b.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return b


func _ghost(b: Button) -> void:
	for state in ["normal", "hover", "pressed", "focus", "disabled"]:
		b.add_theme_stylebox_override(state, UI.ghost_box(state))


func _hud_panel(at: Vector2, width: float) -> PanelContainer:
	var p := PanelContainer.new()
	p.position = at
	p.custom_minimum_size = Vector2(width, 0)
	p.size = Vector2(width, 0)
	p.mouse_filter = Control.MOUSE_FILTER_IGNORE
	p.add_theme_stylebox_override("panel", UI.hud_box())
	root.add_child(p)
	return p


func _button(value: String, action: Callable) -> Button:
	var b := Button.new()
	b.text = value
	if action.is_valid():
		b.pressed.connect(action)
	b.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	return b


func icon_rect(icon_name: String, size_px: Vector2 = Vector2(48, 48)) -> TextureRect:
	var image := TextureRect.new()
	image.texture = UI.icon(icon_name)
	image.custom_minimum_size = size_px
	image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	image.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return image


# ================================================================ cua so

## Mo mot cua so. De origin = (-1,-1) thi cua so tu can giua man hinh - do la
## mac dinh, vi can giua la dung cho gan nhu moi cua so.
func open_menu(title: String, kind: String = "menu", dimensions: Vector2 = Vector2(700, 400), origin: Vector2 = Vector2(-1, -1)) -> void:
	close_menu()
	menu_kind = kind
	game.paused = true

	shade = ColorRect.new()
	shade.color = Color(0.015, 0.013, 0.012, 0.82)
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	shade.mouse_filter = Control.MOUSE_FILTER_STOP
	root.add_child(shade)

	menu = PanelContainer.new()
	menu.size = dimensions
	menu.custom_minimum_size = dimensions
	menu.position = origin if origin.x >= 0.0 else (VIEW - dimensions) * 0.5
	menu.mouse_filter = Control.MOUSE_FILTER_STOP
	# Khung cham tron chi xuat hien O DAY - tren cua so. Do la ly do no van
	# con y nghia khi nhin thay.
	menu.add_theme_stylebox_override("panel", UI.window_box())
	root.add_child(menu)

	var outer := VBoxContainer.new()
	outer.add_theme_constant_override("separation", 8)
	menu.add_child(outer)

	menu_chrome = Vector2(58, 48)
	# Cua so khong co ten thi khong ve hang tieu de - neu khong se thua mot
	# dai trong va mot duong ke chang ngan cach gi ca.
	if title != "" or kind not in ["title", "death"]:
		var header := HBoxContainer.new()
		header.add_theme_constant_override("separation", 8)
		outer.add_child(header)
		var title_label := _label(title.to_upper(), UI.F_HEAD, UI.GOLD)
		title_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		title_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		header.add_child(title_label)
		if kind not in ["title", "death"]:
			# Dau nhan chu "x" thay cho icon. Icon close.png ve ra hai thanh
			# kiem bat cheo - nhin nham thanh nut tan cong.
			var close := _button("✕", close_menu)
			close.custom_minimum_size = Vector2(30, 26)
			close.focus_mode = Control.FOCUS_NONE
			close.tooltip_text = "Đóng [Esc]"
			_ghost(close)
			header.add_child(close)
		outer.add_child(HSeparator.new())
		menu_chrome.y += 44

	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	outer.add_child(scroll)

	menu_box = VBoxContainer.new()
	menu_box.custom_minimum_size.x = dimensions.x - 58
	menu_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	menu_box.add_theme_constant_override("separation", 10)
	scroll.add_child(menu_box)


## Cho cua so co lai vua dung noi dung, roi dat lai cho.
##
## Khong lam viec nay thi hoac cua so thua mot mang trong o duoi, hoac noi dung
## bi cat va hien thanh cuon de len - dung loi cua o hoi thoai va lo ren.
func _fit_menu(mode: String = "center", fixed_y: float = -1.0) -> void:
	var target := menu
	# Doi hai khung hinh: container can mot vong de tinh xong kich thuoc toi thieu.
	await get_tree().process_frame
	await get_tree().process_frame
	if not is_instance_valid(target) or target != menu or not is_instance_valid(menu_box):
		return
	var content := menu_box.get_combined_minimum_size()
	var chrome := menu_chrome
	var w: float = clampf(maxf(content.x + chrome.x, menu.custom_minimum_size.x), 300.0, VIEW.x - 36.0)
	var h: float = clampf(content.y + chrome.y, 140.0, VIEW.y - 36.0)
	# Phai ha ca custom_minimum_size, neu khong PanelContainer giu nguyen kich
	# thuoc dat luc mo va thua mot mang trong o duoi.
	menu.custom_minimum_size = Vector2(w, h)
	menu.size = Vector2(w, h)
	if mode == "bottom":
		menu.position = Vector2((VIEW.x - w) * 0.5, VIEW.y - h - 22.0)
	elif fixed_y >= 0.0:
		# Man hinh dau: ten game duoc ve TREN khung, nen khung phai o nguyen
		# cho, khong duoc tu can giua roi trum len chu.
		menu.position = Vector2((VIEW.x - w) * 0.5, fixed_y)
	else:
		menu.position = (VIEW - Vector2(w, h)) * 0.5


func close_menu() -> void:
	if is_instance_valid(shade):
		shade.queue_free()
	shade = null
	if is_instance_valid(menu):
		menu.queue_free()
	menu = null
	menu_box = null
	menu_kind = ""
	if is_instance_valid(game):
		game.paused = false


func prose(value: String, size: int = UI.F_BODY, color: Color = UI.TEXT) -> void:
	var l := _label(value, size, color)
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	l.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	menu_box.add_child(l)


func option(value: String, action: Callable, enabled: bool = true) -> Button:
	var b := _button(value, action)
	b.disabled = not enabled
	b.custom_minimum_size.y = 36
	menu_box.add_child(b)
	return b


## Mot dong "nhan  -  gia tri", dung trong bang thong tin vat pham.
func _stat_row(parent: Control, key: String, value: String) -> void:
	var row := HBoxContainer.new()
	var k := _label(key, UI.F_TINY, UI.TEXT_DIM)
	k.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(k)
	row.add_child(_label(value, UI.F_TINY, UI.TEXT))
	parent.add_child(row)


## O vuong trong luoi tui do / lo ren.
func _grid_slot(icon_name: String, selected: bool, owned: bool, count: String = "") -> Slot:
	var s := Slot.new()
	s.custom_minimum_size = Vector2(52, 52)
	s.action_icon = UI.icon(icon_name)
	s.icon_size = 34.0
	s.count_text = count
	s.dimmed = not owned
	s.focus_mode = Control.FOCUS_NONE
	s.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	s.add_theme_stylebox_override("normal", UI.slot_box("selected" if selected else "normal"))
	s.add_theme_stylebox_override("hover", UI.slot_box("selected" if selected else "hover"))
	s.add_theme_stylebox_override("pressed", UI.slot_box("selected"))
	return s


func _card(width: float, height: float = 0.0) -> PanelContainer:
	var p := PanelContainer.new()
	p.custom_minimum_size = Vector2(width, height)
	p.add_theme_stylebox_override("panel", UI.flat(Color("110f0e"), UI.LINE, 4, 1, 10))
	return p


# ================================================================ man hinh dau
func title_screen() -> void:
	open_menu("", "title", Vector2(380, 330), Vector2((VIEW.x - 380) * 0.5, 150))

	var art := TextureRect.new()
	art.texture = UI.texture("title")
	art.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	art.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	art.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	art.mouse_filter = Control.MOUSE_FILTER_IGNORE
	shade.add_child(art)
	# Lop toi phu len tranh: khong co no thi chu tren tranh khong doc duoc.
	var veil := ColorRect.new()
	veil.color = Color(0.02, 0.016, 0.014, 0.52)
	veil.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	veil.mouse_filter = Control.MOUSE_FILTER_IGNORE
	shade.add_child(veil)

	# Ten game nam tren tranh, khong nhet vao trong khung cua so.
	var wordmark := _label("ASTER", 46, Color("f2dca6"))
	wordmark.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	wordmark.position = Vector2(0, 52)
	wordmark.size = Vector2(VIEW.x, 60)
	shade.add_child(wordmark)
	var sub = _label("TRO TÀN & HY VỌNG", UI.F_BODY, UI.GOLD_DIM)
	sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	sub.position = Vector2(0, 108)
	sub.size = Vector2(VIEW.x, 20)
	shade.add_child(sub)

	prose("Chương 0 · Hận thù và nước mắt", UI.F_TINY, UI.TEXT_DIM)
	_menu_action("Tiếp tục hành trình", func(): game.load_game(), FileAccess.file_exists(game.save_path), "sword")
	_menu_action("Bắt đầu hành trình mới", _new_game_confirm, true, "quest")
	_menu_action("Cẩm nang sinh tồn", help_screen, true, "settings")
	_menu_action("Thoát game", func(): game.get_tree().quit(), true, "close")

	_fit_menu("top", 152.0)

	var foot := _label("3 vùng đất  ·  10 bản đồ  ·  Tự động lưu", UI.F_MICRO, UI.TEXT_DIM)
	foot.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	foot.position = Vector2(0, VIEW.y - 34)
	foot.size = Vector2(VIEW.x, 18)
	shade.add_child(foot)


func _menu_action(text_value: String, action: Callable, enabled: bool = true, icon_name: String = "") -> Button:
	var b := option(text_value, action, enabled)
	b.custom_minimum_size.y = 40
	b.alignment = HORIZONTAL_ALIGNMENT_LEFT
	if icon_name != "":
		b.icon = UI.icon(icon_name)
		b.expand_icon = true
		b.add_theme_constant_override("icon_max_width", 22)
	return b


func _new_game_confirm() -> void:
	if not FileAccess.file_exists(game.save_path):
		game.new_game()
		return
	open_menu("Bắt đầu lại?", "confirm", Vector2(430, 220))
	prose("Bản lưu hiện tại sẽ được thay thế khi hành trình mới bắt đầu.", UI.F_BODY)
	option("Bắt đầu hành trình mới", func(): game.new_game())
	option("Quay lại", title_screen)
	_fit_menu()


func help_screen() -> void:
	var was_title := menu_kind == "title"
	open_menu("Cẩm nang sinh tồn", "help", Vector2(600, 420))
	for block in [
		["DI CHUYỂN & CHIẾN ĐẤU", "WASD hoặc phím mũi tên để đi.  J hoặc chuột trái: tấn công theo hướng nhìn.  Space: né.  F hoặc chuột phải: đỡ; bấm ngay trước đòn đánh để parry.  Q: xung kích quanh người.  R: uống bình hồi phục."],
		["TƯƠNG TÁC & HÀNH TRANG", "E: trò chuyện, xem dấu vết, đi qua lối chuyển bản đồ.  I hoặc Tab: túi đồ và trang bị.  M: bản đồ vùng.  Esc: tạm dừng.  Đi tới gần vật phẩm rơi để tự nhặt."],
		["SỐNG SÓT", "Khi trọng thương, Kael đi chậm hẳn. Nghỉ bên lửa trại hoặc uống bình. Thợ rèn tại Aster rèn vũ khí, nâng cấp, may trang phục và chế bình. Trò chơi tự lưu khi đổi bản đồ, khi nghỉ và khi xong nhiệm vụ."],
	]:
		prose(str(block[0]), UI.F_TINY, UI.GOLD_DIM)
		prose(str(block[1]), UI.F_BODY)
	option("Đã hiểu", title_screen if was_title else close_menu)
	_fit_menu()


func pause_screen() -> void:
	open_menu("Bên ngọn lửa nhỏ", "pause", Vector2(360, 330))
	_menu_action("Tiếp tục", close_menu, true, "sword")
	_menu_action("Lưu hành trình", func(): game.save_game(); notify("Đã lưu hành trình"); close_menu(), true, "quest")
	_menu_action("Cẩm nang sinh tồn", help_screen, true, "settings")
	_menu_action("Về màn hình đầu", func(): game.save_game(); title_screen(), true, "map")
	_menu_action("Thoát game", func(): game.save_game(); game.get_tree().quit(), true, "close")
	_fit_menu()


# ================================================================ tui do
func inventory(tab: String = "", selected: int = -999) -> void:
	if tab != "":
		inventory_tab = tab
	if selected != -999:
		inventory_selected = selected
	open_menu("Túi hành trang", "inventory", Vector2(660, 400))

	var tabs := HBoxContainer.new()
	tabs.add_theme_constant_override("separation", 4)
	menu_box.add_child(tabs)
	for data in [["equipment", "Trang bị", "armor"], ["consumables", "Tiêu hao", "potion"],
			["materials", "Nguyên liệu", "ore"], ["quest", "Nhiệm vụ", "quest"]]:
		# Khong gan icon cho tab: o co 18px thi icon chi con la mot vet mo,
		# con chu thi doc duoc ngay.
		var b := _button(str(data[1]), inventory.bind(str(data[0]), -1))
		b.add_theme_font_size_override("font_size", UI.F_TINY)
		b.toggle_mode = true
		b.focus_mode = Control.FOCUS_NONE
		b.button_pressed = inventory_tab == data[0]
		_ghost(b)
		tabs.add_child(b)

	var main := HBoxContainer.new()
	main.add_theme_constant_override("separation", 10)
	main.custom_minimum_size.y = 250
	menu_box.add_child(main)

	# Luoi o VUONG. Ban cu dung nut chu nhat 140x78 co chu ben trong nen hai
	# mon do chiem het mot goc va bo trong ca mang lon.
	var grid_card := _card(352, 250)
	main.add_child(grid_card)
	var grid := GridContainer.new()
	grid.columns = 6
	grid.add_theme_constant_override("h_separation", 5)
	grid.add_theme_constant_override("v_separation", 5)
	grid.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	grid_card.add_child(grid)

	var entries := _inventory_entries()
	if inventory_selected < 0 or inventory_selected >= entries.size():
		inventory_selected = 0 if not entries.is_empty() else -1
	for i in range(entries.size()):
		var entry: Dictionary = entries[i]
		var s := _grid_slot(str(entry.icon), i == inventory_selected, entry.owned, _entry_count(entry))
		# Bon bo do dung chung mot icon giap, nen phan biet bang mau cua bo do.
		if entry.type == "outfit":
			s.tint = Content.OUTFITS[entry.id].color.lerp(Color.WHITE, 0.45)
		s.tooltip_text = str(entry.name)
		s.pressed.connect(inventory.bind(inventory_tab, i))
		grid.add_child(s)
	# O trong cho phan con lai cua luoi: luoi rong nhin ra la "chua co gi",
	# khong phai "giao dien bi hong".
	var slots: int = maxi(12, int(ceil(entries.size() / 6.0)) * 6)
	for _i in range(maxi(0, slots - entries.size())):
		var blank := PanelContainer.new()
		blank.custom_minimum_size = Vector2(52, 52)
		blank.mouse_filter = Control.MOUSE_FILTER_IGNORE
		blank.add_theme_stylebox_override("panel", UI.slot_box("empty"))
		grid.add_child(blank)

	var details := _card(238, 250)
	main.add_child(details)
	var detail_box := VBoxContainer.new()
	detail_box.add_theme_constant_override("separation", 7)
	details.add_child(detail_box)
	if inventory_selected >= 0:
		_inventory_details(detail_box, entries[inventory_selected])

	menu_box.add_child(HSeparator.new())
	var currency := HBoxContainer.new()
	currency.alignment = BoxContainer.ALIGNMENT_CENTER
	currency.add_theme_constant_override("separation", 6)
	menu_box.add_child(currency)
	for resource in [["gold", game.bag.gold, "Vàng"], ["ore", game.bag.ore, "Quặng"],
			["hide", game.bag.hide, "Da"], ["herb", game.bag.herb, "Dược thảo"]]:
		currency.add_child(icon_rect(str(resource[0]), Vector2(20, 20)))
		currency.add_child(_label("%d %s" % [resource[1], resource[2]], UI.F_TINY, UI.TEXT_DIM))
		currency.add_child(_label("   ", UI.F_TINY))
	_fit_menu()


func _entry_count(entry: Dictionary) -> String:
	match entry.type:
		"potion": return str(game.bag.potion) if game.bag.potion > 0 else ""
		"herb": return str(game.bag.herb) if game.bag.herb > 0 else ""
		"ore": return str(game.bag.ore) if game.bag.ore > 0 else ""
		"hide": return str(game.bag.hide) if game.bag.hide > 0 else ""
		"gold": return str(game.bag.gold) if game.bag.gold > 0 else ""
	return ""


func _inventory_entries() -> Array:
	var result: Array = []
	match inventory_tab:
		"equipment":
			for i in range(Content.WEAPONS.size()):
				result.append({"type": "weapon", "id": i, "name": Content.WEAPONS[i].name,
						"icon": Content.WEAPONS[i].kind, "owned": game.owned_weapons.has(i)})
			for i in range(Content.OUTFITS.size()):
				result.append({"type": "outfit", "id": i, "name": Content.OUTFITS[i].name,
						"icon": "armor", "owned": game.owned_outfits.has(i)})
		"consumables":
			result = [
				{"type": "potion", "id": 0, "name": "Bình hồi phục", "icon": "potion", "owned": game.bag.potion > 0},
				{"type": "herb", "id": 0, "name": "Dược thảo", "icon": "herb", "owned": game.bag.herb > 0}]
		"materials":
			result = [
				{"type": "gold", "id": 0, "name": "Vàng Aster", "icon": "gold", "owned": true},
				{"type": "ore", "id": 0, "name": "Quặng thô", "icon": "ore", "owned": game.bag.ore > 0},
				{"type": "hide", "id": 0, "name": "Da thú", "icon": "hide", "owned": game.bag.hide > 0}]
		"quest":
			result.append({"type": "quest", "id": 0, "name": "Nhật ký hành trình", "icon": "quest", "owned": true})
			if game.flags.get("relics", false):
				result.append({"type": "relic", "id": 0, "name": "Kỷ vật gia đình", "icon": "quest", "owned": true})
			if game.flags.get("mine_boss", false):
				result.append({"type": "clue", "id": 0, "name": "Mảnh hắc thạch", "icon": "ore", "owned": true})
	return result


func _inventory_details(parent: VBoxContainer, entry: Dictionary) -> void:
	var preview := icon_rect(str(entry.icon), Vector2(64, 64))
	preview.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	parent.add_child(preview)

	var name_label := _label(str(entry.name), UI.F_LEAD, UI.GOLD)
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	parent.add_child(name_label)
	parent.add_child(HSeparator.new())

	var desc := ""
	var action_text := ""
	var action: Callable
	match entry.type:
		"weapon":
			var w = Content.WEAPONS[entry.id]
			var dmg: int = w.damage + game.weapon_levels[entry.id] * 5 + (game.level - 1) * 2
			_stat_row(parent, "Sát thương", str(dmg))
			_stat_row(parent, "Tầm đánh", str(w.reach))
			_stat_row(parent, "Cấp rèn", "+%d" % game.weapon_levels[entry.id])
			desc = "" if entry.owned else "Chưa sở hữu. Tìm thợ rèn tại Aster."
			action_text = "Đang trang bị" if game.weapon == entry.id else "Trang bị"
			action = _equip_weapon.bind(entry.id)
		"outfit":
			_stat_row(parent, "Giáp", str(Content.OUTFITS[entry.id].armor))
			desc = "Trang phục thay đổi diện mạo Kael." if entry.owned else "Chưa sở hữu. Nhờ thợ rèn may."
			action_text = "Đang mặc" if game.outfit == entry.id else "Mặc trang phục"
			action = _equip_outfit.bind(entry.id)
		"potion":
			_stat_row(parent, "Đang có", "%d bình" % game.bag.potion)
			desc = "Hồi phục sinh lực."
			action_text = "Sử dụng"
			action = _use_potion_from_bag
		"herb":
			_stat_row(parent, "Đang có", str(game.bag.herb))
			desc = "Dược liệu dùng để chế bình hồi phục."
		"gold":
			_stat_row(parent, "Đang có", str(game.bag.gold))
			desc = "Tiền trao đổi tại các vùng đất."
		"ore":
			_stat_row(parent, "Đang có", str(game.bag.ore))
			desc = "Nguyên liệu rèn và nâng cấp vũ khí."
		"hide":
			_stat_row(parent, "Đang có", str(game.bag.hide))
			desc = "Nguyên liệu may trang phục."
		"quest":
			desc = "%s\n\n%s" % [Content.QUESTS[game.quest][0], Content.QUESTS[game.quest][1]]
		"relic":
			desc = "Chiếc khăn cháy của Elara và con ngựa gỗ của em trai."
		"clue":
			desc = "Biểu tượng lạ tìm thấy trong tim hắc thạch."

	var description := _label(desc, UI.F_TINY, UI.TEXT_DIM)
	description.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	description.size_flags_vertical = Control.SIZE_EXPAND_FILL
	parent.add_child(description)

	if action.is_valid() and entry.owned:
		var act := _button(action_text, action)
		act.disabled = (entry.type == "weapon" and game.weapon == entry.id) \
				or (entry.type == "outfit" and game.outfit == entry.id)
		act.custom_minimum_size.y = 32
		parent.add_child(act)


func _equip_weapon(id: int) -> void:
	if game.owned_weapons.has(id):
		game.weapon = id
	inventory("equipment", inventory_selected)


func _equip_outfit(id: int) -> void:
	if game.owned_outfits.has(id):
		game.outfit = id
		game.refresh_stats()
	inventory("equipment", inventory_selected)


func _use_potion_from_bag() -> void:
	close_menu()
	game.player.heal()


# ================================================================ lo ren
func smith() -> void:
	open_menu("Lò rèn Aster", "smith", Vector2(680, 410))

	var resources := HBoxContainer.new()
	resources.alignment = BoxContainer.ALIGNMENT_CENTER
	resources.add_theme_constant_override("separation", 6)
	menu_box.add_child(resources)
	for resource in [["gold", game.bag.gold], ["ore", game.bag.ore],
			["hide", game.bag.hide], ["herb", game.bag.herb]]:
		resources.add_child(icon_rect(str(resource[0]), Vector2(20, 20)))
		resources.add_child(_label(str(resource[1]), UI.F_BODY, UI.GOLD))
		resources.add_child(_label("   ", UI.F_TINY))

	var recipes := _smith_recipes()
	if smith_selected >= recipes.size():
		smith_selected = 0

	var main := HBoxContainer.new()
	main.add_theme_constant_override("separation", 10)
	menu_box.add_child(main)

	# Danh sach cuon RIENG trong o cua no. Truoc day tam cong thuc lam cao
	# qua khung, sinh ra thanh cuon cua ca cua so va cat mat nut "Ren".
	var list_scroll := ScrollContainer.new()
	list_scroll.custom_minimum_size = Vector2(368, 276)
	list_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	main.add_child(list_scroll)
	var list := VBoxContainer.new()
	list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	list.add_theme_constant_override("separation", 4)
	list_scroll.add_child(list)
	for i in range(recipes.size()):
		list.add_child(_recipe_row(recipes[i], i))

	var detail := _card(240, 276)
	main.add_child(detail)
	_smith_details(detail, recipes[smith_selected])
	_fit_menu()


## Mot dong cong thuc: icon - ten - gia. Gia nam ngay tren dong nen khong phai
## bam vao tung muc moi biet co du nguyen lieu hay khong.
func _recipe_row(recipe: Dictionary, index: int) -> Control:
	var b := _button("", _select_recipe.bind(index))
	b.custom_minimum_size.y = 40
	b.focus_mode = Control.FOCUS_NONE
	b.disabled = not recipe.enabled
	if index == smith_selected:
		b.add_theme_stylebox_override("normal", UI.slot_box("selected"))
		b.add_theme_stylebox_override("disabled", UI.slot_box("selected"))

	var row := HBoxContainer.new()
	row.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	row.offset_left = 10
	row.offset_right = -10
	row.add_theme_constant_override("separation", 9)
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	b.add_child(row)

	row.add_child(icon_rect(str(recipe.icon), Vector2(24, 24)))
	var name_label := _label(str(recipe.name), UI.F_BODY, UI.TEXT if recipe.enabled else UI.TEXT_OFF)
	name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	name_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	row.add_child(name_label)
	var cost := _label(str(recipe.cost), UI.F_MICRO, UI.GOLD_DIM if recipe.enabled else UI.TEXT_OFF)
	cost.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	row.add_child(cost)
	return b


func _smith_recipes() -> Array:
	var price: int = 20 + int(game.weapon_levels[game.weapon]) * 20
	return [
		{"name": "Nâng %s" % Content.WEAPONS[game.weapon].name, "icon": Content.WEAPONS[game.weapon].kind,
			"cost": "%d vàng · 2 quặng" % price, "desc": "Tăng 5 sát thương. Tối đa +5.",
			"enabled": game.bag.gold >= price and game.bag.ore >= 2 and game.weapon_levels[game.weapon] < 5,
			"kind": "upgrade", "index": -1},
		{"name": "Cung thợ săn", "icon": "bow", "cost": "25 vàng · 2 quặng",
			"desc": "Vũ khí tầm xa nhanh và ổn định.",
			"enabled": not game.owned_weapons.has(2) and game.bag.gold >= 25 and game.bag.ore >= 2,
			"kind": "bow", "index": -1},
		{"name": "Trượng tinh thạch", "icon": "staff", "cost": "55 vàng · 5 quặng",
			"desc": "Vũ khí tầm xa có sát thương lớn.",
			"enabled": not game.owned_weapons.has(3) and game.bag.gold >= 55 and game.bag.ore >= 5,
			"kind": "staff", "index": -1},
		{"name": "Áo thợ săn", "icon": "armor", "cost": "20 vàng · 1 da",
			"desc": "Trang phục nhẹ, cộng 3 giáp.",
			"enabled": not game.owned_outfits.has(1) and game.bag.gold >= 20 and game.bag.hide >= 1,
			"kind": "outfit", "index": 1},
		{"name": "Giáp lữ hành", "icon": "armor", "cost": "40 vàng · 2 da",
			"desc": "Trang phục bền, cộng 6 giáp.",
			"enabled": not game.owned_outfits.has(2) and game.bag.gold >= 40 and game.bag.hide >= 2,
			"kind": "outfit", "index": 2},
		{"name": "Áo người giữ lửa", "icon": "armor", "cost": "60 vàng · 3 da",
			"desc": "Dấu hiệu của hy vọng, cộng 4 giáp.",
			"enabled": not game.owned_outfits.has(3) and game.bag.gold >= 60 and game.bag.hide >= 3,
			"kind": "outfit", "index": 3},
		{"name": "Chế bình hồi phục", "icon": "potion", "cost": "2 dược thảo",
			"desc": "Chế một bình hồi phục.", "enabled": game.bag.herb >= 2,
			"kind": "potion", "index": -1},
		{"name": "Mua bình hồi phục", "icon": "potion", "cost": "12 vàng",
			"desc": "Mua một bình hồi phục.", "enabled": game.bag.gold >= 12,
			"kind": "buy_potion", "index": -1},
	]


func _select_recipe(index: int) -> void:
	smith_selected = index
	smith()


func _smith_details(parent: PanelContainer, recipe: Dictionary) -> void:
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 7)
	parent.add_child(box)

	var icon := icon_rect(str(recipe.icon), Vector2(72, 72))
	icon.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	box.add_child(icon)
	var heading := _label(str(recipe.name), UI.F_LEAD, UI.GOLD)
	heading.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	heading.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	box.add_child(heading)
	box.add_child(HSeparator.new())

	var desc := _label(str(recipe.desc), UI.F_TINY, UI.TEXT_DIM)
	desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	desc.size_flags_vertical = Control.SIZE_EXPAND_FILL
	box.add_child(desc)
	_stat_row(box, "Cần", str(recipe.cost))

	var craft := _button("RÈN / CHẾ TẠO", _craft_recipe.bind(recipe.kind, recipe.index))
	craft.icon = UI.icon("forge")
	craft.expand_icon = true
	craft.add_theme_constant_override("icon_max_width", 20)
	craft.disabled = not recipe.enabled
	craft.custom_minimum_size.y = 36
	box.add_child(craft)


func _craft_recipe(kind: String, index: int) -> void:
	if index >= 0:
		game.craft(kind, index)
	else:
		game.craft(kind)
	smith()


# ================================================================ ban do vung
func atlas() -> void:
	open_menu("Bản đồ các vùng đất", "atlas", Vector2(680, 400))
	prose("●  đang ở đây        ◇  đã khám phá        ·  chưa đặt chân tới", UI.F_MICRO, UI.TEXT_DIM)

	var regions := HBoxContainer.new()
	regions.add_theme_constant_override("separation", 8)
	menu_box.add_child(regions)
	for region in [["I · MIỀN TRO", range(0, 5)], ["II · BIÊN ĐỊA", range(5, 7)],
			["III · CÕI SƯƠNG", range(7, 10)]]:
		var card := _card(196, 234)
		regions.add_child(card)
		var box := VBoxContainer.new()
		box.add_theme_constant_override("separation", 5)
		card.add_child(box)
		var heading := _label(str(region[0]), UI.F_TINY, UI.GOLD_DIM)
		heading.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		box.add_child(heading)
		box.add_child(HSeparator.new())
		for i in region[1]:
			var here: bool = game.map_id == i
			var seen: bool = game.visited.has(i)
			var mark := "●" if here else ("◇" if seen else "·")
			var row := _label("%s  %s" % [mark, Content.MAPS[i].name], UI.F_TINY,
					UI.GOLD if here else (UI.TEXT if seen else UI.TEXT_OFF))
			row.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			box.add_child(row)

	prose("Đi tới vòng sáng ở lối ra và nhấn E để chuyển bản đồ. Vùng càng xa thì quái càng mạnh.",
			UI.F_TINY, UI.TEXT_DIM)
	_fit_menu()


# ================================================================ hoi thoai
func dialogue(speaker: String, lines: Array, ending: Callable = Callable(), choices: Array = []) -> void:
	dialogue_lines = lines
	dialogue_index = 0
	dialogue_end = ending
	dialogue_choices = choices
	dialogue_title = speaker
	_show_line()


## Hoi thoai nam DUOI DAY man hinh, khong phai giua. Day la cho quen thuoc cua
## the loai, va no khong che mat canh dang dien ra.
func _show_line() -> void:
	var box_size := Vector2(760, 186)
	open_menu(dialogue_title, "dialogue", box_size,
			Vector2((VIEW.x - box_size.x) * 0.5, VIEW.y - box_size.y - 26))

	dialogue_text = _label(str(dialogue_lines[dialogue_index]), UI.F_LEAD, UI.TEXT)
	dialogue_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	dialogue_text.add_theme_constant_override("line_spacing", 5)
	# Chieu cao toi thieu co dinh: o thoai khong nhay len nhay xuong giua cac
	# cau ngan va cau dai.
	dialogue_text.custom_minimum_size.y = 74
	dialogue_text.size_flags_vertical = Control.SIZE_EXPAND_FILL
	menu_box.add_child(dialogue_text)

	var foot := HBoxContainer.new()
	foot.add_theme_constant_override("separation", 8)
	menu_box.add_child(foot)
	var count := _label("%d / %d" % [dialogue_index + 1, dialogue_lines.size()], UI.F_MICRO, UI.TEXT_DIM)
	count.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	count.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	foot.add_child(count)

	if dialogue_index == dialogue_lines.size() - 1 and not dialogue_choices.is_empty():
		for choice in dialogue_choices:
			var b := _button(str(choice[0]), _choose_dialogue.bind(choice[1]))
			b.custom_minimum_size.y = 32
			foot.add_child(b)
	else:
		var last := dialogue_index == dialogue_lines.size() - 1
		var b := _button("Kết thúc  [E]" if last else "Tiếp tục  [E]", advance_dialogue)
		b.custom_minimum_size = Vector2(150, 32)
		foot.add_child(b)
	_fit_menu("bottom")


func _choose_dialogue(action: Callable) -> void:
	close_menu()
	action.call()


func advance_dialogue() -> void:
	if dialogue_index == dialogue_lines.size() - 1 and not dialogue_choices.is_empty():
		return
	dialogue_index += 1
	if dialogue_index >= dialogue_lines.size():
		close_menu()
		if dialogue_end.is_valid():
			dialogue_end.call()
	else:
		_show_line()


# ================================================================ hoi sinh
func death_screen() -> void:
	open_menu("Ngọn lửa chưa tắt", "death", Vector2(440, 260))
	var icon := icon_rect("shield", Vector2(64, 64))
	icon.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	menu_box.add_child(icon)
	var text := _label("Kael gục xuống, nhưng ngọn lửa trong cậu chưa tắt.", UI.F_BODY, UI.TEXT)
	text.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	menu_box.add_child(text)
	var loss := _label("Mất 10% vàng  ·  giữ lại trang bị, vật phẩm và tiến độ", UI.F_MICRO, UI.TEXT_DIM)
	loss.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	loss.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	menu_box.add_child(loss)
	option("ĐỨNG DẬY TẠI ASTER", func(): game.respawn())
	_fit_menu()
