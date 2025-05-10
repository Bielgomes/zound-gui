extends Node2D

signal event_received(event: Variant)

signal loading_progress(event: Constants.LoadingEvents)

var thread: Thread
var websocket: WebSocketPeer = WebSocketPeer.new()
var initial_fetch = true


func get_server_path(path: String):
	if OS.has_feature("editor"):
		return ProjectSettings.globalize_path("res://%s" % path)

	return OS.get_executable_path().get_base_dir().path_join(path)


func _ready() -> void:
	set_process(false)
	var server_path = get_server_path("server/")

	thread = Thread.new()
	thread.start(_setup_n_start.bind(server_path))


func _setup_n_start(path):
	call_deferred("emit_signal", "loading_progress", Constants.LoadingEvents.Setup)
	OS.execute(path.path_join("setup.bat"), [])

	call_deferred("emit_signal", "loading_progress", Constants.LoadingEvents.Start)
	OS.create_process(path.path_join("run.bat"), [])

	websocket.connect_to_url("ws://localhost:4358")
	call_deferred("set_process", true)


func _exit_tree() -> void:
	thread.wait_to_finish()
	websocket.close()


func _process(_delta: float) -> void:
	websocket.poll()
	var state = websocket.get_ready_state()

	match state:
		WebSocketPeer.STATE_OPEN:
			if initial_fetch:
				call_deferred("emit_signal", "loading_progress", Constants.LoadingEvents.FetchInitialInformation)
				websocket.send_text(JSON.stringify({
					"type": Constants.OutgoingEvent["CONFIG_FETCH"]
				}))
				websocket.send_text(JSON.stringify({
					"type": Constants.OutgoingEvent["SOUND_FETCH"]
				}))
				initial_fetch = false

			while websocket.get_available_packet_count():
				var packet = websocket.get_packet().get_string_from_utf8()
				var event = JSON.parse_string(packet)

				print("📫 Received event:", event)
				event_received.emit(event)
		WebSocketPeer.STATE_CLOSING:
			pass
		WebSocketPeer.STATE_CLOSED:
			var code = websocket.get_close_code()
			var reason = websocket.get_close_reason()

			print("❌ WebSocket closed with code: %d, reason %s. Clean: %s" % [code, reason, code != -1])
			set_process(false)


func send_event(event: Variant):
	websocket.send_text(event)
