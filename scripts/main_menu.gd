extends Control


func _ready() -> void:
	RenderingServer.set_default_clear_color(Color(0.05, 0.07, 0.12))
	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(center)

	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 16)
	center.add_child(box)

	var title := Label.new()
	title.text = "GEOS"
	title.add_theme_font_size_override("font_size", 72)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(title)

	var sub := Label.new()
	sub.text = "Do núcleo à exosfera"
	sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(sub)

	var play := Button.new()
	play.text = "Jogar"
	play.pressed.connect(_on_play_pressed)
	box.add_child(play)

	var quit := Button.new()
	quit.text = "Sair"
	quit.pressed.connect(get_tree().quit)
	box.add_child(quit)

	var help := Label.new()
	help.text = "A/D ou setas: mover   |   Espaço: pular   |   E: interagir   |   Q: Scan"
	help.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(help)

	play.grab_focus.call_deferred()


func _on_play_pressed() -> void:
	GameState.reset_game()
	get_tree().change_scene_to_file(GameState.LEVEL_PATH % 1)
