extends Node2D

#region Exported Properties

@export var gradient: GradientTexture1D
## duration of a full day-night cycle in seconds
@export var cycle_duration: float = 300.0
## minimum light energy (midnight)
@export var min_energy: float = 0.1
## maximum light energy (noon)
@export var max_energy: float = 0.5

#endregion

#region Private Variables

var time: float = 0.0

#endregion

#region Node References

@onready var canvas_modulate: CanvasModulate = $CanvasModulate
@onready var main_env_light: DirectionalLight2D = $MainEnvLight

#endregion

func _exit_tree() -> void:
	Console.remove_command("set_time")


func _ready() -> void:
	# sets the time of day to a specific point in the cycle
	Console.add_command("set_time", console_set_time_of_day,
		["normalised_time", 1, "Value between 0.0 (midnight) and 1.0 (next midnight)"]
	)
	# returns the current time as a normalized value (0.0 to 1.0)
	Console.add_command("get_time_of_day", console_get_time_of_day)
	# pauses the day/night cycle
	Console.add_command("pause_daynight_cycle", console_pause_daynight_cycle)
	# resumes the day/night cycle
	Console.add_command("resume_daynight_cycle", console_resume_daynight_cycle)


func _process(delta: float) -> void:

	_update_time_of_day(delta)

	var current_light_intensity: float = _calculate_light_intensity()

	_apply_ambient_color(current_light_intensity)
	_apply_directional_light(current_light_intensity)
	_rotate_light_source()


func _update_time_of_day(delta: float) -> void:
	time += delta / cycle_duration

	if time > 1.0:
		time -= 1.0


func _calculate_light_intensity() -> float:
	return (sin(time * TAU - PI / 2.0) + 1.0) / 2.0


func _apply_ambient_color(intensity: float) -> void:
	canvas_modulate.color = gradient.gradient.sample(intensity)


func _apply_directional_light(intensity: float) -> void:
	main_env_light.color = gradient.gradient.sample(intensity)
	main_env_light.energy = lerp(min_energy, max_energy, intensity)


func _rotate_light_source() -> void:
	main_env_light.rotation = (time * TAU) - (PI / 2.0)


#region Public API

func console_set_time_of_day(normalised_time_param: String) -> void:
	var normalised_time: float = normalised_time_param.to_float()
	time = clamp(normalised_time, 0.0, 1.0)


func console_get_time_of_day() -> void:
	Console.print_line(time)


func console_pause_daynight_cycle() -> void:
	set_process(false)


func console_resume_daynight_cycle() -> void:
	set_process(true)


## returns whether it's currently daytime (light intensity > 50%)
func is_daytime() -> bool:
	return _calculate_light_intensity() > 0.5

#endregion
