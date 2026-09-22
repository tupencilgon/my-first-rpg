extends Node2D

## Ban thu huong "gia pixel art".
##
## Script nay dat do phan giai man hinh NGAY LUC CHAY thay vi sua project.godot,
## de ban chinh (scenes/main.tscn) khong bi anh huong gi. Nho vay hai huong
## chay song song duoc, so sanh truc tiep.
##
## === KHAC BIET KY THUAT LON NHAT ===
##
## Ban chinh:  640x360, phong to theo SO NGUYEN (x3 = 1080p)
##             -> moi pixel sprite thanh dung 3x3 pixel man hinh, vuong van
##
## Ban thu:    1920x1080, phong to theo PHAN SO
##             -> khong con rang buoc pixel vuong. Doi lai: art vao game truc
##                tiep, khong phai ep ve luoi 32px, khong phai convert gi.
##
## Day la toan bo su doi lai cua huong nay.

const VIEW := Vector2i(1920, 1080)


func _ready() -> void:
	var win := get_window()
	win.content_scale_size = VIEW
	win.content_scale_mode = Window.CONTENT_SCALE_MODE_CANVAS_ITEMS
	win.content_scale_aspect = Window.CONTENT_SCALE_ASPECT_EXPAND
	# FRACTIONAL (gia tri 0) = cho phep ti le khong nguyen. Dong quan trong nhat.
	win.content_scale_stretch = Window.CONTENT_SCALE_STRETCH_FRACTIONAL
	print("Ban thu HD: khung nhin ", VIEW, "  ti le khong nguyen")
