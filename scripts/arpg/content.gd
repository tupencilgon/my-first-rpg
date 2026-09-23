extends RefCounted
## Dữ liệu vùng đất tách khỏi luật chiến đấu để có thể thêm map mà không sửa nhân vật.

const WEAPONS = [
	{"name":"Kiếm tập gãy", "kind":"sword", "damage":17, "reach":47, "delay":0.36, "cost":6},
	{"name":"Kiếm của cha", "kind":"sword", "damage":27, "reach":55, "delay":0.34, "cost":7},
	{"name":"Cung thợ săn", "kind":"bow", "damage":22, "reach":300, "delay":0.48, "cost":8},
	{"name":"Trượng tinh thạch", "kind":"staff", "damage":30, "reach":260, "delay":0.58, "cost":10}
]
const OUTFITS = [
	{"name":"Áo choàng tro", "color":Color("786b55"), "armor":0},
	{"name":"Áo thợ săn", "color":Color("607c67"), "armor":3},
	{"name":"Giáp lữ hành", "color":Color("7189a5"), "armor":6},
	{"name":"Áo người giữ lửa", "color":Color("aa5653"), "armor":4}
]
const MAPS = [
	{"name":"Aster · Làng tro tàn", "region":"I · MIỀN TRO", "biome":"village", "level":0, "spawn":Vector2(640,660), "links":[[1,Vector2(640,160),"Rừng phía nam"],[2,Vector2(1110,450),"Đồi tưởng niệm"],[3,Vector2(1110,710),"Hầm mỏ phía đông"]]},
	{"name":"Rừng phía nam", "region":"I · MIỀN TRO", "biome":"forest", "level":1, "spawn":Vector2(640,790), "links":[[0,Vector2(640,850),"Làng Aster"],[5,Vector2(640,120),"Đèo phương bắc"]]},
	{"name":"Đồi tưởng niệm", "region":"I · MIỀN TRO", "biome":"graveyard", "level":0, "spawn":Vector2(210,500), "links":[[0,Vector2(130,500),"Làng Aster"]]},
	{"name":"Hầm mỏ · Tầng trên", "region":"I · MIỀN TRO", "biome":"mine", "level":2, "spawn":Vector2(220,720), "links":[[0,Vector2(140,740),"Làng Aster"],[4,Vector2(1110,260),"Tầng sâu"]]},
	{"name":"Hầm mỏ · Tim hắc thạch", "region":"I · MIỀN TRO", "biome":"depths", "level":3, "spawn":Vector2(210,730), "links":[[3,Vector2(130,760),"Tầng trên"],[0,Vector2(1080,740),"Thang về Aster"]]},
	{"name":"Đèo gió bắc", "region":"II · BIÊN ĐỊA", "biome":"pass", "level":3, "spawn":Vector2(640,770), "links":[[1,Vector2(640,850),"Rừng phía nam"],[6,Vector2(1090,430),"Trạm lữ hành"]]},
	{"name":"Trạm lữ hành", "region":"II · BIÊN ĐỊA", "biome":"outpost", "level":0, "spawn":Vector2(220,550), "links":[[5,Vector2(130,550),"Đèo gió bắc"],[7,Vector2(1090,450),"Cổng sương"]]},
	{"name":"Đầm sương tím", "region":"III · CÕI SƯƠNG", "biome":"marsh", "level":4, "spawn":Vector2(210,520), "links":[[6,Vector2(130,520),"Trạm lữ hành"],[8,Vector2(1090,430),"Phế tích vọng âm"]]},
	{"name":"Phế tích vọng âm", "region":"III · CÕI SƯƠNG", "biome":"ruins", "level":5, "spawn":Vector2(220,700), "links":[[7,Vector2(130,760),"Đầm sương tím"],[9,Vector2(1100,280),"Điện hắc nhật"]]},
	{"name":"Điện hắc nhật", "region":"III · CÕI SƯƠNG", "biome":"sanctum", "level":6, "spawn":Vector2(220,720), "links":[[8,Vector2(130,770),"Phế tích vọng âm"]]}
]
const QUESTS = [
	["Những gì còn lại", "Về nhà Kael phía tây Aster. Tìm chiếc khăn và ngựa gỗ. [E]"],
	["Người ở lại", "Nói chuyện với Edren bên chiếc ghế ở phía đông làng."],
	["Một chút sự sống", "Đến rừng phía bắc. Nhặt 3 dược thảo rồi gặp thầy thuốc tại Aster."],
	["Nguồn sống dưới núi", "Gặp thợ săn ở cửa hầm mỏ, xuống tầng sâu và hạ Thú hắc thạch."],
	["Dấu vết phương bắc", "Đến Đèo gió bắc qua rừng. Dẹp nhóm cướp, nói chuyện với thương nhân."],
	["Trước lúc lên đường", "Trở về gặp trưởng làng tại Aster. Nhận thanh kiếm của cha."],
	["Chương I · Dấu vết phương bắc", "Khám phá Biên địa và Cõi sương. Gặp lại Mara tại trạm lữ hành."],
	["Ngọn lửa chưa tắt", "Bạn đã đánh bại Người giữ ấn. Có thể tiếp tục khám phá, rèn đồ và giúp Aster."]
]

static func enemy_stats(kind:String, level:int) -> Dictionary:
	var boss = kind in ["Thú hắc thạch", "Người giữ ấn"]
	return {"hp":(300 + level*50) if boss else (34 + level*13), "damage":(16 + level*2) if boss else (7+level*2), "speed":44 if boss else (64 if kind == "Dơi hang" else 48), "xp":150 if boss else 15+level*5, "boss":boss}
