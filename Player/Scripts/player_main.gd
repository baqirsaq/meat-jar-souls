class_name Player
extends Character

## Manages player higher level behaviour

@onready var animation_tree: AnimationTree = $AnimationTree
@onready var player_sprite: Sprite2D = $PlayerSprite
@onready var character_state_machine: CharacterStateMachine = $CharacterStateMachine

func _ready() -> void:
	animation_tree.active = true


func _physics_process(delta: float) -> void:
	#TODO: Update it to work with the InputPackage
	var direction: float = Input.get_axis("left", "right")

	apply_gravity(delta)
	_handle_horizontal_movement(direction)

	move_and_slide()

# ---- Update Visuals ---- #
	_update_animation()
	_update_facing_directions(direction)


func _update_animation() -> void:
	var movement_ratio = velocity.x / speed
	animation_tree.set("parameters/move/blend_position", movement_ratio)
	animation_tree.set("parameters/sprint/blend_position", movement_ratio)


func _update_facing_directions(direction) -> void:
	if direction > 0:
		player_sprite.flip_h = false
	elif direction < 0:
		player_sprite.flip_h = true


func _handle_horizontal_movement(direction: float) -> void:
	if direction and character_state_machine.can_move():
		velocity.x = move_toward(velocity.x, speed * direction, acceleration)
	else:
		velocity.x = move_toward(velocity.x, 0, deceleration)
