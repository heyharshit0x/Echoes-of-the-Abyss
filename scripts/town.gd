extends Node2D

@onready var gold_label = $CanvasLayer/VBoxContainer/Panel/MarginContainer/DataContainer/GoldLabel if has_node("CanvasLayer/VBoxContainer/Panel/MarginContainer/DataContainer/GoldLabel") else null

func _ready() -> void:
	update_ui()
	
	# Clamp camera so it never scrolls into gray void
	if has_node("Player"):
		var cam = $Player.get_node_or_null("Camera2D")
		if cam:
			cam.limit_left   = 0
			cam.limit_top    = 0
			cam.limit_right  = 1152
			cam.limit_bottom = 648
			
	# Blacksmith now handles win-condition internally — no panel needed
	
	if has_node("MineEntrance"):
		$MineEntrance.on_interact.connect(_on_enter_mine_pressed)

func update_ui() -> void:
	if gold_label: gold_label.text = "Gold: " + str(GlobalState.current_gold)


func _on_enter_mine_pressed() -> void:
	print("Entering Mine...")
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/mine.tscn")
