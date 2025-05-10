extends Control

signal context_menu_requested(sound_button: Node)

@onready var tween := create_tween()
@onready var panel := $Panel
@onready var container := $Panel/MarginContainer
@onready var label := $Panel/MarginContainer/Label
@onready var is_invalid_button := $Panel/IsInvalid

var normal_border_color = Color("#3f3f46")
var hover_border_color = Color("#a1a1aa")
var playing_border_color = Color("#16a34a")

var border_color: Color = normal_border_color
var border_width_bottom: int = 20

var is_playing: bool = false
var is_hover: bool = false

var stylebox: StyleBoxFlat
var controller: Node2D

var sound_data: SoundResource


func update():
	label.text = sound_data.name
	panel.tooltip_text = "Play: " + sound_data.name
	is_invalid_button.visible = not sound_data.is_valid


func _ready() -> void:
	controller = get_parent().get_node("%Controller")

	stylebox = panel.get_theme_stylebox("panel").duplicate()
	panel.add_theme_stylebox_override("panel", stylebox)

	label.text = sound_data.name
	panel.tooltip_text = "Play: " + sound_data.name
	is_invalid_button.visible = not sound_data.is_valid


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and is_hover:
		if event.button_index == MOUSE_BUTTON_LEFT and event.is_released():
			controller.send_event(JSON.stringify({
				"type": Constants.OutgoingEvent["SOUND_PLAY"],
				"soundId": sound_data.id
			}))
		elif event.button_index == MOUSE_BUTTON_RIGHT and event.is_released():
			var mouse_pos = Rect2(get_global_mouse_position().x, get_global_mouse_position().y, 150, 0)
			context_menu_requested.emit(self, mouse_pos)


func _on_panel_mouse_entered() -> void:
	if not is_playing:
		animate_style(hover_border_color, 10, 139)

	is_hover = true


func _on_panel_mouse_exited() -> void:
	if not is_playing and is_hover:
		animate_style(normal_border_color, 20, 125)

	is_hover = false


func start_playing():
	is_playing = true
	animate_style(playing_border_color, 10, 139)


func stop_playing():
	is_playing = false
	animate_style(normal_border_color, 20, 125)


func animate_style(new_color: Color, new_width: int, container_size: int) -> void:
	tween.kill()
	tween = create_tween()

	tween.tween_property(stylebox, "border_color", new_color, 0.15).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(stylebox, "border_width_bottom", new_width, 0.15).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

	tween.tween_property(container, "size:y", container_size, 0.15).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT).set_delay(0.05)
