extends Node2D

@export var gradient: GradientTexture1D
@export var cycle_duration: float = 300.0

## Minimum light energy (Midnight)
@export var min_energy: float = 0.1
## Maximum light energy (Noon)
@export var max_energy: float = 0.5

var time: float = 0.0

@onready var canvas_modulate: CanvasModulate = $CanvasModulate
@onready var main_env_light: DirectionalLight2D = $MainEnvLight


func _process(delta: float) -> void:
	time += delta / cycle_duration
	if time > 1.0:
		time -= 1.0

	var value: float = (sin(time * TAU - PI / 2) + 1.0) / 2

	canvas_modulate.color = gradient.gradient.sample(value)
	main_env_light.color = gradient.gradient.sample(value)

	main_env_light.energy = lerp(min_energy, max_energy, value)

	main_env_light.rotation = (time * TAU) - (PI / 2)
