tool
extends EditorPlugin


const settings := {
	"application/game_jolt_api/game_id": 0,
	"application/game_jolt_api/private_key": "",
}


func _enter_tree():
	for setting in settings:
		if ProjectSettings.get_setting(setting) == null:
			ProjectSettings.set_setting(setting, settings[setting])
			ProjectSettings.set_initial_value(setting, settings[setting])
	
	add_autoload_singleton("GameJolt", "res://addons/atirut.gj-api/api.gd")


func _exit_tree():
	for setting in settings:
		ProjectSettings.set_setting(setting, null)
	
	remove_autoload_singleton("GameJolt")
