extends Control

@onready var confirm_button := $MarginContainer/Body/MarginContainer/VBoxContainer/Footer/Confirm
@onready var cancel_button := $MarginContainer/Body/MarginContainer/VBoxContainer/Footer/Cancel

@onready var name_input := $MarginContainer/Body/MarginContainer/VBoxContainer/Fields/Name/Input
@onready var name_error_label := $MarginContainer/Body/MarginContainer/VBoxContainer/Fields/Name/ErrorLabel

@onready var path_input := $MarginContainer/Body/MarginContainer/VBoxContainer/Fields/Path/HBoxContainer/Input
@onready var path_error_label := $MarginContainer/Body/MarginContainer/VBoxContainer/Fields/Path/ErrorLabel

@onready var audio_select := $AudioSelect

var sound_data: SoundResource = SoundResource.new()
var there_is_an_error: bool = false
var is_sound_select_open: bool = false


func open(sound: SoundResource):
	sound_data = sound
	name_input.text = sound_data.name
	path_input.text = sound_data.path

	visible = true
	validate_inputs()


func validate_inputs():
	_on_name_field_text_changed(name_input.text)
	_on_input_text_changed(path_input.text)


func close():
	sound_data = null

	there_is_an_error = false
	visible = false

	name_error_label.text = ""
	path_error_label.text = ""

	on_form_state_change()


func on_form_state_change():
	confirm_button.disabled = there_is_an_error
	confirm_button.set_default_cursor_shape(Input.CURSOR_FORBIDDEN if there_is_an_error else Input.CURSOR_POINTING_HAND)
	confirm_button.focus_mode = 0 if there_is_an_error else 2


func _input(_event: InputEvent) -> void:
	pass

	#if not visible:
		#return

	#if event.is_action_released("Escape"):
		#close()


func _on_name_field_text_changed(name_: String) -> void:
	if len(name_) < 3 or len(name_) > 255:
		name_error_label.text = "The name must have 3 or more characters"
		there_is_an_error = true
		on_form_state_change()
		return

	name_error_label.text = ""
	there_is_an_error = false
	on_form_state_change()


func _on_input_text_changed(path: String) -> void:
	if not path.is_absolute_path():
		path_error_label.text = "This path is not valid"
		there_is_an_error = true
		on_form_state_change()
		return

	if path.get_extension() not in ["mp3", "wav"]:
		path_error_label.text = "Invalid sound type"
		there_is_an_error = true
		on_form_state_change()
		return

	if not FileAccess.file_exists(path):
		path_error_label.text = "Sound not found in this path"
		there_is_an_error = true
		on_form_state_change()
		return

	path_error_label.text = ""
	there_is_an_error = false
	on_form_state_change()


func _on_cancel_pressed() -> void:
	if not is_sound_select_open:
		close()


func _on_audio_select_canceled() -> void:
	is_sound_select_open = false


func _on_audio_select_file_selected(path: String) -> void:
	path_input.text = path
	is_sound_select_open = false
	on_form_state_change()


func _on_select_file_pressed() -> void:
	if not is_sound_select_open:
		audio_select.visible = true
		is_sound_select_open = true


func _on_confirm_pressed() -> void:
	if not there_is_an_error:
		%Controller.send_event(JSON.stringify({
			"type": Constants.OutgoingEvent["SOUND_UPDATE"],
			"data": {
				id = sound_data.id,
				name = name_input.text,
				path = path_input.text
			}
		}))
		close()
