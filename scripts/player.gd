extends CharacterBody2D

## Nhan vat nguoi choi: di chuyen 4 huong va doi frame hoat anh theo huong di.
##
## CharacterBody2D la loai node danh cho nhan vat co va cham nhung do BAN
## dieu khien (khac voi RigidBody2D bi vat ly keo di).


## @export nghia la bien nay hien ra trong Inspector cua Godot,
## ban chinh duoc ma khong can sua code.
## Tinh bang pixel/giay. Khi doi luoi tu 16px sang 32px, moi thu to gap doi
## nen toc do cung phai gap doi thi cam giac di chuyen moi giu nguyen.
@export var speed: float = 140.0

## So frame chay qua trong 1 giay khi di bo.
@export var anim_fps: float = 8.0

# Thu tu hang trong file assets/sprites/player.png
const DIR_DOWN := 0
const DIR_UP := 1
const DIR_LEFT := 2
const DIR_RIGHT := 3

var _facing: int = DIR_DOWN
var _anim_time: float = 0.0
var _joystick: Node = null

# @onready = lay node con sau khi scene da dung xong.
@onready var _sprite: Sprite2D = $Sprite2D


func _physics_process(delta: float) -> void:
	var direction := _read_input()

	# velocity la thuoc tinh san co cua CharacterBody2D.
	velocity = direction * speed
	# move_and_slide() di chuyen nhan vat va tu dong xu ly va cham voi tuong.
	move_and_slide()

	_update_animation(direction, delta)


## Gop moi nguon dieu khien (phim, gamepad, joystick cam ung) thanh 1 vector.
func _read_input() -> Vector2:
	var direction := Vector2.ZERO

	# ui_right/ui_left/... la cac action co san cua Godot, mac dinh gan voi
	# phim mui ten va D-pad tay cam. Them WASD cho nguoi choi PC.
	if Input.is_action_pressed("ui_right") or Input.is_key_pressed(KEY_D):
		direction.x += 1.0
	if Input.is_action_pressed("ui_left") or Input.is_key_pressed(KEY_A):
		direction.x -= 1.0
	if Input.is_action_pressed("ui_down") or Input.is_key_pressed(KEY_S):
		direction.y += 1.0
	if Input.is_action_pressed("ui_up") or Input.is_key_pressed(KEY_W):
		direction.y -= 1.0

	# Chuan hoa de di cheo khong nhanh hon di thang.
	if direction != Vector2.ZERO:
		direction = direction.normalized()
	else:
		# Khong bam phim thi thu doc joystick cam ung (tren dien thoai).
		var stick := _get_joystick()
		if stick != null:
			direction = stick.get_direction()

	return direction


## Chon frame dung trong sprite sheet 4 cot x 4 hang.
func _update_animation(direction: Vector2, delta: float) -> void:
	if direction != Vector2.ZERO:
		# Dang di: cap nhat huong nhin theo truc co do lech lon hon.
		if absf(direction.x) > absf(direction.y):
			_facing = DIR_RIGHT if direction.x > 0.0 else DIR_LEFT
		else:
			_facing = DIR_DOWN if direction.y > 0.0 else DIR_UP
		_anim_time += delta * anim_fps
	else:
		# Dung yen: quay ve frame 0 (tu the dung).
		_anim_time = 0.0

	var column := int(_anim_time) % _sprite.hframes
	# Sprite2D danh so frame tu trai sang phai, tren xuong duoi.
	_sprite.frame = _facing * _sprite.hframes + column


## Tim joystick ao. Tim lai moi khi chua co vi thu tu khoi tao cua cac node
## trong scene khong dam bao joystick da san sang truoc nhan vat.
func _get_joystick() -> Node:
	if _joystick == null or not is_instance_valid(_joystick):
		_joystick = get_tree().get_first_node_in_group("touch_joystick")
	return _joystick
