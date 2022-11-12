extends Node


var _gid: int
var _pk: String

const _url := "https://api.gamejolt.com/api/game/v1_2/"


func _ready() -> void:
	_gid = ProjectSettings["application/game_jolt_api/game_id"]
	_pk = ProjectSettings["application/game_jolt_api/private_key"]


func auth(username: String, token: String) -> APIResponse:
	# TODO: Cache username and token
	var response := yield(_api("users/auth", {
		"username": username,
		"user_token": token,
	}), "completed") as APIResponse

	if response.error == FAILED:
		response.error = ERR_UNAUTHORIZED

	return response


func _api(endpoint: String, params := {}) -> APIResponse:
	params["game_id"] = _gid

	var url := _url + endpoint + "?"
	for k in params:
		url += "%s=%s&" % [k, params[k]]
	url = url.trim_suffix("&")

	var signature := (url + _pk).md5_text()
	url += "&signature=" + signature
	
	var httprq := HTTPRequest.new()
	add_child(httprq)

	var error := httprq.request(url)
	if error != OK:
		push_error("HTTPRequest error")
		var response := APIResponse.new("HTTPRequest error", error)
		yield(get_tree(), "physics_frame")
		return response
	
	var body := (yield(httprq, "request_completed")[3] as PoolByteArray).get_string_from_ascii()
	var response := JSON.parse(body).result.response as Dictionary

	if response["success"] == "false":
		push_error(response["message"])
		return APIResponse.new(response.message, FAILED)

	return APIResponse.new(response)


class APIResponse:
	var error: int
	var result

	func _init(r, e := OK):
		error = e
		result = r
