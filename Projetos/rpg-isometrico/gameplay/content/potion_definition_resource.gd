class_name PotionDefinitionResource
extends Resource

enum PotionKind {
	HEAL,
	BARRIER
}

@export var id: StringName
@export var race_id: StringName
@export var display_name: String = ""
@export var description: String = ""
@export var kind: PotionKind = PotionKind.HEAL
@export var cooldown: float = 12.0
@export var value: float = 40.0
@export var duration: float = 0.0
