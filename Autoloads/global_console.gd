extends Node


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Console.console_opened.connect(on_console_opened)


func on_console_opened() -> void:
	pass
