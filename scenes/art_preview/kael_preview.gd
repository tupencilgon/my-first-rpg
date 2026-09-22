extends Node2D

## Scene thử riêng để xem art mới mà không sửa bản đồ hay trang bị hiện có.
const FRAMES = preload("res://assets/sprites/kael_v02/kael_frames.tres")
var actor: CharacterBody2D
var actor_sprite: AnimatedSprite2D
var facing := "down"

func label_at(words: String, at: Vector2, font_size: int = 14) -> void:
	var label := Label.new()
	label.text = words
	label.position = at
	label.add_theme_font_size_override("font_size", font_size)
	add_child(label)

func _ready() -> void:
	RenderingServer.set_default_clear_color(Color("222832"))
	label_at("KAEL — BỘ DI CHUYỂN v02", Vector2(24, 12), 20)
	label_at("4 hướng · 4 frame/hướng · 32 × 32 px · 8 frame/giây", Vector2(24, 41))
	var names := ["down", "up", "left", "right"]
	var titles := ["Xuống", "Lên", "Trái", "Phải"]
	for i in range(4):
		var sprite := AnimatedSprite2D.new()
		sprite.sprite_frames = FRAMES
		sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		sprite.position = Vector2(90 + i * 150, 122)
		sprite.scale = Vector2(3, 3)
		add_child(sprite)
		sprite.play("walk_" + names[i])
		label_at(titles[i], Vector2(70 + i * 150, 174))
	label_at("WASD / phím mũi tên: di chuyển nhân vật bên dưới", Vector2(24, 214))
	label_at("Bản ghép sẵn trang phục; chưa dùng cho đổi đồ phân lớp.", Vector2(24, 333), 12)
	actor = CharacterBody2D.new()
	actor.position = Vector2(320, 278)
	add_child(actor)
	actor_sprite = AnimatedSprite2D.new()
	actor_sprite.sprite_frames = FRAMES
	actor_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	actor.add_child(actor_sprite)
	actor_sprite.play("idle_down")
	# Kiểm tra dữ liệu thật; thiếu frame hoặc sai kích thước thì báo lỗi ngay.
	for direction in names:
		assert(FRAMES.get_frame_count("walk_" + direction) == 4)
		for frame_index in range(4):
			assert(FRAMES.get_frame_texture("walk_" + direction, frame_index).get_size() == Vector2(32, 32))
	print("KAEL_ASSET_OK: 4 directions, 16 frames, 32x32, 8 fps")
	if "--art-capture" in OS.get_cmdline_user_args():
		capture_preview()
	elif "--art-test" in OS.get_cmdline_user_args():
		test_movement()

func _physics_process(_delta: float) -> void:
	var direction := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	if Input.is_key_pressed(KEY_A): direction.x -= 1
	if Input.is_key_pressed(KEY_D): direction.x += 1
	if Input.is_key_pressed(KEY_W): direction.y -= 1
	if Input.is_key_pressed(KEY_S): direction.y += 1
	direction = direction.limit_length()
	actor.velocity = direction * 140
	actor.move_and_slide()
	actor.position = actor.position.clamp(Vector2(25, 260), Vector2(615, 310))
	if direction != Vector2.ZERO:
		if absf(direction.x) > absf(direction.y):
			facing = "right" if direction.x > 0 else "left"
		else:
			facing = "down" if direction.y > 0 else "up"
		actor_sprite.play("walk_" + facing)
	else:
		actor_sprite.play("idle_" + facing)

func capture_preview() -> void:
	# Chụp bằng renderer thật sau khi các texture đã có thời gian hiển thị.
	await get_tree().create_timer(0.6).timeout
	await RenderingServer.frame_post_draw
	var path := "C:/Users/PC/Documents/Codex/2026-09-22/d-gamedev-projects-my-first-rpg/outputs/kael-v02/kael_godot_preview.png"
	var result := get_viewport().get_texture().get_image().save_png(path)
	print("KAEL_CAPTURE: ", result)
	get_tree().quit(result)

func test_movement() -> void:
	# Thử đầu vào và animation thực, không chỉ kiểm tra tên file.
	var cases := [["ui_down", "down", Vector2.DOWN], ["ui_up", "up", Vector2.UP], ["ui_left", "left", Vector2.LEFT], ["ui_right", "right", Vector2.RIGHT]]
	for item in cases:
		actor.position = Vector2(320, 280)
		Input.action_press(item[0])
		await get_tree().create_timer(0.18).timeout
		assert(actor_sprite.animation == "walk_" + item[1])
		assert((actor.position - Vector2(320, 280)).dot(item[2]) > 10)
		assert(actor_sprite.frame > 0)
		Input.action_release(item[0])
		await get_tree().create_timer(0.05).timeout
		assert(actor_sprite.animation == "idle_" + item[1])
		assert(actor_sprite.frame == 0)
	print("KAEL_MOVEMENT_OK: all directions move, animate, and stop in idle")
	get_tree().quit()
