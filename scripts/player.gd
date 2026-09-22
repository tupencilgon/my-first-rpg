extends CharacterBody2D

## Nhan vat nguoi choi: di chuyen 4 huong, doi frame hoat anh theo huong di,
## va hien trang bi bang he thong SPRITE PHAN LOP.
##
## CharacterBody2D la loai node danh cho nhan vat co va cham nhung do BAN
## dieu khien (khac voi RigidBody2D bi vat ly keo di).
##
## === SPRITE PHAN LOP ===
## Nhan vat khong phai mot anh duy nhat ma la 4 Sprite2D chong len nhau:
##     Body   -> than the (luon hien)
##     Outfit -> bo do: giap + quan
##     Helmet -> mu
##     Weapon -> vu khi, chi hien khi dang chien dau
## Ca 4 lop dung chung MOT chi so frame, nen chung luon khop nhau tuyet doi.
## Nho vay 3 bo do + 3 mu chi can 6 file anh nhung ra duoc 9 ve ngoai.


## Tinh bang pixel/giay. Khi doi luoi tu 16px sang 32px, moi thu to gap doi
## nen toc do cung phai gap doi thi cam giac di chuyen moi giu nguyen.
@export var speed: float = 140.0

## So frame chay qua trong 1 giay khi di bo.
@export var anim_fps: float = 8.0

# Thu tu hang trong moi file sprite sheet.
const DIR_DOWN := 0
const DIR_UP := 1
const DIR_LEFT := 2
const DIR_RIGHT := 3

# --- Danh muc trang bi ---
# Chuoi rong "" nghia la khong mac gi (lop do se bi an di).
# Day chi la ban tam de thu nghiem. Sau nay se thay bang he thong tui do
# doc du lieu tu file Resource (.tres), khong viet cung trong code nhu the nay.
## Sprite Kael do AI ve, da mac san quan ao - KHONG chong lop Outfit len tren.
## Vi vay `_outfit_index` mac dinh la 0 (khong mac gi).
##
## He thong phan lop van con nguyen o day. Demo khong co doi trang bi nen chua
## can den no; khi nao lam ban co chien dau va trang bi doi duoc thi phai tach
## sprite nay thanh hai lop Body (nguoi tran) va Outfit (quan ao) rieng.
const BODY := "res://assets/sprites/kael_v02/kael_walk_v02.png"

## Sprite placeholder cu, giu lai de doi chieu khi tach lop.
const BODY_PLACEHOLDER := "res://assets/sprites/body_male.png"
const OUTFITS: Array[String] = [
	"",
	"res://assets/sprites/outfit_cloth.png",
	"res://assets/sprites/outfit_leather.png",
]
const HELMETS: Array[String] = [
	"",
	"res://assets/sprites/helmet_iron.png",
]
const WEAPONS: Array[String] = [
	"res://assets/sprites/weapon_sword.png",
	"res://assets/sprites/weapon_bow.png",
]

var _facing: int = DIR_DOWN
var _anim_time: float = 0.0
var _joystick: Node = null

var _outfit_index: int = 0
var _helmet_index: int = 0
var _weapon_index: int = 0
var _in_combat: bool = false

# @onready = lay node con sau khi scene da dung xong.
@onready var _body: Sprite2D = $Body
@onready var _outfit: Sprite2D = $Outfit
@onready var _helmet: Sprite2D = $Helmet
@onready var _weapon: Sprite2D = $Weapon
@onready var _layers: Array[Sprite2D] = [_body, _outfit, _helmet, _weapon]


func _ready() -> void:
	_refresh_equipment()


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


## Chon frame dung trong luoi 4 cot x 4 hang, roi gan cho CA BON lop.
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

	_apply_frame()


## Gan cung MOT chi so frame cho ca bon lop. Day la toan bo bi mat cua he
## thong phan lop - cac lop khop nhau vi chung luon o cung mot frame.
func _apply_frame() -> void:
	# Sprite2D danh so frame tu trai sang phai, tren xuong duoi.
	var column := int(_anim_time) % _body.hframes
	var frame_index := _facing * _body.hframes + column
	for layer in _layers:
		layer.frame = frame_index


## Nap dung anh cho tung lop theo trang bi hien tai.
func _refresh_equipment() -> void:
	_set_layer(_body, BODY)
	_set_layer(_outfit, OUTFITS[_outfit_index])
	_set_layer(_helmet, HELMETS[_helmet_index])
	# Vu khi chi tuot ra khi dang chien dau.
	_set_layer(_weapon, WEAPONS[_weapon_index] if _in_combat else "")


## Gan anh cho mot lop. Duong dan rong = khong mac gi = an lop do di.
func _set_layer(layer: Sprite2D, path: String) -> void:
	if path.is_empty():
		layer.visible = false
		return
	layer.texture = load(path)
	layer.visible = true


## Phim tam de xem he thong phan lop hoat dong. Se bo khi co menu trang bi that.
func _unhandled_input(event: InputEvent) -> void:
	if not (event is InputEventKey and event.pressed and not event.echo):
		return

	match event.keycode:
		KEY_1:
			_outfit_index = (_outfit_index + 1) % OUTFITS.size()
		KEY_2:
			_helmet_index = (_helmet_index + 1) % HELMETS.size()
		KEY_3:
			_weapon_index = (_weapon_index + 1) % WEAPONS.size()
		KEY_4:
			_in_combat = not _in_combat
		_:
			return

	_refresh_equipment()
	# Gan lai frame ngay, neu khong lop vua doi se hien frame 0 mot nhip.
	_apply_frame()


## Tim joystick ao. Tim lai moi khi chua co vi thu tu khoi tao cua cac node
## trong scene khong dam bao joystick da san sang truoc nhan vat.
func _get_joystick() -> Node:
	if _joystick == null or not is_instance_valid(_joystick):
		_joystick = get_tree().get_first_node_in_group("touch_joystick")
	return _joystick
