extends Node2D

signal event_received(event: Variant)

signal loading_progress(event: Constants.LoadingEvents)

var thread: Thread
var websocket: WebSocketPeer = WebSocketPeer.new()
var initial_fetch = true
var server_pid: int = -1


func get_server_path():
	if OS.has_feature("editor"):
		return ProjectSettings.globalize_path("res://%s" % "server/")

	return OS.get_executable_path().get_base_dir()


func _ready() -> void:
	set_process(false)
	var server_path = get_server_path()

	thread = Thread.new()
	thread.start(_setup_n_start.bind(server_path))


func _setup_n_start(path):
	loading_progress.emit(Constants.LoadingEvents.Start)
	server_pid = OS.create_process(path.path_join("server.exe"), [])

	if server_pid == -1:
		print("❌ Failed to start server.")

	websocket.connect_to_url("ws://localhost:4358")
	call_deferred("set_process", true)


func _exit_tree() -> void:
	websocket.close()

	if server_pid != -1:
		print("Stopping server.exe (PID: %d)..." % server_pid)
		OS.kill(server_pid)

	if thread and thread.is_started():
		thread.wait_to_finish()


func _process(_delta: float) -> void:
	websocket.poll()
	var state = websocket.get_ready_state()

	match state:
		WebSocketPeer.STATE_OPEN:
			if initial_fetch:
				loading_progress.emit(Constants.LoadingEvents.FetchInitialInformation)
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
