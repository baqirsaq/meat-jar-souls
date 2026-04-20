@icon("uid://bsrtlduc058r2")
class_name AbilityArea
extends Area2D

@export var ability_to_grant: Ability

func _ready():
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body):
	if body.has_method("set_available_ability"):
		body.set_available_ability(ability_to_grant)

func _on_body_exited(body):
	if body.has_method("set_available_ability"):
		body.set_available_ability(null)
