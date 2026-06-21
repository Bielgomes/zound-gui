extends LineEdit

func _unhandled_key_input(event: InputEvent) -> void:
	if not self.has_focus():
		return

	if event is InputEventKey and event.pressed and not event.is_echo():
		var key_text = OS.get_keycode_string(event.keycode).to_lower()

		if key_text.length() > 1:
			key_text = "<" + key_text + ">"

		var mods = event.get_modifiers_mask()
		var mods_text = ""

		if mods & KEY_MASK_CTRL:
			mods_text += "<ctrl>+"
		if mods & KEY_MASK_SHIFT:
			mods_text += "<shift>+"
		if mods & KEY_MASK_ALT:
			mods_text += "<alt>+"
		if mods & KEY_MASK_META:
			mods_text += "<meta>+"

		var hotkey_string = mods_text + key_text
		self.text = hotkey_to_str(hotkey_string)


func _on_trash_button_up() -> void:
	self.text = ""


func hotkey_to_str(hotkey):
	return hotkey.replace("<", "").replace(">", "")


func str_to_hotkey(string: String) -> String:
	var hotkey = ""
	var is_first = true

	for slice in string.split("+"):
		if is_first == false:
			hotkey += "+"
		else:
			is_first = false

		if len(slice) > 1:
			hotkey += "<%s>" % slice
			continue

		hotkey += slice

	return hotkey

func get_hotkey() -> String:
	return str_to_hotkey(text)
