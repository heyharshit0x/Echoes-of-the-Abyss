extends Control

func _ready() -> void:
	$ReturnButton.pressed.connect(_on_return_pressed)

func _on_return_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
