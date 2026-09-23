extends RefCounted
## Shared atlas mapping for the generated 8 x 4 monster sheets.
## Rows: down, up, left, right. Columns: idle, walk A, walk B,
## windup, strike, hurt, dying, dead.

const COLUMNS := 8
const ROWS := 4
const PATHS := {
	"Sói tro": "res://assets/arpg_v2/monsters/wolf.png",
	"Dơi hang": "res://assets/arpg_v2/monsters/bat.png",
	"Bọ tinh thạch": "res://assets/arpg_v2/monsters/beetle.png",
	"Cướp áo đen": "res://assets/arpg_v2/monsters/bandit.png",
	"Bóng sương": "res://assets/arpg_v2/monsters/wraith.png",
	"Thú hắc thạch": "res://assets/arpg_v2/monsters/crystal_beast.png",
	"Người giữ ấn": "res://assets/arpg_v2/monsters/seal_keeper.png",
}

static var _texture_cache:Dictionary = {}

static func texture_for(kind:String) -> Texture2D:
	if _texture_cache.has(kind):
		return _texture_cache[kind]
	var path:String = PATHS.get(kind, "")
	if path.is_empty() or not ResourceLoader.exists(path):
		_texture_cache[kind] = null
		return null
	var texture := load(path) as Texture2D
	_texture_cache[kind] = texture
	return texture

static func direction_row(facing:Vector2) -> int:
	if absf(facing.x) > absf(facing.y):
		return 3 if facing.x > 0.0 else 2
	return 0 if facing.y >= 0.0 else 1

static func animation_state(actor:Node) -> String:
	if actor.hp <= 0.0:
		return "dying" if actor.death_visual_time > 0.0 else "dead"
	if actor.state == "hurt":
		return "hurt"
	if actor.windup > 0.0:
		return "windup"
	if actor.strike_visual > 0.0:
		return "strike"
	if actor.velocity.length_squared() > 25.0:
		return "walk"
	return "idle"

static func frame_index(actor:Node) -> int:
	match animation_state(actor):
		"walk":
			return 1 + (int(actor.walk_phase / 1.3) & 1)
		"windup":
			return 3
		"strike":
			return 4
		"hurt":
			return 5
		"dying":
			return 6
		"dead":
			return 7
	return 0

static func source_rect(texture:Texture2D, row:int, column:int) -> Rect2:
	# Atlases are 1774 x 887, so integer division would slowly drift.
	# Rounded normalized boundaries keep every pixel in exactly one cell.
	var width := texture.get_width()
	var height := texture.get_height()
	var x0 := roundi(float(column) * width / COLUMNS)
	var x1 := roundi(float(column + 1) * width / COLUMNS)
	var y0 := roundi(float(row) * height / ROWS)
	var y1 := roundi(float(row + 1) * height / ROWS)
	return Rect2(x0, y0, x1 - x0, y1 - y0)

static func display_size(is_boss:bool) -> float:
	return 88.0 if is_boss else 50.0
