extends Panel

@onready var label := $VBoxContainer/Label
@onready var dots := $VBoxContainer/Dots

@onready var timer := $DotTimer


func _ready() -> void:
	visible = true


func _on_ui_loading_done() -> void:
	queue_free()


func _on_controller_loading_progress(event: Variant) -> void:
	dots.text = ""
	match event:
		Constants.LoadingEvents.Setup:
			label.text = "Setting up the server"
		Constants.LoadingEvents.Start:
			label.text = "Establishing a connection"
		Constants.LoadingEvents.FetchInitialInformation:
			label.text = "Fetching initial information"


func _on_dot_timer_timeout() -> void:
	dots.text = dots.text + "."
