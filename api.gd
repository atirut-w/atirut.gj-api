extends Node


var _username: String
var _token: String

var _gid: int
var _pk: String

const _url := "https://api.gamejolt.com/api/game/v1_2/"


func _ready() -> void:
	_gid = ProjectSettings["application/game_jolt_api/game_id"]
	_pk = ProjectSettings["application/game_jolt_api/private_key"]


# Authenticate a user's credentials
func auth(username: String, token: String) -> APIResponse:
	var response := yield(_api("users/auth", {
		"username": username,
		"user_token": token,
	}), "completed") as APIResponse

	_username = username
	_token = token

	return response


# Grant a trophy to the user
func grant_trophy(id: int) -> APIResponse:
	var response = yield(_api("trophies/add-achieved", {
		"trophy_id": id
	}, true), "completed")

	# API bug workaround
	if response.error == FAILED and response.error != ERR_UNAUTHORIZED:
		if "Incorrect trophy" in response.result:
			response.error = ERR_DOES_NOT_EXIST
	elif "message" in response.result and "already has this trophy" in response.result.message:
		response.error = ERR_ALREADY_EXISTS
		response.result = response.result.message
	
	return response


# Revoke a trophy from the user
func revoke_trophy(id: int) -> APIResponse:
	var response = yield(_api("trophies/remove-achieved", {
		"trophy_id": id
	}, true), "completed")

	# API bug workaround
	if response.error == FAILED and response.error != ERR_UNAUTHORIZED:
		if "Incorrect trophy" in response.result:
			response.error = ERR_DOES_NOT_EXIST
	elif "message" in response.result and "does not have this trophy" in response.result.message:
		response.error = ERR_DOES_NOT_EXIST
		response.result = response.result.message
	
	return response


# Make an API call. Avoid using this externally.
func _api(endpoint: String, params := {}, auth := false) -> APIResponse:
	params["game_id"] = _gid

	if auth:
		params["username"] = _username
		params["user_token"] = _token

	var url := _url + endpoint + "?"
	for k in params:
		url += "%s=%s&" % [k, params[k]]

	var signature := (url.trim_suffix("&") + _pk).md5_text()
	url += "signature=" + signature
	
	var httprq := HTTPRequest.new()
	add_child(httprq)

	var error := httprq.request(url)
	if error != OK:
		push_error("HTTPRequest error %d" % error)
		var response := APIResponse.new("HTTPRequest error", error)
		yield(get_tree(), "physics_frame")
		return response
	
	var body := (yield(httprq, "request_completed")[3] as PoolByteArray).get_string_from_ascii()
	var response := JSON.parse(body).result.response as Dictionary

	if response["success"] == "false":
		var message := response.message as String
		push_error(message)

		# See: https://gamejolt.com/game-api/doc/errors
		return APIResponse.new(message, (
			ERR_DOES_NOT_EXIST if "The game ID you passed in" in message
			else ERR_UNAUTHORIZED if (
				"The signature you entered" in message or
				"No such user" in message or
				"This key has restrictions" in message
			)
			else FAILED
		))

	return APIResponse.new(response)


class APIResponse:
	var error: int
	var result

	func _init(r, e := OK):
		error = e
		result = r
