extends Node


func _ready() -> void:
	Console.console_opened.connect(on_console_opened)
	Console.console_closed.connect(on_console_closed)


func on_console_opened() -> void:
	InputPackage.pause_game_actions(true)


func on_console_closed() -> void:
	InputPackage.pause_game_actions(false)
