tool
extends EditorPlugin


const settings := {
	"application/game_jolt_api/private_key": ""
}


func _enter_tree():
	for setting in settings:
		if ProjectSettings[setting] == null:
			ProjectSettings.set_setting(setting, settings[setting])
			ProjectSettings.set_initial_value(setting, settings[setting])


func _exit_tree():
	for setting in settings:
		ProjectSettings.set_setting(setting, null)
