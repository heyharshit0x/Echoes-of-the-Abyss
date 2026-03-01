extends CharacterBody2D
class_name Player

# Player Physics Properties
const SPEED = 250.0

# States
enum State { IDLE, RUN, ATTACK, MINE }
var current_state: State = State.IDLE

# Node References (Assume these will be created in the editor)
@onready var animation_player = $AnimationPlayer if has_node("AnimationPlayer") else null
@onready var sprite = $Sprite2D if has_node("Sprite2D") else null
@onready var interaction_area = $InteractionArea if has_node("InteractionArea") else null
@onready var mining_sound = $MiningSound if has_node("MiningSound") else null
@onready var running_sound = $RunningSound if has_node("RunningSound") else null

# Textures for different states
var _idle_texture = preload("res://assets/completed sprites/player_character.svg")
var _walk_texture = preload("res://assets/walking_anim.svg")

# Action timers/cooldowns
var is_acting: bool = false

func _physics_process(delta: float) -> void:
	if is_acting:
		# Stop movement while attacking/mining
		velocity = Vector2.ZERO
		move_and_slide()
		return
	
	handle_movement(delta)
	handle_actions()
	update_animations()


func handle_movement(_delta: float) -> void:
	# Get input direction strictly from Arrow Keys (ignoring WASD)
	var dir_x = Input.get_axis("ui_left", "ui_right") if (Input.is_physical_key_pressed(KEY_LEFT) or Input.is_physical_key_pressed(KEY_RIGHT)) else 0.0
	var dir_y = Input.get_axis("ui_up", "ui_down") if (Input.is_physical_key_pressed(KEY_UP) or Input.is_physical_key_pressed(KEY_DOWN)) else 0.0
	var direction := Vector2(dir_x, dir_y).normalized()
	
	if direction != Vector2.ZERO:
		velocity = direction * SPEED
		current_state = State.RUN
		
		# Flip Sprite based on X direction
		if sprite:
			if direction.x < 0:
				sprite.flip_h = true
			elif direction.x > 0:
				sprite.flip_h = false
		
		# Flip interaction area direction
		if interaction_area:
			if direction.x < 0:
				interaction_area.scale.x = -1
			elif direction.x > 0:
				interaction_area.scale.x = 1
	else:
		velocity = velocity.move_toward(Vector2.ZERO, SPEED)
		current_state = State.IDLE

	move_and_slide()

func handle_actions() -> void:
	# Assuming "attack" and "mine" actions are setup in Input Map
	if Input.is_action_pressed("attack"): # e.g., 'X' or 'Left Click'
		start_action(State.ATTACK)
	elif Input.is_action_pressed("mine"): # e.g., 'C' or 'Right Click'
		start_action(State.MINE)

func start_action(new_state: State) -> void:
	
	is_acting = true
	current_state = new_state
	
	# Attempt to play animation. If no AnimationPlayer, fake it with a timer.
	if animation_player:
		# Ensure we are using a sprite sheet that has multiple frames for these animations
		if sprite:
			sprite.texture = _walk_texture
			sprite.hframes = 4
			sprite.vframes = 2
			sprite.scale = Vector2(0.18, 0.18)

		if new_state == State.ATTACK:
			animation_player.play("attack")
		elif new_state == State.MINE:
			if mining_sound and not mining_sound.playing: mining_sound.play()
			animation_player.play("mine")
	else:
		# Fallback if no animations are set up yet
		trigger_hitbox()
		await get_tree().create_timer(0.4).timeout
		end_action()

# Called by AnimationPlayer at the end of the swing
func end_action() -> void:
	if mining_sound and mining_sound.playing:
		mining_sound.stop()
		
	is_acting = false
	current_state = State.IDLE

# Called by AnimationPlayer at the specific 'hit' frame
func trigger_hitbox() -> void:
	if not interaction_area: return
	
	var overalapping_bodies = interaction_area.get_overlapping_bodies()
	for body in overalapping_bodies:
		if current_state == State.MINE and body.has_method("hit_rock"):
			body.hit_rock(1) # Mining power is locked to 1

func update_animations() -> void:
	if current_state != State.RUN and running_sound and running_sound.playing:
		running_sound.stop()

	if not animation_player: return
	if is_acting: return
	
	var anim_name = ""
	match current_state:
		State.IDLE:
			anim_name = "idle"
			# Use static character sprite — no walking pose
			if sprite and sprite.texture != _idle_texture:
				sprite.texture = _idle_texture
				sprite.hframes = 1
				sprite.vframes = 1
				sprite.frame = 0
				sprite.scale = Vector2(0.1, 0.1)
		State.RUN:
			anim_name = "run"
			if running_sound and not running_sound.playing:
				running_sound.play()
			
			# Switch to the walk sprite sheet
			if sprite and sprite.texture != _walk_texture:
				sprite.texture = _walk_texture
				sprite.hframes = 4
				sprite.vframes = 2
				sprite.scale = Vector2(0.18, 0.18)
		
	if anim_name != "" and animation_player.has_animation(anim_name):
		animation_player.play(anim_name)
