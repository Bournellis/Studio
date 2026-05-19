class_name ProjectInfo
extends RefCounted

const PROJECT_NAME := "DraxosMobile"
const GODOT_VERSION := "4.6.2-stable"
const GUT_VERSION := "9.6.0"
const ACTIVE_TRACK := "Track 00 - First Slice Foundation"
const MVP_MODE := "MVP_ONLY"

static func boot_actions() -> PackedStringArray:
	return PackedStringArray([
		"Entrar como guest",
		"Solicitar batalha",
		"Ver resultado"
	])
