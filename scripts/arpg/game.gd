extends Node2D
## Luật chơi, tiến độ và bản lưu; các ảnh gốc và scene demo cũ được giữ nguyên.
const Content = preload("res://scripts/arpg/content.gd")
const Actor = preload("res://scripts/arpg/actor.gd")
const World = preload("res://scripts/arpg/world.gd")
const HUD = preload("res://scripts/arpg/hud.gd")
var player:CharacterBody2D
var world:Node2D
var hud:CanvasLayer
var camera:Camera2D
var effects_layer:Node2D
var enemies:Array = []
var drops:Array[Dictionary] = []
var effects:Array[Dictionary] = []
var shots:Array[Dictionary] = []
var texts:Array[Dictionary] = []
var map_id = 0
var quest = 0
var day = 1
var level = 1
var xp = 0
var weapon = 0
var outfit = 0
var weapon_levels:Array = [0,0,0,0]
var owned_weapons:Array = [0]
var owned_outfits:Array = [0]
var visited:Array = [0]
var flags:Dictionary = {}
var bag:Dictionary = {"gold":15,"ore":0,"hide":0,"herb":0,"potion":3}
var map_states:Dictionary = {}
var paused = false
var elapsed = 0.0
var save_timer = 0.0
var save_path = "user://aster_arpg_save_v1.json"
var testing = false
var audio_cooldown = 0.0
var last_save_error = false

func _ready() -> void:
	# HUD chi tiết hơn; camera giữ nguyên phạm vi thế giới như bản trước.
	get_window().content_scale_size = Vector2i(960,540)
	get_window().content_scale_mode = Window.CONTENT_SCALE_MODE_CANVAS_ITEMS
	get_window().content_scale_aspect = Window.CONTENT_SCALE_ASPECT_KEEP
	get_window().content_scale_stretch = Window.CONTENT_SCALE_STRETCH_FRACTIONAL
	player = Actor.new()
	player.game = self
	player.role = "player"
	camera = Camera2D.new()
	camera.zoom = Vector2(1.5,1.5)
	camera.position = Vector2(0,-15)
	camera.position_smoothing_enabled = true
	camera.position_smoothing_speed = 8
	camera.limit_left = 0
	camera.limit_top = 0
	camera.limit_right = 1280
	camera.limit_bottom = 960
	player.add_child(camera)
	load_map(0,false)
	hud = HUD.new()
	hud.game = self
	add_child(hud)
	for arg in OS.get_cmdline_user_args():
		if arg == "--arpg-test":
			testing = true
			save_path = "user://aster_arpg_TEST.json"
			call_deferred("_run_tests")
			return
		if arg.begins_with("--arpg-capture="):
			testing = true
			call_deferred("_capture",arg.trim_prefix("--arpg-capture="))
			return
	hud.title_screen()

func new_game() -> void:
	hud.close_menu()
	quest=0
	day=1
	level=1
	xp=0
	weapon=0
	outfit=0
	weapon_levels=[0,0,0,0]
	owned_weapons=[0]
	owned_outfits=[0]
	visited=[0]
	flags={}
	bag={"gold":15,"ore":0,"hide":0,"herb":0,"potion":3}
	map_states={}
	load_map(0,false)
	refresh_stats()
	player.hp=65
	player.stamina=100
	player.hurt_cd=0
	player.collision_layer=2
	player.attack_cd=0
	player.skill_cd=0
	player.heal_cd=0
	player.guarding=false
	player.set_state("wounded",0)
	hud.dialogue("Chương 0 · Hận thù và nước mắt",[
		"Đêm ấy, những kẻ áo choàng đen tràn vào Aster. Chúng không lấy của cải. Chúng đang tìm kiếm điều gì đó.\n\nMẹ chỉ kịp nói: ‘Dẫn em con chạy đi.’",
		"Một tiếng nổ. Triền núi sụp xuống. Kael rơi vào con suối cạn.\n\nKhi cậu tỉnh dậy, bầu trời đã thôi đỏ. Nhưng Aster chỉ còn tro tàn.",
		"Mẹ và em ở đâu?\n\nHãy về căn nhà phía tây. Dùng WASD hoặc mũi tên để di chuyển, E để tương tác. Đứng cạnh lửa trại để hồi phục."
	],func(): save_game())

func load_map(id:int,remember:bool=true) -> void:
	var previous = map_id
	if is_instance_valid(world):
		if remember: remember_map()
		if player.get_parent(): player.get_parent().remove_child(player)
		remove_child(world)
		world.queue_free()
	if is_instance_valid(effects_layer):
		remove_child(effects_layer)
		effects_layer.queue_free()
	map_id = clampi(id,0,Content.MAPS.size()-1)
	enemies.clear()
	drops.clear()
	effects.clear()
	shots.clear()
	texts.clear()
	world = World.new()
	world.game = self
	add_child(world)
	world.build(map_id)
	world.objects.add_child(player)
	player.position = Content.MAPS[map_id].spawn
	if remember and previous!=id:
		for gate in world.gates:
			if gate[0]==previous:
				player.position=gate[1]+(Vector2(640,520)-gate[1]).normalized()*56
	player.velocity = Vector2.ZERO
	camera.reset_smoothing()
	effects_layer = Node2D.new()
	effects_layer.z_index = 20
	effects_layer.draw.connect(_draw_effects)
	add_child(effects_layer)
	if map_states.has(str(map_id)):
		var saved = map_states[str(map_id)]
		for e in saved.enemies:
			spawn_enemy(e.kind,Vector2(e.x,e.y),e.get("hp",-1))
		for d in saved.drops:
			drop_item(d.type,Vector2(d.x,d.y),int(d.amount),false)
	else:
		populate_map()
	if not visited.has(map_id): visited.append(map_id)
	if is_instance_valid(hud):
		hud.notify(Content.MAPS[map_id].name)
		if remember: save_game()

func populate_map() -> void:
	var danger:int = Content.MAPS[map_id].level
	if danger>0:
		var kinds = ["Sói tro","Sói tro","Dơi hang"]
		if map_id in [3,4]: kinds=["Dơi hang","Bọ tinh thạch","Sói tro"]
		if map_id==5: kinds=["Cướp áo đen","Cướp áo đen","Sói tro"]
		if map_id>=7: kinds=["Bóng sương","Bọ tinh thạch","Cướp áo đen"]
		var points = [Vector2(420,340),Vector2(740,360),Vector2(930,600),Vector2(400,650),Vector2(880,380),Vector2(620,450)]
		for i in range(points.size()):
			var p:Vector2=points[i]
			while world.blocked(p,22): p+=Vector2(24,8)
			spawn_enemy(kinds[i%kinds.size()],p)
		if map_id==4 and not flags.get("mine_boss",false):
			spawn_enemy("Thú hắc thạch",Vector2(890,350))
		if map_id==9 and not flags.get("final_boss",false):
			spawn_enemy("Người giữ ấn",Vector2(860,380))
	if map_id in [1,7]:
		for p in [Vector2(580,690),Vector2(710,580),Vector2(600,440),Vector2(760,740),Vector2(540,290)]:
			drop_item("herb",p,1,false)
	if map_id in [3,4,8]:
		for p in [Vector2(360,720),Vector2(640,590),Vector2(1020,440)]:
			drop_item("ore",p,1,false)

func spawn_enemy(kind:String,p:Vector2,saved_hp:float=-1) -> Node:
	var e = Actor.new()
	var s = Content.enemy_stats(kind,Content.MAPS[map_id].level)
	e.game=self
	e.role="enemy"
	e.kind=kind
	e.title=kind
	e.max_hp=s.hp
	e.hp=s.hp if saved_hp<0 else saved_hp
	e.power=s.damage
	e.speed=s.speed
	e.boss=s.boss
	e.xp_value=s.xp
	e.position=p
	e.home=p
	world.objects.add_child(e)
	enemies.append(e)
	return e

func refresh_stats() -> void:
	player.max_hp=100+(level-1)*16
	player.max_stamina=100+(level-1)*4
	player.armor=Content.OUTFITS[outfit].armor

func _process(dt:float) -> void:
	if paused: return
	elapsed+=dt
	audio_cooldown=maxf(0,audio_cooldown-dt)
	if player.hp>0:
		update_drops(dt)
		update_shots(dt)
	for list in [effects,texts]:
		for i in range(list.size()-1,-1,-1):
			list[i].life-=dt
			if list[i].life<=0: list.remove_at(i)
	effects_layer.queue_redraw()
	save_timer+=dt
	if save_timer>25 and player.hp>0:
		save_timer=0
		save_game()

func _unhandled_input(event:InputEvent) -> void:
	if not (event is InputEventKey and event.pressed and not event.echo): return
	var key=event.physical_keycode
	if key==0: key=event.keycode
	if hud.menu_kind=="dialogue":
		if key in [KEY_E,KEY_ENTER]: hud.advance_dialogue()
		return
	if hud.menu_kind in ["title","death","confirm"]: return
	if key==KEY_ESCAPE:
		if hud.menu_kind!="": hud.close_menu()
		else: hud.pause_screen()
		return
	if key in [KEY_I,KEY_TAB]:
		if hud.menu_kind=="inventory": hud.close_menu(); save_game()
		elif hud.menu_kind=="": hud.inventory()
		return
	if key==KEY_M:
		if hud.menu_kind=="atlas": hud.close_menu()
		elif hud.menu_kind=="": hud.atlas()
		return
	if paused or player.hp<=0: return
	match key:
		KEY_E: interact()
		KEY_SPACE: player.dodge()
		KEY_Q: player.skill()
		KEY_R: player.heal()

func mouse_over_ui() -> bool:
	return paused or (is_instance_valid(hud) and hud.is_pointer_over_hud())

func near_hint() -> String:
	var nearest = nearest_point()
	return "[E]  "+nearest.label if not nearest.is_empty() else ""

func nearest_point() -> Dictionary:
	var nearest:Dictionary={}
	var dist=48.0
	for p in world.interactables:
		var d=player.position.distance_to(p.pos)
		if d<dist:
			nearest=p
			dist=d
	for gate in world.gates:
		if player.position.distance_to(gate[1])<dist:
			nearest={"id":"gate","label":gate[2],"target":gate[0],"pos":gate[1]}
			dist=player.position.distance_to(gate[1])
	return nearest

func interact() -> void:
	var p=nearest_point()
	if p.is_empty(): return
	if p.id=="gate":
		if p.target>=6 and quest<6:
			hud.notify("Chưa thể lên đường. Hãy hoàn thành lời hẹn với Aster.")
			return
		if map_id==4 and p.target==0 and not flags.get("shortcut",false):
			hud.notify("Hãy mở tời kéo tại tầng trên trước.")
			return
		load_map(p.target)
		return
	talk(p.id)

func talk(id:String) -> void:
	match id:
		"relics":
			if flags.get("relics",false):
				hud.dialogue("Nhà Kael",["Những mảnh gỗ đã nguội. Chiếc khăn và con ngựa gỗ nằm trong hành trang. Không có dấu vết rõ ràng của mẹ và em."])
			else:
				hud.dialogue("Những gì còn lại",["Kael bới từng thanh gỗ. Không có mẹ. Không có em. Không có thi thể.","Chỉ còn chiếc khăn của mẹ bị cháy một góc và món đồ chơi bằng gỗ của em.\n\nHọ đã biến mất. Nhưng mất tích không có nghĩa là đã chết."],func():
					flags.relics=true
					advance_quest(2 if flags.get("edren",false) else 1)
					hud.notify("Nhận kỷ vật: khăn của mẹ · ngựa gỗ"))
		"edren":
			hud.dialogue("Edren",["Kael... cháu có tìm thấy mẹ và em chưa?\n\nKael lắc đầu.","Vậy ít nhất cháu vẫn còn thứ để đi tìm.\n\nTa thì tìm thấy tất cả rồi.","Ta cứ nghĩ mãi. Nếu tối đó ta về sớm hơn một chút...\n\nTa không hiểu tại sao mình lại là người còn sống."],Callable(),[
				["Cháu sẽ ngồi đây với chú.",func(): edren_end("Kael ngồi xuống bên cạnh Edren. Cả hai im lặng rất lâu.")],
				["Cháu... không biết phải nói gì.",func(): edren_end("Edren nhìn xuống đôi tay. Kael không tìm được lời nào.")]
			])
		"chair":
			hud.dialogue("Chiếc ghế trống",["Edren không còn ở đây. Người trong làng nói ông đã tự kết liễu đời mình trong đêm.\n\nKhông có cảnh tượng nào. Chỉ có chiếc ghế trống trước căn nhà cháy.","Không phải người sống sót nào cũng thực sự thoát khỏi đêm hôm ấy."],func():
				flags.edren=true
				if quest==1: advance_quest(2))
		"grave":
			if day>1:
				hud.dialogue("Bốn cái tên",["Edren, vợ ông và hai người con.\n\n‘Giá như cháu biết phải nói gì với chú.’"])
			else: hud.dialogue("Đồi tưởng niệm",["Đất vẫn còn mới. Một khoảng trống nữa đang được chuẩn bị cho những người chưa được tìm thấy."])
		"healer":
			if quest==2 and bag.herb>=3:
				hud.dialogue("Thầy thuốc",["Đủ dược thảo rồi. Những người bị thương sẽ qua được đêm nay.\n\nHầm mỏ phía đông vẫn đóng cửa. Đi cùng người thợ săn già; đừng xuống đó một mình mà không chuẩn bị."],func():
					bag.herb-=3
					bag.potion+=3
					bag.gold+=30
					player.hp=player.max_hp
					advance_quest(3)
					hud.notify("+3 bình hồi phục · +30 vàng"))
			else:
				player.hp=player.max_hp
				hud.dialogue("Thầy thuốc",["Ta đã băng lại vết thương cho cháu.\n\nTa cần 3 dược thảo từ rừng phía bắc lối làng. Đi tới bụi cây sáng màu để nhặt. Đừng để mình kiệt sức."])
		"smith","trader": hud.smith()
		"elder":
			if quest==5:
				hud.dialogue("Trước lúc lên đường",["Elara... Vậy mẹ cháu có thể vẫn còn sống.\n\nĐây là thanh kiếm của cha cháu. Người thợ rèn đã giữ nó sau đêm ấy.","Đừng để lòng căm thù quyết định cháu sẽ trở thành người như thế nào.","Kael nhìn lại Aster. Khói bếp đã trở lại, nhưng trên đồi vẫn là những hàng bia mộ mới.\n\nCHƯƠNG I · DẤU VẾT PHƯƠNG BẮC"],func():
					if not owned_weapons.has(1): owned_weapons.append(1)
					weapon=1
					bag.gold+=60
					day=maxi(day,3)
					advance_quest(6)
					load_map(0))
			else:
				hud.dialogue("Trưởng làng",["Cháu muốn tìm gia đình mình thì trước tiên phải sống đủ lâu để tìm được họ.",Content.QUESTS[quest][1]])
		"mara":
			hud.dialogue("Mara",["Cháu có thấy Leni không? Con bé mới mười tuổi... Ta đã hỏi mọi người. Ta không tìm thấy con bé.","Nếu con bé đang ở đâu đó ngoài kia và gọi mẹ... thì ta không thể ngồi đây chờ được."])
		"mara_far":
			flags.mara_reunion=true
			hud.dialogue("Mara · Gặp lại nơi đất lạ",["Kael? Cháu cũng đến tận đây rồi sao?\n\nTa nghe một đoàn tù nhân đã đi qua cổng sương. Có một đứa trẻ giống Leni.","Ta vẫn chưa tìm thấy con. Nhưng ta sẽ tiếp tục.\n\n[Phần mở rộng gameplay: manh mối này chưa phải kết luận về số phận Leni.]"],save_game)
		"hunter":
			hud.dialogue("Thợ săn già",["Chờ quái giơ móng, rồi né. Đừng vung kiếm đến kiệt sức. Đỡ ngay trước đòn đánh có thể khiến nó trượt đi.","Ở dưới cùng có thứ đã biến đổi. Lớp đá trên người nó phát sáng tím. Khi vòng đỏ nở rộng, tránh xa.\n\nTa sẽ giữ cửa hầm này cho cháu."],func():
				if not flags.get("hunter_supplies",false):
					flags.hunter_supplies=true
					bag.potion+=2
					hud.notify("Thợ săn trao 2 bình hồi phục"))
		"shortcut":
			flags.shortcut=true
			hud.dialogue("Tời kéo",["Dây cáp đã được nối lại. Từ tầng sâu, giờ có thể đi thẳng về Aster bằng thang phía nam."],save_game)
		"symbol":
			if flags.get("mine_boss",false):
				hud.dialogue("Dấu vết dưới đá",["Dấu giày. Những dụng cụ không thuộc về thợ mỏ. Và một biểu tượng lạ.\n\nCó người đã vào đây trước đêm tấn công."],func(): advance_quest(4))
			else: hud.notify("Sinh vật khổng lồ vẫn chặn khu vực này.")
		"merchant":
			var bandits=0
			for e in enemies:
				if e.hp>0 and e.kind=="Cướp áo đen": bandits+=1
			if bandits>0:
				hud.dialogue("Thương nhân",["Bọn cướp vẫn quanh đây! Hãy giúp tôi dẹp chúng trước.\n\nCòn %d tên áo đen trên đèo."%bandits])
			elif flags.get("mine_boss",false) and quest==4:
				hud.dialogue("Manh mối đầu tiên",["Biểu tượng này... Tôi từng thấy nó trên những người áo đen đi qua một thị trấn phía bắc. Họ đang áp giải một nhóm người.","Có một phụ nữ chống cự rất dữ dội. Bên cạnh là một đứa trẻ. Tôi không nhớ rõ mặt họ.","Nhưng tôi nhớ cái tên mà một kẻ áo đen đã gọi bà ấy.\n\nElara.","Lần đầu tiên từ đêm Aster cháy, Kael có một lý do để tin rằng mẹ mình còn sống.\n\nHãy trở về báo tin cho trưởng làng."],func(): advance_quest(5))
			else:
				hud.dialogue("Thương nhân",["Cảm ơn cậu. Có những đoàn người áo đen qua phương bắc. Nếu tìm được dấu hiệu gì về chúng, hãy cho tôi xem."])
		"fire":
			player.hp=player.max_hp
			player.stamina=player.max_stamina
			player.set_state("heal",0.8)
			fx(player.position,Color("a5d1a3"),"heal",45)
			save_game()
			hud.notify("Đã hồi phục và lưu hành trình")
		"inn":
			hud.dialogue("Chủ quán trọ",["Tầng dưới dành cho những người không còn nhà. Cháu có thể nghỉ ở đây.\n\nNghỉ sẽ sang ngày mới, hồi đầy máu và thể lực. Quái thường và vật liệu ngoài làng sẽ xuất hiện lại."],Callable(),[
				["Nghỉ đến sáng (miễn phí)",rest],
				["Tôi sẽ quay lại sau.",func(): hud.close_menu()]
			])
		"seal":
			if flags.get("final_boss",false):
				hud.dialogue("Một cánh cửa khác",["Ấn hắc nhật đã tắt. Xa hơn cõi sương, con đường vẫn chưa kết thúc.\n\nBạn đã hoàn thành phần nội dung chiến đấu mở rộng của bản chơi này. Số phận Elara và em trai vẫn chưa được xác nhận."],func(): advance_quest(7))
			else: hud.notify("Người giữ ấn vẫn còn ở đây.")
		"rebuild": hud.dialogue("Aster đang hồi phục",["Vật liệu đã được xếp thành từng bó. Những mái nhà mới sẽ mọc lên, dù không phải khoảng trống nào cũng được lấp đầy."])

func edren_end(text:String) -> void:
	hud.dialogue("Edren",[text,"‘Cháu còn người để đi tìm.’"],func():
		flags.edren=true
		if quest==1: advance_quest(2))

func advance_quest(next:int) -> void:
	if next>quest:
		quest=mini(next,7)
		gain_xp(35)
		hud.notify("Nhiệm vụ mới: "+Content.QUESTS[quest][0])
	save_game()

func rest() -> void:
	day+=1
	# Boss cốt truyện không hồi sinh; quái thường có thể săn lại để kiếm vật liệu.
	map_states.clear()
	player.hp=player.max_hp
	player.stamina=player.max_stamina
	hud.close_menu()
	load_map(0,false)
	player.position=Vector2(475,755)
	hud.dialogue("Ngày %d · Những người ở lại"%day,["Một ngày mới đến với Aster."+("\n\nChiếc ghế trước nhà Edren giờ đã trống." if day==2 else "\n\nTiếng búa lại vang lên giữa những nền nhà cũ.")],save_game)

func craft(recipe:String,index:int=0) -> bool:
	match recipe:
		"upgrade":
			var cost=20+weapon_levels[weapon]*20
			if bag.gold<cost or bag.ore<2 or weapon_levels[weapon]>=5: return false
			bag.gold-=cost
			bag.ore-=2
			weapon_levels[weapon]+=1
		"bow","staff":
			var w=2 if recipe=="bow" else 3
			var cost=25 if w==2 else 55
			var ore=2 if w==2 else 5
			if owned_weapons.has(w) or bag.gold<cost or bag.ore<ore: return false
			bag.gold-=cost
			bag.ore-=ore
			owned_weapons.append(w)
		"outfit":
			if index<1 or index>3 or owned_outfits.has(index) or bag.gold<index*20 or bag.hide<index: return false
			bag.gold-=index*20
			bag.hide-=index
			owned_outfits.append(index)
		"potion":
			if bag.herb<2: return false
			bag.herb-=2
			bag.potion+=1
		"buy_potion":
			if bag.gold<12: return false
			bag.gold-=12
			bag.potion+=1
		_: return false
	sound(880,0.1)
	save_game()
	return true

func melee(source:Node,damage:float,reach:float,cone:float) -> void:
	for e in enemies:
		if not is_instance_valid(e) or e.hp<=0: continue
		var delta=e.position-source.position
		if delta.length()<=reach+(15 if e.boss else 7) and (delta.length()<12 or source.facing.dot(delta.normalized())>cone) and has_line_of_sight(source.position,e.position):
			e.take_hit(damage,source.position)

func has_line_of_sight(a:Vector2,b:Vector2) -> bool:
	var steps=int(a.distance_to(b)/8)+1
	for i in range(1,steps):
		if world.blocked(a.lerp(b,float(i)/steps),0): return false
	return true

func projectile(source:Node,direction:Vector2,damage:float,kind:String) -> void:
	shots.append({"pos":source.position-Vector2(0,12),"dir":direction,"damage":damage,"kind":kind,"life":0.95})

func update_shots(dt:float) -> void:
	for i in range(shots.size()-1,-1,-1):
		var shot=shots[i]
		shot.life-=dt
		var hit=false
		# Chia bước nhỏ để tên bay nhanh không xuyên qua mục tiêu hẹp.
		var steps=maxi(1,int(360*dt/5)+1)
		for step in range(steps):
			shot.pos+=shot.dir*360*dt/steps
			if world.blocked(shot.pos+Vector2(0,10),1):
				hit=true
				break
			for e in enemies:
				if e.hp>0 and shot.pos.distance_to(e.position-Vector2(0,12))<(22 if e.boss else 13):
					e.take_hit(shot.damage,shot.pos-shot.dir*20)
					hit=true
					break
			if hit: break
		if hit or shot.life<=0: shots.remove_at(i)

func enemy_died(e:Node) -> void:
	gain_xp(e.xp_value)
	drop_item("gold",e.position+Vector2(-9,3),12 if e.boss else 5+Content.MAPS[map_id].level)
	drop_item("ore" if e.kind in ["Bọ tinh thạch","Thú hắc thạch","Người giữ ấn"] else "hide",e.position+Vector2(10,5),3 if e.boss else 1)
	if randi()%4==0 or e.boss: drop_item("potion",e.position+Vector2(0,17),1)
	if e.kind=="Thú hắc thạch":
		flags.mine_boss=true
		if quest==3: advance_quest(4)
		hud.notify("Sinh vật đã gục. Một biểu tượng lạ nằm trong đống đá.")
	if e.kind=="Người giữ ấn":
		flags.final_boss=true
		advance_quest(7)
		bag.gold+=100
	if e.boss: save_game()

func gain_xp(amount:int) -> void:
	xp+=amount
	while xp>=level*65:
		xp-=level*65
		level+=1
		refresh_stats()
		player.hp=player.max_hp
		player.stamina=player.max_stamina
		fx(player.position,Color("e1c38b"),"nova",65)
		if is_instance_valid(hud): hud.notify("LÊN CẤP %d · Máu và thể lực đã hồi đầy"%level)

func drop_item(type:String,p:Vector2,amount:int,bounce:bool=true) -> void:
	drops.append({"type":type,"pos":p,"amount":amount,"age":0.0 if bounce else 1.0})

func update_drops(dt:float) -> void:
	for i in range(drops.size()-1,-1,-1):
		var d=drops[i]
		d.age+=dt
		if d.age>0.55 and d.pos.distance_to(player.position)<22:
			bag[d.type]+=d.amount
			var names={"gold":"vàng","ore":"quặng","hide":"da","herb":"dược thảo","potion":"bình máu"}
			float_text(d.pos,"+%d %s"%[d.amount,names[d.type]],Color("b2d3a5"))
			drops.remove_at(i)
			sound(900,0.045)

func fx(p:Vector2,color:Color,kind:String,radius:float,angle:float=0) -> void:
	effects.append({"pos":p,"color":color,"kind":kind,"radius":radius,"angle":angle,"life":0.45,"max":0.45})

func float_text(p:Vector2,value:String,color:Color) -> void:
	texts.append({"pos":p,"text":value,"color":color,"life":0.9})

func _draw_effects() -> void:
	for d in drops:
		var colors={"gold":Color("e1bd6d"),"ore":Color("b1a4d7"),"hide":Color("bd9772"),"herb":Color("8cb38a"),"potion":Color("d4867d")}
		var c:Color=colors[d.type]
		var bounce=maxf(0,1.0-d.age)*absf(sin(d.age*10))*20
		var p:Vector2=d.pos-Vector2(0,3+bounce+sin(elapsed*3+d.pos.x)*1.2)
		effects_layer.draw_circle(d.pos,7,Color(c,0.13))
		effects_layer.draw_colored_polygon(PackedVector2Array([p+Vector2(-3,0),p+Vector2(0,-5),p+Vector2(3,0),p+Vector2(0,4)]),c)
		if player.position.distance_to(d.pos)<60:
			var names={"gold":"Vàng","ore":"Quặng","hide":"Da","herb":"Dược thảo","potion":"Bình máu"}
			effects_layer.draw_string(ThemeDB.fallback_font,p+Vector2(-23,-10),names[d.type],HORIZONTAL_ALIGNMENT_CENTER,46,9,Color("e6d8b9"))
	for shot in shots:
		var c=Color("d4c0a0") if shot.kind=="bow" else Color("afa1eb")
		effects_layer.draw_line(shot.pos-shot.dir*12,shot.pos,c,2)
		if shot.kind=="staff": effects_layer.draw_circle(shot.pos,4,c)
	for e in effects:
		var t=1-e.life/e.max
		var c:Color=e.color
		c.a*=1-t
		match e.kind:
			"slash":
				effects_layer.draw_arc(e.pos,e.radius*(0.65+t*0.35),e.angle-1.2+t,e.angle+0.6+t,18,c,3*(1-t)+1)
			"nova","heal":
				effects_layer.draw_arc(e.pos,e.radius*t,0,TAU,36,c,2)
				for n in range(10):
					var p:Vector2=e.pos+Vector2.from_angle(n*TAU/10+t)*e.radius*t
					effects_layer.draw_rect(Rect2(p,Vector2(3,3)),c)
			_:
				for n in range(7):
					var p:Vector2=e.pos+Vector2.from_angle(n*2.4)*e.radius*t
					effects_layer.draw_rect(Rect2(p,Vector2(2,2)),c)
	for text in texts:
		var c:Color=text.color
		c.a=minf(1,text.life*2)
		effects_layer.draw_string(ThemeDB.fallback_font,text.pos+Vector2(-20,-30-(1-text.life)*20),text.text,HORIZONTAL_ALIGNMENT_CENTER,80,11,c)
	# Bụi nhỏ, thưa để người chơi vẫn thấy rõ dấu báo đòn đánh.
	for i in range(20):
		var p=Vector2(fmod(i*139+elapsed*5,1280),fmod(i*87-elapsed*9+5000,960))
		effects_layer.draw_rect(Rect2(p,Vector2(1,1)),Color(0.85,0.76,0.62,0.25))

func player_died() -> void:
	shots.clear()
	# Để người chơi thấy tư thế gục xuống trước khi hiện nút hồi sinh.
	get_tree().create_timer(0.75).timeout.connect(func():
		if is_instance_valid(player) and player.hp<=0: hud.death_screen())

func respawn() -> void:
	bag.gold=int(bag.gold*0.9)
	hud.close_menu()
	load_map(0)
	player.position=Vector2(640,665)
	player.hp=player.max_hp
	player.stamina=player.max_stamina
	player.collision_layer=2
	player.hurt_cd=2
	player.set_state("revive",1.2)
	fx(player.position,Color("d3c7a1"),"nova",60)
	save_game()

func remember_map() -> void:
	var living:Array=[]
	for e in enemies:
		if is_instance_valid(e) and e.hp>0:
			living.append({"kind":e.kind,"x":e.position.x,"y":e.position.y,"hp":e.hp})
	var ground:Array=[]
	for d in drops:
		ground.append({"type":d.type,"x":d.pos.x,"y":d.pos.y,"amount":d.amount})
	map_states[str(map_id)]={"enemies":living,"drops":ground}

func save_game() -> bool:
	if player.hp<=0: return false
	remember_map()
	var data={"version":1,"map":map_id,"x":player.position.x,"y":player.position.y,"hp":player.hp,"stamina":player.stamina,"quest":quest,"day":day,"level":level,"xp":xp,"weapon":weapon,"outfit":outfit,"weapon_levels":weapon_levels,"owned_weapons":owned_weapons,"owned_outfits":owned_outfits,"visited":visited,"flags":flags,"bag":bag,"maps":map_states}
	# Ghi tạm trước để tránh mất toàn bộ tiến độ nếu lần ghi bị ngắt.
	var file=FileAccess.open(save_path+".tmp",FileAccess.WRITE)
	if file==null:
		if is_instance_valid(hud): hud.notify("Không ghi được bản lưu. Kiểm tra dung lượng ổ đĩa.")
		last_save_error=true
		return false
	file.store_string(JSON.stringify(data))
	file.close()
	var err=DirAccess.rename_absolute(save_path+".tmp",save_path)
	last_save_error=err!=OK
	return not last_save_error

func load_game() -> bool:
	if not FileAccess.file_exists(save_path): return false
	var data=JSON.parse_string(FileAccess.get_file_as_string(save_path))
	if not data is Dictionary or data.get("version",0)!=1:
		hud.notify("Bản lưu không hợp lệ.")
		return false
	quest=clampi(int(data.get("quest",0)),0,7)
	day=maxi(1,int(data.get("day",1)))
	level=maxi(1,int(data.get("level",1)))
	xp=maxi(0,int(data.get("xp",0)))
	weapon=clampi(int(data.get("weapon",0)),0,3)
	outfit=clampi(int(data.get("outfit",0)),0,3)
	weapon_levels=data.get("weapon_levels",[0,0,0,0])
	if weapon_levels.size()!=4: weapon_levels=[0,0,0,0]
	for i in range(4): weapon_levels[i]=clampi(int(weapon_levels[i]),0,5)
	owned_weapons=_int_array(data.get("owned_weapons",[0]))
	owned_outfits=_int_array(data.get("owned_outfits",[0]))
	visited=_int_array(data.get("visited",[0]))
	if not owned_weapons.has(weapon): weapon=0
	if not owned_outfits.has(outfit): outfit=0
	flags=data.get("flags",{})
	for key in bag:
		bag[key]=maxi(0,int(data.get("bag",{}).get(key,0)))
	map_states=data.get("maps",{})
	hud.close_menu()
	load_map(clampi(int(data.get("map",0)),0,9),false)
	refresh_stats()
	player.position=Vector2(data.get("x",640),data.get("y",660)).clamp(Vector2(40,95),Vector2(1240,910))
	if world.blocked(player.position): player.position=Content.MAPS[map_id].spawn
	player.hp=clampf(float(data.get("hp",100)),1,player.max_hp)
	player.stamina=clampf(float(data.get("stamina",100)),0,player.max_stamina)
	player.state="idle"
	player.state_time=0
	player.hurt_cd=1
	player.collision_layer=2
	camera.reset_smoothing()
	hud.notify("Đã tiếp tục hành trình")
	return true

func _int_array(values:Array) -> Array:
	var result:Array=[]
	for v in values: result.append(int(v))
	return result

func sound(frequency:float,duration:float) -> void:
	if testing or audio_cooldown>0: return
	audio_cooldown=0.05
	var stream=AudioStreamWAV.new()
	stream.format=AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate=22050
	var bytes=PackedByteArray()
	var count=int(22050*duration)
	bytes.resize(count*2)
	for i in range(count):
		var t=float(i)/22050
		var envelope=pow(1-float(i)/count,2)
		var sample=int(sin(TAU*frequency*t)*envelope*1700)
		bytes.encode_s16(i*2,sample)
	stream.data=bytes
	var audio=AudioStreamPlayer.new()
	audio.stream=stream
	add_child(audio)
	audio.finished.connect(audio.queue_free)
	audio.play()

func _notification(what:int) -> void:
	if what==NOTIFICATION_WM_CLOSE_REQUEST and is_instance_valid(player) and not testing:
		if is_instance_valid(hud) and hud.menu_kind!="title": save_game()

func _capture(path:String) -> void:
	hud.close_menu()
	player.position=Vector2(640,570)
	quest=2
	day=1
	player.hp=84
	await get_tree().process_frame
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png(path)
	print("CAPTURE_SAVED ",path)
	get_tree().quit()

func _run_tests() -> void:
	var suite=load("res://scripts/arpg/tests.gd").new()
	add_child(suite)
	await suite.run(self)
