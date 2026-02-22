@icon("uid://bc11spgof552w")
class_name AttackArea
extends Area2D

@export var damage: int = 1

func activate( duration: float = 0.1 ) -> void:
	_set_active()
	await get_tree().create_timer( duration ).timeout
	_set_active( false )


func _ready() -> void:
	body_entered.connect( _on_body_entered )
	area_entered.connect( _on_body_entered )
	visible = false
	monitorable = false
	monitoring = false


func _on_body_entered( body : Node2D) -> void:
	print( "Body entered: ", body.name)
	if body is DamageArea:
		body.take_damage(self)


func _set_active(value: bool = true) -> void:
	monitoring = value
	visible = value
