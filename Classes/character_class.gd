class_name Character
extends CharacterBody2D

@export var stats: Stats
var speed: float = 0.0
var acceleration: float = 0.0
var deceleration: float = 0.0
var current_health: int = 1000
var _gravity_min: float = 920.0
var _gravity_max: float = 1100.0


func _ready() -> void:
	stats.recalculate_stats()
	current_health = stats.current_max_health


func apply_gravity(delta) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

func lose_health(value: int) -> void:
	current_health -= value
