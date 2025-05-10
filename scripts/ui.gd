extends Control

signal loading_done()

@onready var context_menu := %ContextMenu
@onready var sounds_container := %SoundsContainer
@onready var header := %Header

var sound_scene = preload("res://scenes/sound_button.tscn")


func search_sound(id: int):
	var found_sounds = sounds_container.get_children().filter(func(sound): return sound.sound_data and sound.sound_data.id == id)
	if found_sounds:
		return found_sounds[0]

	return null


func _on_controller_event_received(event: Variant) -> void:
	match event.type:
		"CONFIG:FETCHED":
			header.init_config(event.config)
		"SOUND:FETCHED":
			for sound in event.sounds:
				var added_sound = sound_scene.instantiate()

				var sound_data = SoundResource.new()
				sound_data.id = sound.id
				sound_data.name = sound.name
				sound_data.path = sound.path
				sound_data.is_valid = sound.is_valid
				sound_data.created_at = sound.created_at

				added_sound.sound_data = sound_data
				context_menu._connect(added_sound)
				sounds_container.add_child(added_sound)

			sounds_container.move_child(sounds_container.get_children()[0], sounds_container.get_child_count())
			loading_done.emit()
		"SOUND:UPDATED":
			var updated_sound = search_sound(event.sound.id)
			if updated_sound:
				var sound_data = updated_sound.sound_data
				sound_data.id = event.sound.id
				sound_data.name = event.sound.name
				sound_data.path = event.sound.path
				sound_data.is_valid = event.sound.is_valid
				sound_data.created_at = event.sound.created_at

				updated_sound.update()
		"SOUND:ADDED":
			var added_sound = sound_scene.instantiate()

			var sound_data = SoundResource.new()
			sound_data.id = event.sound.id
			sound_data.name = event.sound.name
			sound_data.path = event.sound.path
			sound_data.is_valid = event.sound.is_valid
			sound_data.created_at = event.sound.created_at

			added_sound.sound_data = sound_data
			context_menu._connect(added_sound)

			var last_child = sounds_container.get_children()[-1]
			sounds_container.add_child(added_sound)
			sounds_container.move_child(last_child, sounds_container.get_child_count())
		"SOUND:REMOVED":
			var sound_to_remove = search_sound(event.soundId)
			if sound_to_remove:
				sounds_container.remove_child(sound_to_remove)
		"SOUND:PLAYING":
			var playing_sound = search_sound(event.soundId)
			if playing_sound:
				playing_sound.start_playing()
		"SOUND:STOPPED":
			var stopped_sound = search_sound(event.soundId)
			if stopped_sound:
				stopped_sound.stop_playing()
