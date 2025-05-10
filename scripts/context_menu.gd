extends PopupMenu

@onready var controller := %Controller

var sound_data: SoundResource


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		if visible and event.button_index == MOUSE_BUTTON_RIGHT:
			sound_data = null
			hide()


func _connect(sound_button: Node):
	sound_button.connect("context_menu_requested", Callable(self, "_on_context_menu_requested"))


func _on_context_menu_requested(sound_button: Node, mouse_position: Rect2i):
	sound_data = sound_button.sound_data
	popup(mouse_position)


func _on_id_pressed(id: int) -> void:
	if sound_data:
		match id:
			0:
				%Modal.open(sound_data)
			1:
				controller.send_event(JSON.stringify({
					"type": Constants.OutgoingEvent["SOUND_REMOVE"],
					"soundId": sound_data.id
				}))
