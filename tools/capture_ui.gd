extends SceneTree
## Chup anh tung man giao dien de doi chieu. Chi dung khi kiem tra, khong phai
## mot phan cua game. Chay:
##   godot --path . --script res://tools/capture_ui.gd --resolution 1280x720

const OUT := "user://ui_shots/"


func _initialize() -> void:
	await _boot()


func _boot() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT))
	change_scene_to_file("res://scenes/arpg.tscn")
	await _wait(20)

	var game: Node = current_scene
	game.new_game()
	await _wait(10)

	# Dung mot canh co du thu de nhin: dang lam nhiem vu, mat mau, co binh.
	game.quest = 2
	game.day = 4
	game.level = 5
	game.xp = 180
	game.bag.potion = 7
	game.bag.gold = 247
	game.bag.ore = 16
	game.bag.hide = 8
	game.player.hp = game.player.max_hp * 0.62
	game.player.stamina = game.player.max_stamina * 0.62
	game.hud.close_menu()
	game.hud.notify("Hầm mỏ · Tim hắc thạch")
	await _wait(6)
	await _shot("01-gameplay")

	game.hud.inventory("equipment", 1)
	await _wait(4)
	await _shot("02-tui-do")

	game.hud.inventory("consumables", 0)
	await _wait(4)
	await _shot("03-tieu-hao")

	game.hud.smith()
	await _wait(4)
	await _shot("04-lo-ren")

	game.hud.dialogue("Edren", [
		"Kael... cháu có tìm thấy mẹ và em chưa?\n\nKael lắc đầu.",
		"Vậy ít nhất cháu vẫn còn thứ để đi tìm.",
	])
	await _wait(4)
	await _shot("05-hoi-thoai")

	game.hud.atlas()
	await _wait(4)
	await _shot("06-ban-do")

	game.hud.title_screen()
	await _wait(6)
	await _shot("07-man-hinh-dau")

	print("XONG. Anh o ", ProjectSettings.globalize_path(OUT))
	quit()


func _wait(frames: int) -> void:
	for _i in frames:
		await process_frame


func _shot(name: String) -> void:
	# Doi them vai khung de container kip tu can kich thuoc truoc khi chup.
	await _wait(3)
	var img := root.get_texture().get_image()
	var path := ProjectSettings.globalize_path(OUT + name + ".png")
	img.save_png(path)
	print("  -> ", path)
