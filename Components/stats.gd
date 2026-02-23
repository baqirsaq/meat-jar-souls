class_name Stats
extends Resource

signal health_depleted
signal health_change(current_health: int, max_health: int)

enum BuffableStats {
	MAX_HEALTH,
	STAMINA,
	DEFENSE,
	ATTACK,
}

const STAT_CURVE: Dictionary[BuffableStats, Curve] = {
	BuffableStats.MAX_HEALTH: preload("uid://cqlu3w3c1tk3e"),
	BuffableStats.STAMINA: preload("uid://5iaffix37mfd"),
	BuffableStats.DEFENSE: preload("uid://chir03ggnuvhp"),
	BuffableStats.ATTACK: preload("uid://cgl60e2t5i424"),
}

const BASE_LEVEL_XP: float = 100.0

@export var base_max_health: int = 100 # when at level 1
@export var base_stamina: int = 10 # when at level 1
@export var base_defense: int = 10 # when at level 1
@export var base_attack: int = 10 # when at level 1
@export var experience: int = 0: set = _on_experience_set

var level: int:
	get(): return floor(max(1.0, sqrt(experience / BASE_LEVEL_XP)+ 0.5))
var current_max_health: int = 100
var current_defense: int = 10
var current_stamina: int = 10
var current_attack: int = 10

var health: int = 0: set = _on_health_set

var stat_buffs: Array[StatBuff]


func _init() -> void:
	call_deferred("setup_stats")


func setup_stats() -> void:
	recalculate_stats()
	health = current_max_health


func add_buff(buff: StatBuff) -> void:
	stat_buffs.append(buff)
	call_deferred("recalculate_stats")


func remove_buff(buff: StatBuff) -> void:
	stat_buffs.erase(buff)
	call_deferred("recalculate_stats")


func recalculate_stats() -> void:
	var stat_multipliers: Dictionary = {}
	var stat_addends: Dictionary = {}

	for buff in stat_buffs:
		_apply_buff_to_dicts(buff, stat_multipliers, stat_addends)

	var stat_sample_pos: float = (float(level) / 100.0) - 0.01
	@warning_ignore_start("narrowing_conversion")
	current_max_health = base_max_health * STAT_CURVE[BuffableStats.MAX_HEALTH].sample(stat_sample_pos)
	current_stamina    = current_stamina * STAT_CURVE[BuffableStats.STAMINA].sample(stat_sample_pos)
	current_defense    = current_defense * STAT_CURVE[BuffableStats.DEFENSE].sample(stat_sample_pos)
	current_attack     = current_attack  * STAT_CURVE[BuffableStats.ATTACK].sample(stat_sample_pos)

	for stat_name in stat_multipliers:
		var prop: String = "current_" + stat_name
		set(prop, get(prop) * stat_multipliers[stat_name])

	for stat_name in stat_addends:
		var prop: String = "current_" + stat_name
		set(prop, get(prop) + stat_addends[stat_name])  # Note: was a bug here, was using stat_multipliers


func _apply_buff_to_dicts(buff: StatBuff, stat_multipliers: Dictionary,
		stat_addends: Dictionary) -> void:
	var stat_name: String = BuffableStats.keys()[buff.stat].to_lower()

	match buff.buff_type:
		StatBuff.BuffType.ADD:
			if not stat_addends.has(stat_name):
				stat_addends[stat_name] = 0.0
			stat_addends[stat_name] += buff.buff_amount

		StatBuff.BuffType.MULTIPLY:
			if not stat_multipliers.has(stat_name):
				stat_multipliers[stat_name] = 1.0
			stat_multipliers[stat_name] += buff.buff_amount
			if stat_multipliers[stat_name] < 0.0:
				stat_multipliers[stat_name] = 0.0


func _on_health_set(new_value: int) -> void:
	health = clampi(new_value, 0, current_max_health)
	health_change.emit(health, current_max_health)
	if health <= 0:
		health_depleted.emit()


func _on_experience_set(new_value: int) -> void:
	var old_level: int = level
	experience = new_value

	if not old_level == level:
		recalculate_stats()


func _calculate_final_buff():
	var stat_multipliers: Dictionary = {} # Amount to multiply included stats by
	var stat_addends: Dictionary = {} # Amount to add to included stats
	for buff in stat_buffs:
		var stat_name: String = BuffableStats.keys()[buff.stat].to_lower()
		match buff.buff_type:
			StatBuff.BuffType.ADD:
				if not stat_addends.has(stat_name):
					stat_addends[stat_name] = 0.0
				stat_addends[stat_name] += buff.buff_amount

			StatBuff.BuffType.MULTIPLY:
				if not stat_multipliers.has(stat_name):
					stat_multipliers[stat_name] = 1.0
				stat_multipliers[stat_name] += buff.buff_amount

				if stat_multipliers[stat_name] < 0.0:
					stat_multipliers[stat_name] = 0
