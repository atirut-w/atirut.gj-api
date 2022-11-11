tool
extends EditorPlugin


const settings := {
	"application/game_jolt_api/private_key": ""
}


func _enter_tree():
	for setting in settings:
		ProjectSettings.set_setting(setting, settings[setting])


func _exit_tree():
	for setting in settings:
		ProjectSettings.set_setting(setting, null)
