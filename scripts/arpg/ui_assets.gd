extends RefCounted
## He mau, co chu va khung vien cho toan bo giao dien Aster.
##
## NGUYEN TAC BO CUC - ba dieu nay la ly do ban cu bi roi mat:
##
## 1. TRANG TRI PHAI CO THU BAC. Khung vien cham tron chi dung cho CUA SO
##    (tui do, lo ren, hoi thoai). Thanh trang thai va thanh ky nang tren man
##    hinh dung khung phang, mo, vien 1px. Khi moi thu deu duoc vien vang thi
##    khong cai nao noi bat ca.
##
## 2. KHONG LONG KHUNG TRONG KHUNG. Thanh ky nang cu la mot khung cham tron,
##    ben trong lai la bay o cung cham tron. Ban moi bo khung ngoai di.
##
## 3. MAU VANG LA DAU NHAN, KHONG PHAI MAU NEN. Vang chi dung cho tieu de,
##    o dang chon va so lieu quan trong.

const ROOT := "res://assets/ui/"
const LEGACY := "res://assets/arpg_v2/"

# ---------------------------------------------------------------- he mau
const INK        := Color("0d0b0a")   # nen toi nhat, dung cho lop phu
const PANEL      := Color("171412")   # nen khung
const PANEL_SOFT := Color("221d19")   # nen o, nen o trong
const LINE       := Color("3b322a")   # vien mo - mac dinh
const LINE_HI    := Color("7a6038")   # vien khi ro chuot
const GOLD       := Color("e3ba68")
const GOLD_DIM   := Color("a98a4e")
const TEXT       := Color("ece4d6")
const TEXT_DIM   := Color("9c9184")
const TEXT_OFF   := Color("6b6259")   # chu cho muc chua so huu
const HP         := Color("bf4a40")
const STAMINA    := Color("6d9b73")
const XP         := Color("c8973f")
const GOOD       := Color("92c294")
const BAD        := Color("d4705f")

# ---------------------------------------------------------------- co chu
const F_MICRO := 9
const F_TINY  := 11
const F_BODY  := 13
const F_LEAD  := 15
const F_HEAD  := 18
const F_TITLE := 22

static var _cache: Dictionary = {}


## Anh giao dien da duoc thu nho san bang tools/make_ui_art.gd.
## Ban goc 1254px nam trong assets/arpg_v2/ va khong duoc ve thang ra man hinh:
## thu nho 1254 -> 38 bang loc song tuyen chinh la thu lam icon nat thanh vet mo.
static func texture(name: String) -> Texture2D:
	if _cache.has(name):
		return _cache[name]
	var result: Texture2D = null
	for path in [ROOT + name + ".png", LEGACY + name + ".png"]:
		if ResourceLoader.exists(path):
			result = load(path) as Texture2D
			break
	_cache[name] = result
	return result


static func icon(name: String) -> Texture2D:
	return texture("icons/" + name)


# ---------------------------------------------------------------- khung vien
static func flat(bg: Color, border: Color, radius: int = 4, width: int = 1, pad: int = 8) -> StyleBoxFlat:
	var box := StyleBoxFlat.new()
	box.bg_color = bg
	box.border_color = border
	box.set_border_width_all(width)
	box.set_corner_radius_all(radius)
	box.content_margin_left = pad
	box.content_margin_right = pad
	box.content_margin_top = int(pad * 0.7)
	box.content_margin_bottom = int(pad * 0.7)
	return box


## Khung cho thong tin tren man hinh choi: mo, phang, gan nhu vo hinh.
## Viec cua no la giup chu doc duoc tren nen co va da, khong phai de dep.
static func hud_box(alpha: float = 0.74) -> StyleBoxFlat:
	var bg := PANEL
	bg.a = alpha
	return flat(bg, Color(LINE.r, LINE.g, LINE.b, 0.8), 4, 1, 9)


## Khung cham tron - CHI dung cho cua so. Day la thu danh dau "day la mot cua
## so that", nen neu dung khap noi thi no khong con danh dau duoc gi.
static func window_box() -> StyleBox:
	var tex := texture("panel")
	if tex == null:
		return flat(Color("14110f"), GOLD_DIM, 6, 2, 16)
	var box := StyleBoxTexture.new()
	box.texture = tex
	box.set_texture_margin_all(30.0)
	box.content_margin_left = 20
	box.content_margin_right = 20
	box.content_margin_top = 16
	box.content_margin_bottom = 16
	box.axis_stretch_horizontal = StyleBoxTexture.AXIS_STRETCH_MODE_STRETCH
	box.axis_stretch_vertical = StyleBoxTexture.AXIS_STRETCH_MODE_STRETCH
	return box


## O chua vat pham / ky nang. Vuong, phang, de icon tu no noi len.
static func slot_box(state: String = "normal") -> StyleBoxFlat:
	match state:
		"selected":
			return flat(Color("2e2519"), GOLD, 3, 2, 4)
		"hover":
			return flat(Color("2a2420"), LINE_HI, 3, 1, 4)
		"empty":
			return flat(Color("14120f"), Color(LINE.r, LINE.g, LINE.b, 0.55), 3, 1, 4)
		_:
			return flat(PANEL_SOFT, LINE, 3, 1, 4)


static func button_box(state: String = "normal") -> StyleBoxFlat:
	match state:
		"hover", "focus":
			return flat(Color("33291e"), LINE_HI, 4, 1, 12)
		"pressed":
			return flat(Color("1a1512"), GOLD_DIM, 4, 1, 12)
		"disabled":
			return flat(Color("1a1816"), Color("2e2a26"), 4, 1, 12)
		_:
			return flat(Color("241e18"), LINE, 4, 1, 12)


## Nut phu: chi co chu, khong co nen - dung cho tab va nut dong.
static func ghost_box(state: String = "normal") -> StyleBoxFlat:
	match state:
		"hover", "focus":
			return flat(Color(1, 1, 1, 0.07), Color(LINE_HI.r, LINE_HI.g, LINE_HI.b, 0.7), 4, 1, 10)
		"pressed":
			return flat(Color("2e2519"), GOLD, 4, 1, 10)
		_:
			return flat(Color(0, 0, 0, 0), Color(0, 0, 0, 0), 4, 1, 10)


static func apply_theme(theme: Theme) -> void:
	theme.default_font_size = F_BODY

	theme.set_color("font_color", "Label", TEXT)
	theme.set_color("font_shadow_color", "Label", Color(0, 0, 0, 0.85))
	theme.set_constant("shadow_offset_x", "Label", 1)
	theme.set_constant("shadow_offset_y", "Label", 1)

	for state in ["normal", "hover", "pressed", "focus", "disabled"]:
		theme.set_stylebox(state, "Button", button_box(state))
	theme.set_color("font_color", "Button", TEXT)
	theme.set_color("font_hover_color", "Button", Color("fff0cc"))
	theme.set_color("font_pressed_color", "Button", GOLD)
	theme.set_color("font_disabled_color", "Button", TEXT_OFF)
	theme.set_color("font_shadow_color", "Button", Color(0, 0, 0, 0.8))
	theme.set_constant("shadow_offset_y", "Button", 1)
	theme.set_constant("h_separation", "Button", 8)

	theme.set_stylebox("panel", "PanelContainer", hud_box())
	theme.set_color("font_color", "RichTextLabel", TEXT)
	theme.set_color("default_color", "RichTextLabel", TEXT)
	theme.set_color("separator", "HSeparator", Color(LINE.r, LINE.g, LINE.b, 0.9))
	theme.set_constant("separation", "HSeparator", 8)
