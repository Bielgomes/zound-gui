extends Panel

@onready var label := $VBoxContainer/Label
@onready var loading_icon := $VBoxContainer/LoadingIcon
@onready var warning := $VBoxContainer/Warning

var tween: Tween

func _ready() -> void:
	loading_icon.pivot_offset = Vector2(16, 16)

	tween = get_tree().create_tween().set_loops()
	tween.tween_property(loading_icon, "rotation", TAU, 1.0).as_relative().from(0.0)

	visible = true

func _on_ui_loading_done() -> void:
	queue_free()

func _on_controller_loading_progress(event: Variant) -> void:
	match event:
		Constants.LoadingEvents.Setup:
			label.text = "Setting up the server"
		Constants.LoadingEvents.Start:
			label.text = "Establishing a connection"
		Constants.LoadingEvents.FetchInitialInformation:
			label.text = "Fetching initial information"
		_:
			tween.delete()

func _on_dot_timer_timeout() -> void:
	warning.text = "Taking longer than usual"
