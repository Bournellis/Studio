extends "res://modes/boot/boot_runtime.gd"

# Thin shell kept as the scene-facing script. The runtime stays in
# boot_runtime.gd so future routes/features do not grow this entrypoint again.
const _FOUNDATION_SHELL_BOUNDARIES := [
	"app_shell_action_contract.gd",
	"account_session_flow.gd",
	"surface_action_flow.gd",
	"battle_lifecycle_flow.gd",
	"surface_ui_helpers.gd",
]
