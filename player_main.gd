extends CharacterBody2D
class_name Player

@export var current_speed: float = 300.0

@onready var animation_tree: AnimationTree = $AnimationTree
@onready var player_sprite: Sprite2D = $PlayerSprite
@onready var character_state_machine: CharacterStateMachine = $CharacterStateMachine

func _ready() -> void:
	animation_tree.active = true

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	var direction := Input.get_axis("left", "right")
	if direction and character_state_machine.can_move():
		velocity.x = direction * current_speed
	else:
		velocity.x = move_toward(velocity.x, 0, current_speed)

	move_and_slide()

# ---- Update Visuals ---- #
	_update_animation(direction)
	_update_facing_directions(direction)

func _update_animation(direction) -> void:
	animation_tree.set("parameters/move/blend_position", direction)

func _update_facing_directions(direction) -> void:
	if direction > 0:
		player_sprite.flip_h = false
	elif direction < 0:
		player_sprite.flip_h = true
