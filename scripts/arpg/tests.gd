extends Node
## Kiểm tra hành vi thật qua scene đang chạy; bản lưu test tách khỏi người chơi.
var failures:Array[String]=[]
var checks=0
var game:Node
const MonsterVisuals = preload("res://scripts/arpg/monster_visuals.gd")
const UI = preload("res://scripts/arpg/ui_assets.gd")

func check(ok:bool,message:String) -> void:
	checks+=1
	if not ok:
		failures.append(message)
		push_error("TEST FAILED: "+message)

func finish_dialogue() -> void:
	var limit=20
	while game.hud.menu_kind=="dialogue" and limit>0:
		limit-=1
		if game.hud.dialogue_index==game.hud.dialogue_lines.size()-1 and not game.hud.dialogue_choices.is_empty():
			game.hud.dialogue_choices[0][1].call()
		else:
			game.hud.advance_dialogue()

func key(code:int,pressed:bool) -> void:
	var event=InputEventKey.new()
	event.physical_keycode=code
	event.keycode=code
	event.pressed=pressed
	Input.parse_input_event(event)

func menu_button(root:Node,text_value:String) -> Button:
	for node in root.find_children("*","Button",true,false):
		if node is Button and node.text == text_value and node.visible:
			return node
	return null

func close_button(root:Node) -> Button:
	for node in root.find_children("*","Button",true,false):
		if node is Button and node.tooltip_text == "Đóng [Esc]" and node.visible:
			return node
	return null

func verify_monster_atlases(g:Node) -> void:
	check(MonsterVisuals.PATHS.size()==7,"Seven monster atlas mappings are registered")
	for kind in MonsterVisuals.PATHS:
		var texture := MonsterVisuals.texture_for(kind)
		check(texture != null,"Monster atlas loads: %s" % kind)
		if texture == null:
			continue
		check(texture.get_width()>0 and texture.get_height()>0,"Monster atlas has pixels: %s" % kind)
		var covered := Rect2(Vector2.ZERO,Vector2(texture.get_width(),texture.get_height()))
		var accumulated := 0.0
		for row in range(MonsterVisuals.ROWS):
			for column in range(MonsterVisuals.COLUMNS):
				var source := MonsterVisuals.source_rect(texture,row,column)
				check(source.size.x>0 and source.size.y>0 and covered.encloses(source),"Atlas cell %s r%d c%d is valid" % [kind,row,column])
				accumulated += source.size.x*source.size.y
		check(is_equal_approx(accumulated,float(texture.get_width()*texture.get_height())),"Atlas cells cover full sheet: %s" % kind)
	for direction in [Vector2.DOWN,Vector2.UP,Vector2.LEFT,Vector2.RIGHT]:
		var expected:int = int([0,1,2,3][[Vector2.DOWN,Vector2.UP,Vector2.LEFT,Vector2.RIGHT].find(direction)])
		check(MonsterVisuals.direction_row(direction)==expected,"Monster direction row %s" % direction)

func verify_monster_states(g:Node) -> void:
	g.load_map(3)
	g.player.position=Vector2(640,700)
	var enemy:Variant = g.spawn_enemy("Sói tro",Vector2(640,670))
	for direction in [Vector2.DOWN,Vector2.UP,Vector2.LEFT,Vector2.RIGHT]:
		enemy.facing=direction
		for state in ["idle","walk","windup","strike","hurt","dying","dead"]:
			enemy.hp=enemy.max_hp
			enemy.state="idle"
			enemy.velocity=Vector2.ZERO
			enemy.windup=0
			enemy.strike_visual=0
			enemy.death_visual_time=0
			match state:
				"walk": enemy.velocity=Vector2(12,0)
				"windup": enemy.windup=0.2
				"strike": enemy.strike_visual=0.2
				"hurt": enemy.state="hurt"
				"dying": enemy.hp=0; enemy.death_visual_time=0.2
				"dead": enemy.hp=0
			check(enemy.monster_animation_state()==state,"Monster %s state uses %s frame" % [direction,state])
			var frame:int = int(enemy.monster_frame_index())
			check(frame>=0 and frame<MonsterVisuals.COLUMNS,"Monster %s frame remains in atlas" % state)
	# A real AI windup must lead to strike; hurt overrides the telegraph; death settles on final pose.
	enemy.hp=enemy.max_hp
	enemy.state="idle"
	enemy.hurt_cd=0
	enemy.windup=0
	enemy.strike_visual=0
	g.player.hp=g.player.max_hp
	enemy._update_enemy(0.01)
	check(enemy.monster_animation_state()=="windup" and enemy.monster_frame_index()==3,"Enemy starts windup before striking")
	enemy._update_enemy(0.60)
	check(enemy.monster_animation_state()=="strike" and enemy.monster_frame_index()==4,"Enemy strike frame follows real windup timing")
	enemy.hurt_cd=0
	enemy.take_hit(1,enemy.position+Vector2(20,0))
	check(enemy.monster_animation_state()=="hurt" and enemy.monster_frame_index()==5,"Hurt takes priority over attack telegraph")
	enemy.hurt_cd=0
	enemy.take_hit(99999,enemy.position+Vector2(20,0))
	check(enemy.monster_animation_state()=="dying" and enemy.monster_frame_index()==6,"Death starts dying frame")
	enemy.death_visual_time=0
	check(enemy.monster_animation_state()=="dead" and enemy.monster_frame_index()==7,"Death ends on final frame")

func verify_v2_ui(g:Node) -> void:
	for name in ["armor","bag","bow","dodge","forge","gold","herb","hide","map","nova","ore","potion","quest","settings","shield","staff","sword"]:
		check(UI.icon(name)!=null,"UI icon loads: %s" % name)
		# Chan lai dung loi da lam UI xau: icon 1254px ve o 34px thi nat thanh
		# vet mo. Anh giao dien phai la ban da thu nho san trong assets/ui/.
		check(UI.icon(name).get_width()<=128,"UI icon is pre-downscaled: %s" % name)
	for name in ["panel","portrait","title"]:
		check(UI.texture(name)!=null,"UI texture loads: %s" % name)
	g.hud.inventory("equipment",4)
	check(g.paused and g.hud.menu_kind=="inventory","Inventory opens as a modal")
	check(g.mouse_over_ui() and g.hud.shade.mouse_filter==Control.MOUSE_FILTER_STOP,"Modal consumes combat clicks")
	var equip_base := menu_button(g.hud.menu,"Mặc trang phục")
	check(equip_base!=null,"Visible inventory details offers outfit action")
	if equip_base != null: equip_base.pressed.emit()
	check(g.outfit==0 and g.player.armor==0,"Grid detail equips base outfit")
	g.hud.inventory("equipment",6)
	var equip_traveler := menu_button(g.hud.menu,"Mặc trang phục")
	check(equip_traveler!=null,"Grid selection updates outfit detail action")
	if equip_traveler != null: equip_traveler.pressed.emit()
	check(g.outfit==2 and g.player.armor==6,"Grid detail equips selected traveler outfit")
	g.hud.inventory("consumables",0)
	check(g.hud.inventory_tab=="consumables" and g.hud.inventory_selected==0,"Inventory tabs and slot selection persist")
	g.hud.close_menu()
	check(not g.paused and not g.mouse_over_ui(),"Closing inventory restores world input")
	g.player.skill_cd=5.0
	g.player.attack_cd=0.5
	g.hud._process(0.0)
	check(g.hud.hotbar_slots[2].cooldown_ratio>0.99 and g.hud.hotbar_slots[0].cooldown_ratio>0.0,"Hotbar cooldown overlays reflect live timers")
	g.hud.smith()
	var craft := menu_button(g.hud.menu,"RÈN / CHẾ TẠO")
	check(craft!=null and not craft.disabled,"Forge has enabled visible craft action with resources")
	g.hud.close_menu()
	g.talk("mara")
	check(g.paused and g.hud.menu_kind=="dialogue" and g.hud.dialogue_index==0,"Dialogue opens on its first line")
	var close_dialogue := close_button(g.hud.menu)
	check(close_dialogue!=null,"Dialogue exposes a visible close action")
	if close_dialogue != null: close_dialogue.pressed.emit()
	check(not g.paused and g.hud.menu_kind=="" and g.hud.dialogue_index==0,"Closing dialogue leaves story progression untouched")
	g.hud.title_screen()
	check(g.hud.menu.size.x<=400 and g.hud.menu_box.custom_minimum_size.x<=348,"Title menu keeps a narrow readable column")
	check(g.hud.shade.find_children("*","TextureRect",true,false).size()>0,"Title uses a full-screen background texture")
	g.hud.close_menu()

func run(g:Node) -> void:
	game=g
	g.new_game()
	finish_dialogue()
	check(not g.paused,"Intro ends and releases control")
	check(g.player.face(Vector2.RIGHT)==3,"Right animation row")
	check(g.player.face(Vector2.LEFT)==2,"Left animation row")
	check(g.player.face(Vector2.UP)==1,"Up animation row")
	check(g.player.face(Vector2.DOWN)==0,"Down animation row")
	g.player.position=Vector2(640,650)
	var start=g.player.position
	key(KEY_D,true)
	for i in range(18): await get_tree().physics_frame
	key(KEY_D,false)
	check(g.player.position.x>start.x+8 and absf(g.player.position.y-start.y)<2,"D moves right without inverted axes")
	check(g.player.facing.x>0.9,"Walking faces right")
	key(KEY_W,true)
	key(KEY_D,true)
	check(absf(g.player.motion_input().length()-1)<0.001,"Diagonal input normalized")
	key(KEY_W,false)
	key(KEY_D,false)
	g.player.position=Vector2(36,640)
	key(KEY_A,true)
	for i in range(18): await get_tree().physics_frame
	key(KEY_A,false)
	check(g.player.position.x>=36,"Boundary collision")
	verify_monster_atlases(g)
	verify_monster_states(g)
	g.talk("relics")
	finish_dialogue()
	check(g.quest==1 and g.flags.relics,"Relics advance first quest")
	g.talk("edren")
	finish_dialogue()
	check(g.quest==2 and g.flags.edren,"Edren dialogue choices advance quest")
	g.load_map(1)
	var herb_count=0
	for d in g.drops: if d.type=="herb": herb_count+=1
	check(herb_count>=3,"Enough herbs for tutorial")
	var loot_pos=Vector2(650,810)
	g.player.position=Vector2(650,760)
	g.drop_item("gold",loot_pos,17,false)
	var gold_before=g.bag.gold
	g.update_drops(0.01)
	check(g.bag.gold==gold_before,"Distant loot stays on ground")
	g.player.position=loot_pos
	g.update_drops(0.01)
	check(g.bag.gold==gold_before+17,"Walking over loot picks it up")
	g.bag.herb=3
	g.load_map(0)
	g.talk("healer")
	finish_dialogue()
	check(g.quest==3 and g.bag.herb==0,"Herb hand-in consumes resources")
	g.load_map(3)
	g.talk("hunter")
	finish_dialogue()
	g.talk("shortcut")
	finish_dialogue()
	check(g.flags.shortcut,"Dungeon shortcut unlocked")
	g.player.position=Vector2(640,750)
	var target=g.spawn_enemy("Sói tro",Vector2(640,718))
	var behind=g.spawn_enemy("Sói tro",Vector2(640,780))
	g.player.face(Vector2.UP)
	g.player.attack_cd=0
	g.player.state="idle"
	g.player.stamina=100
	var old_hp=target.hp
	check(g.player.attack(),"Basic attack available")
	check(target.hp<old_hp,"Melee hits forward target")
	check(behind.hp==behind.max_hp,"Melee cannot hit behind")
	check(not g.player.attack(),"Attack cooldown prevents repeated damage")
	g.player.state="idle"
	g.player.stamina=100
	check(g.player.dodge(),"Dodge spends stamina")
	old_hp=g.player.hp
	g.player.take_hit(30,g.player.position+Vector2(0,-20))
	check(g.player.hp==old_hp,"Dodge invulnerability")
	g.player.state="idle"
	g.player.state_time=0
	g.player.hurt_cd=0
	g.player.guarding=true
	g.player.guard_time=0.1
	g.player.face(Vector2.UP)
	g.player.take_hit(20,g.player.position+Vector2(0,-20))
	check(g.player.hp==old_hp,"Timed frontal parry")
	g.player.guard_time=0.5
	g.player.take_hit(20,g.player.position+Vector2(0,-20))
	check(g.player.hp<old_hp and g.player.hp>old_hp-10,"Guard reduces frontal damage")
	g.player.hurt_cd=0
	old_hp=g.player.hp
	g.player.take_hit(20,g.player.position+Vector2(0,20))
	check(g.player.hp<=old_hp-20,"Guard does not block rear attack")
	g.player.guarding=false
	g.player.hp=30
	g.player.state="idle"
	g.player.heal_cd=0
	var potions=g.bag.potion
	check(g.player.heal() and g.bag.potion==potions-1 and g.player.hp>30,"Healing consumes potion")
	g.player.state="idle"
	g.player.stamina=100
	g.player.skill_cd=0
	check(g.player.skill() and g.player.skill_cd>0,"Area skill has stamina cost and cooldown")
	g.bag.gold=200
	g.bag.ore=20
	g.bag.hide=10
	check(g.craft("bow") and g.owned_weapons.has(2),"Forge ranged weapon")
	check(not g.craft("bow"),"Cannot purchase owned weapon twice")
	check(g.craft("upgrade") and g.weapon_levels[0]==1,"Upgrade weapon")
	check(g.craft("outfit",2) and g.owned_outfits.has(2),"Craft outfit")
	g.outfit=2
	g.refresh_stats()
	check(g.player.armor==6,"Outfit applies defense")
	await verify_v2_ui(g)
	g.weapon=2
	g.player.attack_cd=0
	g.player.state="idle"
	g.player.position=Vector2(640,750)
	g.player.face(Vector2.UP)
	target.hurt_cd=0
	old_hp=target.hp
	g.player.attack()
	g.update_shots(0.1)
	check(target.hp<old_hp,"Arrow projectile hits enemy")
	g.load_map(4)
	for e in g.enemies:
		if e.boss:
			e.take_hit(9999,Vector2.ZERO)
	check(g.flags.get("mine_boss",false) and g.quest==4,"Dungeon boss advances story")
	g.load_map(5)
	for e in g.enemies:
		if e.kind=="Cướp áo đen": e.take_hit(9999,Vector2.ZERO)
	g.talk("merchant")
	finish_dialogue()
	check(g.quest==5,"Merchant recognizes Elara clue")
	g.load_map(0)
	g.talk("elder")
	finish_dialogue()
	check(g.quest==6 and g.owned_weapons.has(1) and g.weapon==1,"Chapter zero completes with father's sword")
	check(not g.world.interactables.any(func(p): return p.id=="edren"),"Chapter ending refreshes village NPCs")
	for id in range(10):
		g.load_map(id)
		check(not g.world.blocked(g.player.position),"Map %d has accessible spawn"%id)
		check(g.world.gates.size()>0,"Map %d has exit"%id)
		for gate in g.world.gates:
			check(not g.world.blocked(gate[1]),"Map %d exit is not blocked"%id)
	g.load_map(9)
	for e in g.enemies:
		if e.boss: e.take_hit(9999,Vector2.ZERO)
	check(g.quest==7,"Expansion boss completes extension")
	g.load_map(7)
	g.player.position=Vector2(640,810)
	g.player.hp=80
	g.drop_item("ore",Vector2(300,790),7,false)
	check(g.save_game(),"Atomic save succeeds")
	var expected_gold=g.bag.gold
	g.bag.gold=0
	g.level=1
	check(g.load_game(),"Load succeeds")
	check(g.bag.gold==expected_gold and g.quest==7 and g.map_id==7,"Save restores inventory and story")
	var saved_drop=false
	for d in g.drops: if d.type=="ore" and d.amount==7: saved_drop=true
	check(saved_drop,"Ground loot persists through save/load")
	g.player.hp=1
	g.player.hurt_cd=0
	g.player.state="idle"
	g.player.guarding=false
	g.player.take_hit(9999,g.player.position+Vector2(20,0))
	check(g.player.hp==0 and g.player.state=="dead","Lethal enemy damage enters death animation")
	await get_tree().create_timer(0.8).timeout
	check(g.hud.menu_kind=="death" and g.paused,"Death screen pauses combat")
	g.respawn()
	check(g.player.hp==g.player.max_hp and g.map_id==0 and g.player.state=="revive","Death and resurrection")
	check(g.bag.gold==int(expected_gold*0.9),"Death gold penalty is exactly ten percent")
	g.rest()
	finish_dialogue()
	check(g.day>=4,"Rest advances day")
	check(not g.world.interactables.any(func(p): return p.id=="edren"),"Edren leaves after first day")
	check(g.world.interactables.any(func(p): return p.id=="chair"),"Empty chair remains")
	# Kiểm tra nhánh người chơi ngủ trước khi gặp Edren, tránh kẹt nhiệm vụ.
	g.quest=1
	g.talk("chair")
	finish_dialogue()
	check(g.quest==2,"Resting early cannot softlock Edren quest")
	g.hud.atlas()
	check(g.paused and g.hud.menu_kind=="atlas","Map menu pauses hostile world")
	g.hud.close_menu()
	g.player.hp=g.player.max_hp*0.2
	g.player.state="idle"
	g.player.state_time=0
	g.player._update_player(0.01)
	check(g.player.state=="wounded","Low health triggers wounded state")
	g.player.hp=g.player.max_hp
	g.player.stamina=0
	g.player._update_player(0.01)
	check(g.player.state=="tired","Exhaustion triggers tired state")
	g.player.stamina=g.player.max_stamina
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--screenshots="):
			await screenshots(arg.trim_prefix("--screenshots="))
	print("ARPG_TEST_RESULT: ",checks," checks, ",failures.size()," failures")
	for f in failures: print("FAILED: ",f)
	DirAccess.remove_absolute(g.save_path)
	DirAccess.remove_absolute(g.save_path+".tmp")
	get_tree().quit(0 if failures.is_empty() else 1)

func shot(path:String) -> void:
	game.paused=true
	await get_tree().process_frame
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png(path)

func screenshots(folder:String) -> void:
	DirAccess.make_dir_recursive_absolute(folder)
	game.quest=2
	game.load_map(0,false)
	game.player.position=Vector2(640,570)
	game.player.state="idle"
	game.player.hurt_cd=0
	game.player.face(Vector2.DOWN)
	game.camera.reset_smoothing()
	await shot(folder+"/01-aster.png")
	game.hud.inventory()
	await shot(folder+"/02-inventory.png")
	game.hud.smith()
	await shot(folder+"/03-forge.png")
	game.hud.close_menu()
	game.talk("mara")
	await shot(folder+"/04-dialogue.png")
	game.hud.close_menu()
	game.load_map(4,false)
	game.player.position=Vector2(780,380)
	game.player.facing=Vector2.RIGHT
	game.player.state="attack"
	game.player.state_time=0.2
	game.spawn_enemy("Thú hắc thạch",Vector2(865,385))
	game.camera.reset_smoothing()
	game.fx(game.player.position,Color("e7ba75"),"nova",100)
	game.effects[-1].life=0.2
	game.effects_layer.queue_redraw()
	await shot(folder+"/05-combat.png")
	game.hud.title_screen()
	await shot(folder+"/06-title.png")
