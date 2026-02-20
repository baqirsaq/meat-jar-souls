extends Label

@export var character: CharacterBody2D

func _process(_delta: float) -> void:
	if not character:
		text = "No Character Assigned"
	else:
		text = "Speed: " + str(round(character.velocity))
