extends Control

var is_logging_in := false

func login():
	if is_logging_in:
		return
	else:
		is_logging_in = true
	print("Logging in")
	var username = $CenterContainer/PanelContainer/VBoxContainer/Username.text
	var token = $CenterContainer/PanelContainer/VBoxContainer/Token.text
	if username != "" and token != "":
		var success = yield(GameJolt.authenticate(username, token), "completed")
		print(success)
	is_logging_in = false
	get_parent().remove_child(self)
	pass

func _input(event):
	if Input.is_key_pressed(KEY_ENTER):
		login()

func _on_RichTextLabel2_meta_clicked(meta):
	OS.shell_open(meta)
