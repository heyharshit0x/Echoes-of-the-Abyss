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

func _process(delta: float) -> void:
	if player_in_range and Input.is_action_just_pressed("ui_accept"):
		on_interact.emit()

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		player_in_range = true
		if prompt_label:
			prompt_label.visible = true

func _on_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		player_in_range = false
		if prompt_label:
			prompt_label.visible = false
