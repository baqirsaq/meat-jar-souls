@icon("uid://bsrtlduc058r2")
class_name DamageArea
extends Area2D

signal on_hit_received(attack_area: AttackArea, defense_state: DefenseState)

enum DefenseState { NONE, GUARD, PARRY }

@export var audio: AudioStream #TODO
@export var current_defense: DefenseState = DefenseState.NONE

func take_damage(attack_area: AttackArea) -> void:
	on_hit_received.emit(attack_area, current_defense)

	match current_defense:
		DefenseState.PARRY:
			print("PARRIED! No damage taken, attacker stunned.")

		DefenseState.GUARD:
			print("BLOCKED! Reduced damage taken.")

		DefenseState.NONE:
			print("DAMAGE!! ", attack_area.name)

	if audio:
		pass #TODO


func make_invulnerable(duration: float = 0.3) -> void:
	process_mode = Node.PROCESS_MODE_DISABLED
	await get_tree().create_timer(duration).timeout
	process_mode = Node.PROCESS_MODE_INHERIT


# --- State Setters ---
func set_defense_state(new_state: DefenseState) -> void:
	current_defense = new_state


func parry() -> void:
	current_defense = DefenseState.PARRY


func guard() -> void:
	current_defense = DefenseState.GUARD


func none() -> void:
	current_defense = DefenseState.NONE
