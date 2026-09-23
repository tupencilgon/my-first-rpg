extends Node2D
## Mỗi map ARPG có bố cục riêng; không sửa TileMap vẽ tay trong main.tscn.
const Content = preload("res://scripts/arpg/content.gd")
var game:Node
var map_id = 0
var biome = "village"
var terrain:ImageTexture
var objects:Node2D
var blockers:Array[Rect2] = []
var interactables:Array[Dictionary] = []
var gates:Array = []
var rng = RandomNumberGenerator.new()

func build(id:int) -> void:
	map_id = id
	biome = Content.MAPS[id].biome
	rng.seed = id*7349+123
	objects = Node2D.new()
	objects.y_sort_enabled = true
	add_child(objects)
	gates = Content.MAPS[id].links
	_make_ground()
	for rect in [Rect2(0,0,1280,55),Rect2(0,925,1280,35),Rect2(0,0,30,960),Rect2(1250,0,30,960)]:
		barrier(rect)
	if id == 0:
		for p in [Vector2(390,490),Vector2(850,410),Vector2(400,760),Vector2(930,680)]:
			prop("burnt_house",p)
		add_point("relics","Nhà Kael",Vector2(390,477),"relic")
		add_npc("elder","Trưởng làng",Vector2(620,495),Color("ae9770"))
		add_npc("healer","Thầy thuốc",Vector2(535,635),Color("789d8f"))
		add_npc("smith","Thợ rèn",Vector2(895,652),Color("aa7558"))
		add_npc("inn","Chủ quán trọ",Vector2(430,725),Color("9d8caa"))
		prop("chair",Vector2(854,457))
		if game.day == 1:
			add_npc("edren","Edren",Vector2(854,449),Color("716b63"))
		else:
			add_point("chair","Chiếc ghế trống",Vector2(854,460),"memory")
		if game.day<3:
			add_npc("mara","Mara",Vector2(690,345),Color("956a6e"))
		add_point("fire","Lửa trại",Vector2(640,608),"fire")
	elif id == 2:
		for y in [320,430,540]:
			for x in [440,525,610,695,780]:
				prop("gravestone",Vector2(x,y))
		add_point("grave","Gia đình Edren",Vector2(525,552),"memory")
	elif id == 3:
		add_npc("hunter","Thợ săn già",Vector2(300,710),Color("8b916a"))
		for r in [Rect2(480,280,90,290),Rect2(740,580,230,65),Rect2(870,120,60,250)]:
			barrier(r)
		add_point("shortcut","Tời kéo · mở lối tắt",Vector2(1040,590),"lever")
	elif id == 4:
		add_point("symbol","Dấu ấn lạ",Vector2(920,300),"relic")
	elif id == 5:
		add_npc("merchant","Thương nhân",Vector2(890,465),Color("b59b73"))
	elif id == 6:
		prop("burnt_house",Vector2(470,430))
		prop("burnt_house",Vector2(830,600))
		add_npc("mara_far","Mara",Vector2(500,480),Color("956a6e"))
		add_npc("trader","Người bán hàng",Vector2(780,530),Color("a79269"))
		add_point("fire","Lửa trại",Vector2(640,540),"fire")
	elif id == 9:
		add_point("seal","Ấn hắc nhật",Vector2(900,300),"relic")
	# Đặt cây ngoài hành lang chính; không dùng hình cây làm cả vùng va chạm.
	for i in range(44 if biome in ["forest","marsh"] else 25):
		var p = Vector2(rng.randf_range(80,1200),rng.randf_range(170,880))
		if _reserved(p):
			continue
		if biome in ["mine","depths","ruins","sanctum"]:
			barrier(Rect2(p-Vector2(15,12),Vector2(30,24)))
		else:
			prop("tree",p)
	if game.day>2 and id==0:
		for p in [Vector2(750,600),Vector2(430,585)]:
			add_point("rebuild","Vật liệu tái thiết",p,"wood")
	queue_redraw()

func _reserved(p:Vector2) -> bool:
	if absf(p.x-640)<110 or absf(p.y-520)<85:
		return true
	if p.distance_to(Content.MAPS[map_id].spawn)<120:
		return true
	for g in gates:
		if p.distance_to(g[1])<120:
			return true
	for n in interactables:
		if p.distance_to(n.pos)<100:
			return true
	return false

func _make_ground() -> void:
	var palette = [Color("504733"),Color("61533e"),Color("423f32")]
	match biome:
		"forest": palette = [Color("3d4737"),Color("525641"),Color("354032")]
		"graveyard": palette = [Color("4f5145"),Color("5d5c4f"),Color("454b43")]
		"mine","depths": palette = [Color("39373b"),Color("464045"),Color("302f35")]
		"pass","outpost": palette = [Color("52585b"),Color("646b69"),Color("485054")]
		"marsh","ruins","sanctum": palette = [Color("383e48"),Color("454957"),Color("30353e")]
	var im = Image.create(640,480,false,Image.FORMAT_RGB8)
	for y in range(480):
		for x in range(640):
			var col:Color = palette[0]
			var noise = sin(x*0.031+y*0.025)+sin(y*0.06-x*0.011)
			if noise>0.8: col = palette[1]
			elif noise< -0.8: col = palette[2]
			var path_x = 320+sin(y*0.018)*20
			var path_y = 265+sin(x*0.018)*18
			if absf(x-path_x)<24 or absf(y-path_y)<22:
				col = Color("79654a") if map_id<3 else palette[1].lightened(0.055)
			col = col.lightened(rng.randf_range(-0.07,0.07))
			im.set_pixel(x,y,col)
	terrain = ImageTexture.create_from_image(im)

func barrier(rect:Rect2) -> void:
	blockers.append(rect)
	var body = StaticBody2D.new()
	body.position = rect.get_center()
	var shape = CollisionShape2D.new()
	var box = RectangleShape2D.new()
	box.size = rect.size
	shape.shape = box
	body.add_child(shape)
	objects.add_child(body)

func prop(type:String,p:Vector2) -> void:
	# AtlasTexture lấy từng vật thể từ ảnh tham chiếu ngay trong engine; không đổi ảnh nguồn.
	var scene = Node2D.new()
	scene.position = p
	objects.add_child(scene)
	var atlas = AtlasTexture.new()
	var dimensions = Vector2(90,144)
	match type:
		"tree":
			atlas.atlas=load("res://docs/art/map-source-v01/04_burnt_trees.png")
			atlas.region=Rect2(520,12,480,722) if rng.randf()>0.5 else Rect2(1020,15,495,720)
			dimensions=Vector2(86,129)
		"burnt_house":
			atlas.atlas=load("res://docs/art/map-source-v01/03_buildings.png")
			atlas.region=Rect2(32,115,405,450)
			dimensions=Vector2(114,127)
		"chair":
			atlas.atlas=load("res://docs/art/map-source-v01/05_props.png")
			atlas.region=Rect2(94,82,190,296)
			dimensions=Vector2(19,30)
		"gravestone":
			atlas.atlas=load("res://docs/art/map-source-v01/05_props.png")
			atlas.region=Rect2(74,454,221,255)
			dimensions=Vector2(25,29)
	var sprite=Sprite2D.new()
	sprite.texture=atlas
	sprite.scale=dimensions/atlas.region.size
	sprite.position=Vector2(0,-dimensions.y/2)
	scene.add_child(sprite)
	if type=="burnt_house" and ((game.day>=3 and p.x>800) or biome=="outpost"):
		var roof=Sprite2D.new()
		var roof_atlas=AtlasTexture.new()
		roof_atlas.atlas=load("res://docs/art/map-source-v01/06_overhead_parts.png")
		roof_atlas.region=Rect2(25,112,615,335)
		roof.texture=roof_atlas
		roof.scale=Vector2(120,65)/roof_atlas.region.size
		roof.position=Vector2(0,-99)
		scene.add_child(roof)
	if biome == "marsh":
		scene.modulate = Color("999eb4")
	if type == "burnt_house":
		barrier(Rect2(p+Vector2(-48,-103),Vector2(96,18)))
		barrier(Rect2(p+Vector2(-48,-85),Vector2(14,78)))
		barrier(Rect2(p+Vector2(34,-85),Vector2(14,78)))
	elif type == "tree":
		barrier(Rect2(p+Vector2(-8,-10),Vector2(16,10)))
	elif type == "gravestone":
		barrier(Rect2(p+Vector2(-10,-8),Vector2(20,8)))

func add_npc(id:String,label:String,p:Vector2,col:Color) -> void:
	var npc = load("res://scripts/arpg/actor.gd").new()
	npc.role = "npc"
	npc.title = label
	npc.game = game
	npc.position = p
	npc.tint = col
	objects.add_child(npc)
	add_point(id,label,p,"npc")

func add_point(id:String,label:String,p:Vector2,type:String) -> void:
	interactables.append({"id":id,"label":label,"pos":p,"type":type})

func blocked(p:Vector2, margin:float=8) -> bool:
	for rect in blockers:
		if rect.grow(margin).has_point(p):
			return true
	return false

func _draw() -> void:
	if terrain == null:
		return
	draw_texture_rect(terrain,Rect2(0,0,1280,960),false)
	for r in blockers:
		if r.size.x<300 and r.size.y<300 and biome in ["mine","depths","ruins","sanctum"]:
			draw_rect(r.grow(4),Color("292831"))
			draw_rect(r,Color("57515c"))
			draw_line(r.position,r.position+Vector2(r.size.x,0),Color("7f7781"),3)
	if biome in ["mine","depths","sanctum"]:
		for i in range(14):
			var p = Vector2(100+i*81,170+sin(i*7.2)*50)
			draw_colored_polygon(PackedVector2Array([p+Vector2(-6,5),p+Vector2(-2,-18),p+Vector2(5,-8),p+Vector2(8,8)]),Color("8d7bab"))
	for g in gates:
		var p:Vector2 = g[1]
		draw_circle(p,26,Color(0.67,0.68,0.56,0.12))
		draw_arc(p,22,0,TAU,24,Color("a7ad98"),1)
		draw_line(p+Vector2(-6,0),p+Vector2(6,0),Color("e2d9af"),2)
		draw_line(p+Vector2(2,-4),p+Vector2(6,0),Color("e2d9af"),2)
		draw_line(p+Vector2(2,4),p+Vector2(6,0),Color("e2d9af"),2)
		draw_string(ThemeDB.fallback_font,p+Vector2(-64,42),g[2],HORIZONTAL_ALIGNMENT_CENTER,128,10,Color("d7d3b8"))
	for point in interactables:
		var p:Vector2 = point.pos
		if point.type == "npc":
			draw_string(ThemeDB.fallback_font,p+Vector2(-55,-43),point.label,HORIZONTAL_ALIGNMENT_CENTER,110,10,Color("e6d6b2"))
		elif point.type == "fire":
			draw_circle(p,24,Color(0.9,0.5,0.25,0.13))
			draw_line(p+Vector2(-8,3),p+Vector2(8,-2),Color("49362a"),4)
			draw_colored_polygon(PackedVector2Array([p+Vector2(-7,0),p+Vector2(-3,-13),p+Vector2(0,-8),p+Vector2(3,-20),p+Vector2(7,0)]),Color("df9b51"))
		elif point.type in ["relic","lever"]:
			draw_circle(p,5,Color("d9b97f"))
			draw_arc(p,9,0,TAU,16,Color("978768"),1)
		elif point.type == "wood":
			draw_rect(Rect2(p-Vector2(18,8),Vector2(36,12)),Color("9a7b57"))
