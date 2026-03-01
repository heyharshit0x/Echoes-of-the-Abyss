extends Node2D

signal on_interact

@onready var detection_area = $DetectionArea if has_node("DetectionArea") else null
@onready var prompt_label = $PromptLabel if has_node("PromptLabel") else null

var player_in_range = false

func _ready() -> void:
	if detection_area:
		detection_area.body_entered.connect(_on_body_entered)
		detection_area.body_exited.connect(_on_body_exited)
	
	if prompt_label:
		prompt_label.visible = false

func _process(_delta: float) -> void:
	if player_in_range and Input.is_action_just_pressed("ui_accept"):
		_try_win()

func _try_win() -> void:
	if GlobalState.current_gold >= GlobalState.WIN_GOLD_REQUIRED:
		# Deduct gold and load win screen
		GlobalState.current_gold -= GlobalState.WIN_GOLD_REQUIRED
		get_tree().change_scene_to_file("res://scenes/win_screen.tscn")
	else:
		# Show how much gold is still needed
		var needed = GlobalState.WIN_GOLD_REQUIRED - GlobalState.current_gold
		if prompt_label:
			prompt_label.text = "Need %d more gold!" % needed

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		player_in_range = true
		if prompt_label:
			var needed = GlobalState.WIN_GOLD_REQUIRED - GlobalState.current_gold
			if needed <= 0:
				prompt_label.text = "[SPACE] Escape the Abyss!"
			else:
				prompt_label.text = "[SPACE] Escape (%d/1000 Gold)" % GlobalState.current_gold
			prompt_label.visible = true

func _on_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		player_in_range = false
		if prompt_label:
			prompt_label.visible = false
