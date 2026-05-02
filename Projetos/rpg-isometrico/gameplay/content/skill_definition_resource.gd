class_name SkillDefinitionResource
extends Resource

enum SkillKind {
	PROJECTILE,
	SELF_BUFF,
	AREA_BURST,
	LEAP_STRIKE
}

@export var id: StringName
@export var race_id: StringName
@export var weapon_id: StringName
@export var display_name: String = ""
@export var description: String = ""
@export var kind: SkillKind = SkillKind.PROJECTILE
@export var cooldown: float = 3.0
@export var damage: float = 20.0
@export var range: float = 5.0
@export var duration: float = 0.0
@export var value: float = 0.0
