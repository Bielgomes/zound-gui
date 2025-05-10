extends Control

@onready var tween := create_tween()
@onready var panel := $Panel
@onready var label := $Panel/MarginContainer/Label
@onready var audio_select := $AudioSelect

var controller: Node2D
var stylebox: StyleBoxFlat

var normal_border_color = Color("#3f3f46")
var hover_border_color = Color("#a1a1aa")

var border_color: Color = normal_border_color

var is_playing: bool = false
var is_hover: bool = false
var is_file_select_open: bool = false

var sound_data: SoundResource = null


func _ready() -> void:
	controller = get_parent().get_node("%Controller")

	stylebox = panel.get_theme_stylebox("panel").duplicate()
	panel.add_theme_stylebox_override("panel", stylebox)

	is_file_select_open = false


func _process(_delta) -> void:
	stylebox.border_color = border_color
	label.add_theme_color_override("font_color", border_color)


func _input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_released():
		if is_hover and not is_file_select_open:
			audio_select.visible = true
			is_file_select_open = true


func _on_panel_mouse_entered() -> void:
	if not is_playing:
		is_hover = true
		animate_style_tween(hover_border_color)


func _on_panel_mouse_exited() -> void:
	if not is_playing and is_hover:
		is_hover = false
		animate_style_tween(normal_border_color)


func animate_style_tween(new_color: Color) -> void:
	tween.kill()
	tween = create_tween()
	tween.tween_property(self, "border_color", new_color, 0.1)


func _on_audio_select_canceled() -> void:
	is_file_select_open = false


func _on_audio_select_files_selected(paths: PackedStringArray) -> void:
	for path in paths:
		name = path.split("\\")[-1].split(".")[0]
		name = name.replace("-", " ").replace("_", " ")

		controller.send_event(JSON.stringify({
			"type": Constants.OutgoingEvent["SOUND_ADD"],
			"data": {
				"name": name,
				"path": path
			}
		}))

	is_file_select_open = false
