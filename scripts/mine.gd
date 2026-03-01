extends Node2D

# =============================================
# Mine Scene Controller
# Simple loop: mine gold rocks → 1000 gold → win
# Rocks respawn automatically after being broken
# =============================================

const WIN_GOLD: int = 1000
const ROCK_RESPAWN_DELAY: float = 4.0
const ROCK_SCENE = preload("res://scenes/rock.tscn")

# UI
@onready var gold_label  = $CanvasLayer/GoldLabel  if has_node("CanvasLayer/GoldLabel")  else null
@onready var system_msg  = $CanvasLayer/SystemMessage if has_node("CanvasLayer/SystemMessage") else null



var rocks_container: Node2D
var win_triggered: bool = false

func _ready() -> void:
	var return_btn = $CanvasLayer/ReturnTownButton if has_node("CanvasLayer/ReturnTownButton") else null
	if return_btn:
		return_btn.pressed.connect(return_to_town)

	rocks_container = Node2D.new()
	rocks_container.name = "RocksContainer"
	add_child(rocks_container)

	spawn_all_rocks()

func _process(_delta: float) -> void:
	update_ui()
	check_win()

func update_ui() -> void:
	if gold_label: gold_label.text = "Gold: " + str(GlobalState.current_gold) + " / " + str(WIN_GOLD)

func check_win() -> void:
	if not win_triggered and GlobalState.current_gold >= WIN_GOLD:
		win_triggered = true
		get_tree().change_scene_to_file("res://scenes/win_screen.tscn")

# ─── Rock Spawning Loop ──────────────────────────────────────────────

func spawn_all_rocks() -> void:
	# Spawn gold coins scattered horizontally and vertically
	for i in range(-50, 50):
		# Spread them out every ~300 pixels
		var x_pos = i * 300 + randf_range(-100, 100)
		# Spread them vertically between Y=100 and Y=600 (playable area)
		var y_pos = randf_range(100, 600)
		spawn_rock(Vector2(x_pos, y_pos))

func spawn_rock(pos: Vector2) -> void:
	var rock: Node = ROCK_SCENE.instantiate()
	rock.position = pos
	rocks_container.add_child(rock)
	rock.tree_exiting.connect(_on_rock_removed.bind(pos))

func _on_rock_removed(pos: Vector2) -> void:
	await get_tree().create_timer(ROCK_RESPAWN_DELAY).timeout
	if is_inside_tree():
		spawn_rock(pos)

# ─── Navigation ─────────────────────────────────────────────────────

func return_to_town() -> void:
	get_tree().change_scene_to_file("res://scenes/town.tscn")
