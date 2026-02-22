extends Label

@export var character: Character

func _process(_delta: float) -> void:
	if not character:
		text = "No Character Assigned"
	else:
		text = "Health " + str(round(character.current_health))
