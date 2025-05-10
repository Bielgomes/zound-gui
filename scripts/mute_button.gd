extends Button

signal on_mute_change()

@onready var headphone_icon := preload("res://icons/headphones.svg") as Texture2D
@onready var headphone_off_icon := preload("res://icons/headphone-off.svg") as Texture2D

var is_muted := false


func set_is_muted(input_muted: bool):
	is_muted = input_muted
	icon = headphone_off_icon if is_muted else headphone_icon
	
	on_mute_change.emit()


func _on_pressed() -> void:
	set_is_muted(!is_muted)
