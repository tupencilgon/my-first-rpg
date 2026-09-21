extends Control

## Joystick ao cho man hinh cam ung (Android / iOS).
##
## Cach dung: nguoi choi cham vao nua trai man hinh -> joystick hien ra ngay
## tai diem cham, keo ngon tay de di chuyen. Kieu "floating joystick" nay de
## choi hon loai co dinh mot cho.
##
## Tren PC joystick tu an di. Bat "always_show" trong Inspector neu muon
## nhin thay no khi chay thu tren may tinh.

## Ban kinh vung keo, tinh bang pixel cua game (khong phai pixel man hinh that).
@export var radius: float = 68.0

## Keo duoi nguong nay thi coi nhu khong di chuyen - tranh rung tay.
@export var dead_zone: float = 0.18

## Bat len de test joystick tren PC (dung chung voi Project Settings >
## Input Devices > Pointing > Emulate Touch From Mouse).
@export var always_show: bool = false

var _touch_index: int = -1
var _origin: Vector2 = Vector2.ZERO
var _current: Vector2 = Vector2.ZERO
var _active: bool = false


func _ready() -> void:
	# Dua node vao group de player.gd tim thay ma khong can biet duong dan.
	add_to_group("touch_joystick")

	var enabled := always_show or DisplayServer.is_touchscreen_available()
	visible = enabled
	set_process_unhandled_input(enabled)


## Tra ve huong di chuyen, do dai tu 0.0 den 1.0.
## player.gd goi ham nay moi frame.
func get_direction() -> Vector2:
	if not _active:
		return Vector2.ZERO

	var offset := _current - _origin
	var strength := clampf(offset.length() / radius, 0.0, 1.0)
	if strength < dead_zone:
		return Vector2.ZERO
	return offset.normalized() * strength


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.pressed:
			# Chi nhan ngon tay dau tien, va chi o nua trai man hinh
			# (nua phai de danh cho nut tan cong sau nay).
			if _touch_index == -1 and event.position.x < size.x * 0.5:
				_touch_index = event.index
				_origin = event.position
				_current = event.position
				_active = true
				queue_redraw()
		elif event.index == _touch_index:
			_touch_index = -1
			_active = false
			queue_redraw()

	elif event is InputEventScreenDrag and event.index == _touch_index:
		_current = event.position
		queue_redraw()


## _draw() duoc goi lai moi khi ta gan queue_redraw().
func _draw() -> void:
	if not _active:
		return
	draw_circle(_origin, radius, Color(1.0, 1.0, 1.0, 0.13))
	var knob := _origin + (_current - _origin).limit_length(radius)
	draw_circle(knob, radius * 0.45, Color(1.0, 1.0, 1.0, 0.33))
