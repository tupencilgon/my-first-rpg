@tool
extends EditorPlugin

## Gan bang "Asset HD" vao cot ben phai cua Godot.
##
## Vi sao lam plugin trong Godot thay vi mot ung dung rieng: Godot DA la cong
## cu chinh vi tri va kich thuoc tot nhat - keo chuot la thay ngay. Cai Godot
## thieu la buoc BIEN MOT ANH PNG THANH PROP dung duoc, va cach kiem tra ti le
## giua cac asset. Bang nay lam dung hai viec do.

const PanelScript := preload("res://addons/bang_asset/bang_asset.gd")

var _panel: Control


func _enter_tree() -> void:
	_panel = PanelScript.new()
	_panel.plugin = self
	add_control_to_dock(DOCK_SLOT_RIGHT_UL, _panel)


func _exit_tree() -> void:
	if _panel != null:
		remove_control_from_docks(_panel)
		_panel.queue_free()
		_panel = null
