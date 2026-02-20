class_name Character
extends CharacterBody2D

var speed: float = 0.0
var acceleration: float = 0.0
var deceleration: float = 0.0


func apply_gravity(delta) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
