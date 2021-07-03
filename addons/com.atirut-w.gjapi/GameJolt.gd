extends Node

var gameID := ""
var gameKey := ""

var username := ""
var token := ""
var is_authenticated := false
var is_authenticating := false

const baseURL := "api.gamejolt.com/api/game"
var version = APIVersion.v1_2
const APIVersion = {
	v1_2 = "v1_2"
}

func authenticate(un: String, tk: String) -> bool:
	assert(not is_authenticating, "already authenticating")
	is_authenticating = true
	var response = yield(send_request("users/auth", {game_id = gameID, username = un, user_token = tk}), "completed")
	if response.success == "true":
		username = un
		token = tk
		is_authenticated = true
		is_authenticating = false
		return true
	else:
		username = ""
		token = ""
		is_authenticated = false
		is_authenticating = false
		return false

func auto_login():
	assert(not is_authenticating, "already authenticating")
	add_child(preload("res://addons/com.atirut-w.gjapi/gui/login/login.tscn").instance())

func query_users(query: Dictionary) -> Array:
	var request := {game_id = gameID}
	for key in query:
		request[key] = query[key]
	var response = yield(send_request("users", request), "completed")
	return response.users

# May the people forgive me, for I have stolen this code from Discord.
func query_trophies(query: Dictionary) -> Array:
	var request := {
		game_id = gameID,
		username = username,
		user_token = token
	}
	for key in query:
		request[key] = query[key]
	var response = yield(send_request("trophies", request), "completed")
	return response.trophies

func grant_trophy(id: int) -> bool:
	var response = yield(send_request("trophies/add-achieved", {game_id = gameID, username = username, user_token = token, trophy_id = id}), "completed")
	return bool(response.success)

func revoke_trophy(id: int) -> bool:
	var response = yield(send_request("trophies/remove-achieved", {game_id = gameID, username = username, user_token = token, trophy_id = id}), "completed")
	return bool(response.success)

func get_server_time(utc := false) -> Dictionary:
	var response = yield(send_request("time", {game_id = gameID}), "completed")
	if utc:
		return OS.get_datetime_from_unix_time(response.timestamp)
	else:
		# Bias the time stamp according to time zone.
		# Godot's time zone bias is in minutes and UNIX time stamp is counted in seconds, so we have to multiply the bias by 60 to convert it from minutes to seconds.
		return OS.get_datetime_from_unix_time(response.timestamp + (OS.get_time_zone_info().bias * 60))

func send_request(endpoint: String, queries := {}) -> Dictionary:
	# Any double slashes after HTTP:// can ruin the signature.
	var url = "https://" + ("%s/%s/%s" % [baseURL, version, endpoint]).replace("//", "/")

	# Add queries.
	url += "?"
	for key in queries.keys():
		url += "&%s=%s" % [key, queries[key]]
	url += "&signature=" + (url + gameKey).md5_text() # Add signature.
	
	var http = HTTPRequest.new()
	add_child(http)

	# THE superior way to make HTTP requests.
	http.request(url)
	var http_response = yield(http, "request_completed")
	remove_child(http)

	# Get the body of the HTTP response and parse it as JSON.
	var body = JSON.parse(http_response[3].get_string_from_utf8()).result
	var api_response = body.response

	if api_response.success == "false": push_error(api_response.message)
	return api_response
