class_name Player
extends Character

## Manages player higher level behaviour

@export var sparks_effect: PackedScene
@onready var animation_tree: AnimationTree = $AnimationTree
@onready var player_sprite: Sprite2D = $PlayerSprite
@onready var attack_node: AttackArea = $AttackArea
@onready var character_state_machine: CharacterStateMachine = $CharacterStateMachine
@onready var blood_splater: GPUParticles2D = $BloodSplater #TEMP FIXME REMOVEME PLZ

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
	animation_tree.set("parameters/guard/blend_position", movement_ratio)


func _update_facing_directions(direction) -> void:
	if direction > 0:
		player_sprite.flip_h = false
		attack_node.position.x = 43
	elif direction < 0:
		player_sprite.flip_h = true
		attack_node.position.x = -43

func _handle_horizontal_movement(direction: float) -> void:
	if direction and character_state_machine.can_move():
		velocity.x = move_toward(velocity.x, speed * direction, acceleration)
	else:
		velocity.x = move_toward(velocity.x, 0, deceleration)


func _on_damage_area_on_hit_received(attack_area: AttackArea, defense_state: DamageArea.DefenseState) -> void:
	match defense_state:
		DamageArea.DefenseState.PARRY:
			var effect_instance: GPUParticles2D = sparks_effect.instantiate()
			get_tree().current_scene.add_child(effect_instance)
			effect_instance.global_position = global_position
			effect_instance.emitting = true
		DamageArea.DefenseState.GUARD:
			lose_health(attack_area.damage - stats.current_defense) #TODO: find a better calculation approch
		DamageArea.DefenseState.NONE:
			lose_health(attack_area.damage)
			blood_splater.blood_start()
