extends Control

@onready var hotkey_input := $MarginContainer/Body/MarginContainer/VBoxContainer/Fields/Hotkey/HBoxContainer/Input
@onready var hotkey_input_error_label := $MarginContainer/Body/MarginContainer/VBoxContainer/Fields/Hotkey/ErrorLabel

@onready var confirm_button := $MarginContainer/Body/MarginContainer/VBoxContainer/Footer/Confirm

var sound_data: SoundResource
var there_is_an_error: bool = false


func open(sound: SoundResource):
	sound_data = sound
	hotkey_input.text = sound_data.hotkey.replace("<", "").replace(">", "")

	visible = true
	validate_inputs()


func validate_inputs():
	_on_input_text_changed(hotkey_input.text)


func close():
	sound_data = null

	hotkey_input.text = ""
	hotkey_input_error_label.text = ""

	there_is_an_error = false
	visible = false


func _on_cancel_button_up() -> void:
	close()


func _on_confirm_button_up() -> void:
	validate_inputs()
	if there_is_an_error:
		return

	%Controller.send_event(JSON.stringify({
		"type": Constants.OutgoingEvent["SOUND_UPDATE_HOTKEY"],
		"soundId": sound_data.id,
		"hotkey":  hotkey_input.get_hotkey() if hotkey_input.text != "" else null
	}))
	close()


func search_sound_with_hotkey(hotkey: String):
	var sounds = %SoundsContainer.get_children()
	var sound_index = %SoundsContainer.get_children().find_custom(func(sound): return sound.sound_data and sound.sound_data.hotkey == hotkey)
	if sound_index != -1:
		return sounds[sound_index]

	return null


func _on_input_text_changed(hotkey: String) -> void:
	if hotkey == "":
		there_is_an_error = false
		return

	hotkey = hotkey_input.str_to_hotkey(hotkey)

	var sound_with_same_hotkey = search_sound_with_hotkey(hotkey)
	if sound_with_same_hotkey and sound_with_same_hotkey.sound_data.id != sound_data.id:
		hotkey_input_error_label.text = "There is already a sound with this hotkey"
		there_is_an_error = true
		return

	there_is_an_error = false
