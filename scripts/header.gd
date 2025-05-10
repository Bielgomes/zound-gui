extends Panel

@onready var headphone_volume_slider := %HeadphoneVolume/HeadphoneVolumeSlider
@onready var headphone_volume_label := %HeadphoneVolume/Volume

@onready var microphone_volume_slider := %MicrophoneVolume/MicrophoneVolumeSlider
@onready var microphone_volume_label := %MicrophoneVolume/Volume

@onready var mute_button := %MuteButton

@onready var controller := %Controller

var headphone_volume: float = 0.5
var microphone_volume: float = 0.5


func init_config(config: Variant):
	headphone_volume = config.headphone_volume
	microphone_volume = config.microphone_volume
	mute_button.set_is_muted(config.headphone_muted)

	headphone_volume_slider.value = headphone_volume * 100
	microphone_volume_slider.value = microphone_volume * 100

	headphone_volume_label.text = str(headphone_volume_slider.value) + "%"
	microphone_volume_label.text = str(microphone_volume_slider.value) + "%"


func _on_output_slider_drag_ended(value_changed: bool) -> void:
	if value_changed:
		microphone_volume = microphone_volume_slider.value / 100
		on_change_event()


func _on_output_slider_value_changed(value: float) -> void:
	microphone_volume_label.text = str(value) + "%"


func _on_input_slider_drag_ended(value_changed: bool) -> void:
	if value_changed:
		headphone_volume = headphone_volume_slider.value / 100
		on_change_event()


func _on_input_slider_value_changed(value: float) -> void:
	headphone_volume_label.text = str(value) + "%"


func _on_mute_button_on_mute_change() -> void:
	on_change_event()


func _on_stop_button_pressed() -> void:
	controller.send_event(JSON.stringify({
		"type": Constants.OutgoingEvent["SOUND_STOP"]
	}))


func on_change_event():
	controller.send_event(JSON.stringify({
		"type": Constants.OutgoingEvent["CONFIG_UPDATE"],
		"config": {
			"headphone_volume": headphone_volume,
			"microphone_volume": microphone_volume,
			"headphone_muted": mute_button.is_muted,
		},
	}))
