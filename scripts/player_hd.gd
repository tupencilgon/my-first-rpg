extends CharacterBody2D

## BAN THU huong "gia pixel art": art vao game o do phan giai goc cua no,
## khong ep ve luoi 32px, khong convert gi.
##
## Khac gi ban chinh (scripts/player.gd):
##   - Sprite cao 126px thay vi 32px, nen toc do phai to hon khoang 4 lan
##   - MOI huong chi co MOT hinh, chua co chu ky buoc chan o do phan giai nay
##   - Thay chu ky buoc bang mot nhip NHUN NHAY len-xuong vai pixel
##
## Nhun nhay la meo cu nhung doc ra duoc: mat nguoi thay co nhip la thay
## "dang di". No khong thay duoc animation that, nhung du de thu cam giac
## choi truoc khi bo cong ve 16 frame o co 126px.

## Pixel/giay. Moi thu to gap ~4 lan ban 32px nen toc do cung phai gap ~4.
@export var speed: float = 340.0

## So nhip nhun trong 1 giay khi di.
@export var bob_speed: float = 9.0

## Nhun cao bao nhieu pixel.
@export var bob_height: float = 4.0

# Thu tu cot trong sheet kael_hd.png
const DIR_DOWN := 0
const DIR_UP := 1
const DIR_LEFT := 2
const DIR_RIGHT := 3

## Ban chan nam o hang 133 cua o cao 136. Sprite ve can giua nen phai keo len
## 66 pixel de goc toa do node trung voi ban chan - cung quy uoc voi prop.
const FOOT_OFFSET := -66.0

var _facing: int = DIR_DOWN
var _walk_time: float = 0.0

@onready var _sprite: Sprite2D = $Sprite2D


func _physics_process(delta: float) -> void:
	var direction := _read_input()
	velocity = direction * speed
	move_and_slide()

	if direction != Vector2.ZERO:
		if absf(direction.x) > absf(direction.y):
			_facing = DIR_RIGHT if direction.x > 0.0 else DIR_LEFT
		else:
			_facing = DIR_DOWN if direction.y > 0.0 else DIR_UP
		_walk_time += delta * bob_speed
	else:
		_walk_time = 0.0

	_sprite.frame = _facing
	# abs(sin) cho nhip nhun len roi ha xuong, khong bao gio chim duoi 0 -
	# nhan vat nhac nguoi len chu khong lun xuong dat.
	_sprite.offset.y = FOOT_OFFSET - absf(sin(_walk_time)) * bob_height


func _read_input() -> Vector2:
	var direction := Vector2.ZERO
	if Input.is_action_pressed("ui_right") or Input.is_key_pressed(KEY_D):
		direction.x += 1.0
	if Input.is_action_pressed("ui_left") or Input.is_key_pressed(KEY_A):
		direction.x -= 1.0
	if Input.is_action_pressed("ui_down") or Input.is_key_pressed(KEY_S):
		direction.y += 1.0
	if Input.is_action_pressed("ui_up") or Input.is_key_pressed(KEY_W):
		direction.y -= 1.0
	if direction != Vector2.ZERO:
		direction = direction.normalized()
	return direction
