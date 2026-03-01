extends StaticBody2D
class_name RockNode

# The rock now acts universally as a coin.
@export var max_health: int = 5 # Takes 5 hits (0.4s each) to break = 2 seconds
@export var min_drop: int = 5
@export var max_drop: int = 15

var current_health: int
@onready var sprite = $Sprite2D if has_node("Sprite2D") else null
@onready var hit_particles = $CPUParticles2D if has_node("CPUParticles2D") else null

func _ready() -> void:
	current_health = max_health

func hit_rock(mining_power: int) -> void:
	current_health -= mining_power
	
	if sprite:
		var original_color = sprite.modulate
		sprite.modulate = Color(1, 1, 1) # Flash white
		await get_tree().create_timer(0.05).timeout
		if sprite: sprite.modulate = original_color
		
	if hit_particles:
		hit_particles.emitting = true
		
	if current_health <= 0:
		break_rock()

func break_rock() -> void:
	var drop_amount = randi_range(min_drop, max_drop)
	
	# Directly add to current_gold since there's no other resources
	GlobalState.current_gold += drop_amount
	
	queue_free()
