extends CharacterBody2D
## Gốc tọa độ nằm ở chân. Hướng nhìn lấy từ vector di chuyển, không lật ngược sprite.
const Content = preload("res://scripts/arpg/content.gd")
const MonsterVisuals = preload("res://scripts/arpg/monster_visuals.gd")
const KAEL = preload("res://assets/sprites/kael_v03/kael_walk_v03.png")
var game:Node
var role = "player"
var title = "Kael"
var kind = "Sói tro"
var facing = Vector2.DOWN
var hp:float = 100.0
var max_hp:float = 100.0
var stamina:float = 100.0
var max_stamina:float = 100.0
var armor = 0
var power = 10
var speed = 130.0
var xp_value = 15
var boss = false
var state = "idle"
var state_time = 0.0
var clock = 0.0
var attack_cd = 0.0
var hurt_cd = 0.0
var skill_cd = 0.0
var heal_cd = 0.0
var guard_time = 0.0
var guarding = false
var dash_dir = Vector2.DOWN
var windup = 0.0
var strike_visual = 0.0
var death_visual_time = 0.0
var strike_target = Vector2.ZERO
var tint = Color("9b7960")
var home = Vector2.ZERO
var walk_phase = 0.0

func _ready() -> void:
	collision_layer = 2 if role == "player" else 4
	collision_mask = 1
	var shape = CollisionShape2D.new()
	var circle = CircleShape2D.new()
	circle.radius = 7.0 if not boss else 19.0
	shape.shape = circle
	shape.position.y = -5
	add_child(shape)
	if role == "player":
		home = position

func motion_input() -> Vector2:
	return Vector2(float(Input.is_physical_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT))-float(Input.is_physical_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT)), float(Input.is_physical_key_pressed(KEY_S) or Input.is_key_pressed(KEY_DOWN))-float(Input.is_physical_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP))).normalized()

func face(direction:Vector2) -> int:
	if direction.length_squared() > 0.001:
		facing = direction.normalized()
	if absf(facing.x) > absf(facing.y):
		return 3 if facing.x > 0 else 2
	return 0 if facing.y >= 0 else 1

func set_state(value:String, duration:float) -> void:
	state = value
	state_time = duration

func _physics_process(dt:float) -> void:
	if not is_instance_valid(game) or game.paused:
		return
	clock += dt
	attack_cd = maxf(0, attack_cd-dt)
	hurt_cd = maxf(0, hurt_cd-dt)
	skill_cd = maxf(0, skill_cd-dt)
	heal_cd = maxf(0, heal_cd-dt)
	state_time = maxf(0, state_time-dt)
	strike_visual = maxf(0, strike_visual-dt)
	death_visual_time = maxf(0, death_visual_time-dt)
	if hp <= 0:
		velocity = Vector2.ZERO
		queue_redraw()
		return
	if state_time <= 0 and state not in ["idle", "walk", "wounded", "tired"]:
		state = "idle"
	if role == "player":
		_update_player(dt)
	elif role == "enemy":
		_update_enemy(dt)
	if velocity.length() > 5:
		walk_phase += dt*10.0
	move_and_slide()
	position = position.clamp(Vector2(36,90),Vector2(1244,914))
	queue_redraw()

func _update_player(dt:float) -> void:
	var direction = motion_input()
	var want_guard = Input.is_physical_key_pressed(KEY_F) or Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT)
	guarding = want_guard and stamina > 4 and state_time <= 0
	guard_time = guard_time+dt if guarding else 0.0
	if not guarding and state != "dash":
		stamina = minf(max_stamina, stamina+dt*(24 if state != "attack" else 8))
	if state == "dash":
		velocity = dash_dir*370
		if int(clock*45) % 2 == 0:
			game.fx(position-Vector2(0,13),Color(0.5,0.8,0.9,0.4),"spark",10)
	else:
		var slow = 0.42 if guarding else (0.6 if state in ["attack","heal","hurt"] else 1.0)
		if hp/max_hp < 0.25:
			slow *= 0.78
		velocity = velocity.move_toward(direction*speed*slow, dt*1100)
		if direction != Vector2.ZERO:
			face(direction)
		if state_time <= 0:
			state = "walk" if direction != Vector2.ZERO else ("wounded" if hp/max_hp<0.25 else ("tired" if stamina<22 else "idle"))
	if (Input.is_physical_key_pressed(KEY_J) or Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)) and not game.mouse_over_ui():
		attack()

func attack() -> bool:
	if hp<=0 or attack_cd>0 or state in ["dash","heal","hurt"] or game.paused:
		return false
	var weapon = Content.WEAPONS[game.weapon]
	if stamina < weapon.cost:
		return false
	stamina -= weapon.cost
	guarding = false
	attack_cd = weapon.delay
	set_state("attack",weapon.delay*0.75)
	var damage = weapon.damage + game.weapon_levels[game.weapon]*5 + (game.level-1)*2
	if weapon.kind == "sword":
		game.melee(self,damage,weapon.reach,0.0)
		game.fx(position+Vector2(0,-12),Color("f4d3a0"),"slash",weapon.reach,facing.angle())
	else:
		game.projectile(self,facing,damage,weapon.kind)
	game.sound(260 if weapon.kind == "sword" else 500,0.07)
	return true

func dodge() -> bool:
	if game.paused or hp<=0 or stamina<24 or state in ["dash","hurt","heal"]:
		return false
	stamina -= 24
	dash_dir = motion_input()
	if dash_dir == Vector2.ZERO:
		dash_dir = facing
	set_state("dash",0.22)
	hurt_cd = 0.3
	game.sound(160,0.1)
	return true

func skill() -> bool:
	if game.paused or hp<=0 or skill_cd>0 or stamina<32 or state in ["dash","hurt"]:
		return false
	stamina -= 32
	skill_cd = 5.0
	set_state("attack",0.48)
	game.melee(self,42+game.level*5,110,-1.1)
	game.fx(position+Vector2(0,-8),Color("eab66e"),"nova",110)
	game.sound(600,0.2)
	return true

func heal() -> bool:
	if game.paused or hp<=0 or hp>=max_hp or game.bag.potion<=0 or heal_cd>0 or state == "dash":
		return false
	game.bag.potion -= 1
	hp = minf(max_hp,hp+65)
	heal_cd = 4
	set_state("heal",0.6)
	game.fx(position-Vector2(0,10),Color("90dba7"),"heal",40)
	game.sound(760,0.18)
	return true

func _update_enemy(dt:float) -> void:
	var p = game.player
	if p.hp <= 0:
		velocity = Vector2.ZERO
		return
	var delta_pos = p.position-position
	var distance = delta_pos.length()
	if state == "hurt":
		velocity = velocity.move_toward(Vector2.ZERO,dt*400)
		return
	if windup>0:
		windup -= dt
		velocity = Vector2.ZERO
		if windup<=0:
			strike_visual = 0.18 if boss else 0.14
			if position.distance_to(p.position)<(100 if boss else 47):
				p.take_hit(power,position)
			game.fx(position+facing*24,Color("e76f5c"),"slash",80 if boss else 32,facing.angle())
			if boss:
				game.fx(position,Color("b175d1"),"nova",100)
			attack_cd = 1.6 if boss else 1.15
		return
	if distance< (410 if boss else 265) and game.has_line_of_sight(position,p.position):
		face(delta_pos)
		if distance<(83 if boss else 35) and attack_cd<=0:
			windup = 0.85 if boss else 0.55
			strike_target = p.position
			velocity = Vector2.ZERO
		elif distance>28:
			velocity = delta_pos.normalized()*speed
		else:
			velocity = Vector2.ZERO
	else:
		velocity = Vector2.ZERO
	state = "walk" if velocity.length()>0 else "idle"

func take_hit(damage:float, source:Vector2) -> bool:
	if hp<=0 or hurt_cd>0 or state == "dash":
		return false
	if role == "player" and guarding and facing.dot((source-position).normalized())>0.15:
		if guard_time<0.22:
			game.float_text(position,"ĐỠ CHUẨN!",Color("b6e3ee"))
			game.fx(position,Color("b6e3ee"),"nova",35)
			stamina = minf(max_stamina,stamina+12)
			return false
		stamina = maxf(0,stamina-18)
		damage *= 0.22
		damage = maxf(1,damage-armor)
	else:
		damage = maxf(1,damage-armor)
	hp = maxf(0,hp-damage)
	hurt_cd = 0.45 if role == "player" else 0.15
	velocity = (position-source).normalized()*100
	set_state("hurt",0.18)
	game.float_text(position,str(int(damage)),Color("ee9277") if role == "player" else Color("f2dcaa"))
	game.fx(position-Vector2(0,14),Color("dba071"),"spark",23)
	if hp<=0:
		death_visual_time = 0.48 if role == "enemy" else 0.0
		set_state("dead",99)
		collision_layer = 0
		if role == "enemy":
			game.enemy_died(self)
		else:
			game.player_died()
	return true

func _draw() -> void:
	var shadow = Vector2(18,7) if not boss else Vector2(43,13)
	draw_set_transform(Vector2.ZERO,0,Vector2(1,0.4))
	draw_circle(Vector2(0,-3),shadow.x/2,Color(0.02,0.02,0.025,0.5))
	draw_set_transform(Vector2.ZERO)
	if role == "enemy":
		_draw_monster()
		return
	var bob = sin(walk_phase)*1.5 if state=="walk" else sin(clock*2)*0.35
	var angle = 0.0
	if state == "dead":
		angle = PI/2
	if state == "hurt":
		angle = -0.18
	if state in ["wounded","tired"]:
		bob += 2+sin(clock*5)*0.8
		angle = 0.12 if state=="wounded" else 0.04
	if state == "dash":
		angle = facing.x*0.3
	if role == "player":
		var row = face(Vector2.ZERO)
		var frame = int(walk_phase/1.3)%4 if state=="walk" else 0
		var color = Color(2,0.65,0.65) if state=="hurt" else Color.WHITE
		draw_set_transform(Vector2(0,-13+bob),angle,Vector2(1.2,1.2))
		draw_texture_rect_region(KAEL,Rect2(-16,-19,32,32),Rect2(frame*32,row*32,32,32),color)
		# Áo khoác dùng cùng hướng với thân, tránh chồng lớp đồ cũ lệch kích thước.
		var cloth = Content.OUTFITS[game.outfit].color
		if game.outfit>0:
			if row == 1:
				draw_colored_polygon(PackedVector2Array([Vector2(-5,-2),Vector2(5,-2),Vector2(7,8),Vector2(-7,8)]),cloth)
			else:
				draw_rect(Rect2(-6,0,3,8),cloth)
				draw_rect(Rect2(3,0,3,8),cloth.darkened(0.2))
		draw_set_transform(Vector2.ZERO)
		_draw_weapon()
	else:
		draw_set_transform(Vector2(0,bob))
		draw_texture_rect_region(KAEL,Rect2(-18,-38,36,36),Rect2(0,0,32,32),tint.lightened(0.5))
		draw_colored_polygon(PackedVector2Array([Vector2(-5,-16),Vector2(5,-16),Vector2(7,-5),Vector2(-7,-5)]),tint)
		draw_line(Vector2(-4,-16),Vector2(-4,-5),tint.lightened(0.2),1)
		if title in ["Mara","Thầy thuốc"]:
			draw_arc(Vector2(0,-26),8,PI,TAU,10,tint,4)
		draw_set_transform(Vector2.ZERO)
	if guarding:
		draw_arc(Vector2(0,-14),24,facing.angle()-0.9,facing.angle()+0.9,14,Color("8ec1ce"),2)
	if state == "heal" or state == "revive":
		draw_arc(Vector2(0,-14),23+sin(clock*10)*4,0,TAU,24,Color("9eddb7"),1)

func _draw_weapon() -> void:
	if hp<=0:
		return
	var a = facing.angle()
	if state == "attack":
		a += sin(state_time*10)*1.2-0.5
	var origin = Vector2(0,-12)+facing*7
	var tip = origin+Vector2.from_angle(a)*(30 if game.weapon == 1 else 24)
	var kind_w = Content.WEAPONS[game.weapon].kind
	if kind_w == "sword":
		draw_line(origin,tip,Color("d9d7bd"),3)
		draw_line(origin,origin+Vector2.from_angle(a)*7,Color("9d7850"),4)
	elif kind_w == "bow":
		draw_arc(origin,13,a-1.3,a+1.3,9,Color("b99160"),2)
		draw_line(origin+Vector2.from_angle(a-1.3)*13,origin+Vector2.from_angle(a+1.3)*13,Color("d7cbae"))
	else:
		draw_line(origin,tip,Color("a59079"),3)
		draw_circle(tip,4,Color("b0a1ee"))

func _draw_monster() -> void:
	var texture := MonsterVisuals.texture_for(kind)
	if texture == null:
		_draw_monster_fallback()
		return
	var size := MonsterVisuals.display_size(boss)
	var row := MonsterVisuals.direction_row(facing)
	var column := monster_frame_index()
	var source := MonsterVisuals.source_rect(texture,row,column)
	# All frames use one fixed square and a shared foot origin. Transparent atlas
	# padding therefore cannot make attacks or hurt frames jump or resize.
	var destination := Rect2(-size*0.5,-size,size,size)
	var color := Color(1.35,0.72,0.72) if monster_animation_state() == "hurt" else Color.WHITE
	if monster_animation_state() == "idle":
		var breathe := 1.0 + sin(clock*2.4)*0.012
		destination = Rect2(-size*breathe*0.5,-size*breathe,size*breathe,size*breathe)
	draw_texture_rect_region(texture,destination,source,color)
	if hp>0:
		var bar_width := 58.0 if boss else 36.0
		var bar_y := -size-7.0
		if hp<max_hp or boss:
			draw_rect(Rect2(-bar_width*0.5,bar_y,bar_width,3),Color("25202b"))
			draw_rect(Rect2(-bar_width*0.5,bar_y,bar_width*hp/max_hp,3),Color("c77c7b"))
		if windup>0:
			draw_arc(Vector2.ZERO,100 if boss else 38,0,TAU,32,Color(0.9,0.28,0.2,0.7),2)
			draw_string(ThemeDB.fallback_font,Vector2(-3,bar_y-7),"!",HORIZONTAL_ALIGNMENT_LEFT,-1,17,Color("f4bb81"))

func monster_animation_state() -> String:
	return MonsterVisuals.animation_state(self)

func monster_frame_index() -> int:
	return MonsterVisuals.frame_index(self)

func _draw_monster_fallback() -> void:
	var c = Color("847d70")
	if kind in ["Cướp áo đen","Người giữ ấn"]:
		c = Color("514358")
	if kind in ["Bọ tinh thạch","Thú hắc thạch","Bóng sương"]:
		c = Color("736687")
	if hurt_cd>0:
		c = Color("e6b4a6")
	var scale_v = 2.0 if boss else 1.0
	var bob = sin(walk_phase)*2
	draw_set_transform(Vector2(0,-12),PI/2 if hp<=0 else 0,Vector2.ONE*scale_v)
	if kind == "Dơi hang":
		draw_colored_polygon(PackedVector2Array([Vector2(-3,-5),Vector2(-21,-12-sin(clock*15)*6),Vector2(-15,2),Vector2(-3,4)]),c)
		draw_colored_polygon(PackedVector2Array([Vector2(3,-5),Vector2(21,-12-sin(clock*15)*6),Vector2(15,2),Vector2(3,4)]),c)
		draw_circle(Vector2.ZERO,7,c.darkened(0.2))
	elif kind in ["Cướp áo đen","Người giữ ấn","Bóng sương"]:
		draw_colored_polygon(PackedVector2Array([Vector2(-5,-17),Vector2(5,-17),Vector2(12,10),Vector2(-12,10)]),c)
		draw_circle(Vector2(0,-14),7,c.lightened(0.12))
		draw_rect(Rect2(-4,-15,8,4),Color("28232d"))
		draw_line(Vector2(10,-5),Vector2(16,-22),Color("a5a1b8"),2)
	else:
		draw_colored_polygon(PackedVector2Array([Vector2(-14,5),Vector2(-12,-8+bob),Vector2(-5,-15+bob),Vector2(5,-12),Vector2(14,-7),Vector2(12,7)]),c)
		draw_colored_polygon(PackedVector2Array([Vector2(-10,-8),Vector2(-9,-20),Vector2(-2,-12)]),c.lightened(0.15))
		draw_colored_polygon(PackedVector2Array([Vector2(3,-10),Vector2(10,-18),Vector2(11,-5)]),c.lightened(0.15))
		for i in [-1,1]:
			draw_rect(Rect2(i*8-2,5+sin(walk_phase+i)*2,5,7),c.darkened(0.3))
	draw_rect(Rect2(-5,-7,3,2),Color("efab91"))
	draw_rect(Rect2(3,-7,3,2),Color("efab91"))
	draw_set_transform(Vector2.ZERO)
	if hp>0:
		if hp<max_hp or boss:
			draw_rect(Rect2(-18,-44*scale_v,36,3),Color("25202b"))
			draw_rect(Rect2(-18,-44*scale_v,36*hp/max_hp,3),Color("c77c7b"))
		if windup>0:
			draw_arc(Vector2.ZERO,100 if boss else 38,0,TAU,32,Color(0.9,0.28,0.2,0.7),2)
			draw_string(ThemeDB.fallback_font,Vector2(-3,-55*scale_v),"!",HORIZONTAL_ALIGNMENT_LEFT,-1,17,Color("f4bb81"))
