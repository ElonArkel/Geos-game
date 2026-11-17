extends CanvasLayer
## Interface: energia, materiais, painel do Scan, mensagens e bancada de construção.
## Tudo é montado por código, então não precisa mexer em nós de UI para começar.

var _energy_bar: ProgressBar
var _layer_label: Label
var _inventory_label: Label
var _message_label: Label
var _scan_panel: PanelContainer
var _scan_title: Label
var _scan_body: Label
var _craft_panel: PanelContainer
var _craft_list: VBoxContainer
var _message_timer: Timer
var _scan_timer: Timer


func _ready() -> void:
	add_to_group("hud")
	process_mode = Node.PROCESS_MODE_ALWAYS  # funciona mesmo com o jogo pausado
	_build_ui()
	GameState.energy_changed.connect(_on_energy_changed)
	GameState.inventory_changed.connect(_refresh_inventory)
	GameState.message_posted.connect(_show_message)
	GameState.scan_performed.connect(_show_scan)
	_on_energy_changed(GameState.energy, GameState.MAX_ENERGY)
	_refresh_inventory()
	var layer: Dictionary = GameState.LAYERS[GameState.layer_index]
	_layer_label.text = "%s  (%s)" % [layer["name"], layer["depth"]]


func _build_ui() -> void:
	var root := Control.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(root)

	# Canto superior esquerdo
	var top := VBoxContainer.new()
	top.position = Vector2(16, 12)
	root.add_child(top)
	_layer_label = Label.new()
	top.add_child(_layer_label)
	_energy_bar = ProgressBar.new()
	_energy_bar.custom_minimum_size = Vector2(260, 22)
	_energy_bar.max_value = GameState.MAX_ENERGY
	top.add_child(_energy_bar)
	_inventory_label = Label.new()
	top.add_child(_inventory_label)

	# Mensagens (topo central)
	_message_label = Label.new()
	_message_label.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
	_message_label.offset_top = 12
	_message_label.offset_bottom = 44
	_message_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_message_label.visible = false
	root.add_child(_message_label)
	_message_timer = Timer.new()
	_message_timer.one_shot = true
	_message_timer.wait_time = 3.0
	_message_timer.timeout.connect(func(): _message_label.visible = false)
	add_child(_message_timer)

	# Painel do Scan (parte de baixo)
	_scan_panel = PanelContainer.new()
	_scan_panel.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
	_scan_panel.offset_left = 40
	_scan_panel.offset_right = -40
	_scan_panel.offset_top = -130
	_scan_panel.offset_bottom = -16
	_scan_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_scan_panel.visible = false
	root.add_child(_scan_panel)
	var scan_box := VBoxContainer.new()
	_scan_panel.add_child(_wrap_margin(scan_box))
	_scan_title = Label.new()
	_scan_title.add_theme_font_size_override("font_size", 20)
	scan_box.add_child(_scan_title)
	_scan_body = Label.new()
	_scan_body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_scan_body.custom_minimum_size = Vector2(600, 0)
	scan_box.add_child(_scan_body)
	_scan_timer = Timer.new()
	_scan_timer.one_shot = true
	_scan_timer.wait_time = 8.0
	_scan_timer.timeout.connect(func(): _scan_panel.visible = false)
	add_child(_scan_timer)

	# Painel de construção (centro)
	_craft_panel = PanelContainer.new()
	_craft_panel.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	_craft_panel.grow_horizontal = Control.GROW_DIRECTION_BOTH
	_craft_panel.grow_vertical = Control.GROW_DIRECTION_BOTH
	_craft_panel.custom_minimum_size = Vector2(560, 0)
	_craft_panel.visible = false
	root.add_child(_craft_panel)
	_craft_list = VBoxContainer.new()
	_craft_list.add_theme_constant_override("separation", 8)
	_craft_panel.add_child(_wrap_margin(_craft_list))


func _wrap_margin(child: Control) -> MarginContainer:
	var m := MarginContainer.new()
	for side in ["margin_left", "margin_right", "margin_top", "margin_bottom"]:
		m.add_theme_constant_override(side, 12)
	m.add_child(child)
	return m


func _on_energy_changed(current: float, _maximum: float) -> void:
	_energy_bar.value = current


func _refresh_inventory() -> void:
	var mats: PackedStringArray = []
	for id in GameState.inventory:
		if GameState.inventory[id] > 0:
			mats.append("%s x%d" % [GameState.MATERIALS[id]["name"], GameState.inventory[id]])
	var comps: PackedStringArray = []
	for id in GameState.components:
		comps.append(GameState.RECIPES[id]["name"])
	_inventory_label.text = "Materiais: %s\nComponentes: %s" % [
		", ".join(mats) if mats.size() > 0 else "-",
		", ".join(comps) if comps.size() > 0 else "-"]


func _show_message(text: String) -> void:
	_message_label.text = text
	_message_label.visible = true
	_message_timer.start()


func _show_scan(title: String, body: String) -> void:
	_scan_title.text = "Scan: " + title
	_scan_body.text = body
	_scan_panel.visible = true
	_scan_timer.start()


# --- Construção de componentes ---
func open_crafting() -> void:
	_rebuild_crafting()
	_craft_panel.visible = true
	get_tree().paused = true


func close_crafting() -> void:
	_craft_panel.visible = false
	get_tree().paused = false


func _unhandled_input(event: InputEvent) -> void:
	if _craft_panel.visible and event.is_action_pressed("ui_cancel"):
		close_crafting()
		get_viewport().set_input_as_handled()


func _rebuild_crafting() -> void:
	for c in _craft_list.get_children():
		_craft_list.remove_child(c)
		c.queue_free()

	var title := Label.new()
	title.text = "Bancada da Cápsula Exploradora"
	title.add_theme_font_size_override("font_size", 22)
	_craft_list.add_child(title)

	for id in GameState.RECIPES:
		var r: Dictionary = GameState.RECIPES[id]
		var done := GameState.has_component(id)
		var btn := Button.new()
		btn.text = "%s  -  %s%s" % [r["name"], _cost_text(r["cost"]), "   (construído)" if done else ""]
		btn.disabled = not GameState.can_craft(id)
		btn.pressed.connect(_on_craft_pressed.bind(id))
		_craft_list.add_child(btn)
		var desc := Label.new()
		desc.text = r["desc"]
		desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		desc.modulate = Color(1, 1, 1, 0.7)
		_craft_list.add_child(desc)

	var close := Button.new()
	close.text = "Fechar (Esc)"
	close.pressed.connect(close_crafting)
	_craft_list.add_child(close)
	_craft_panel.reset_size()


func _cost_text(cost: Dictionary) -> String:
	var parts: PackedStringArray = []
	for id in cost:
		parts.append("%s x%d" % [GameState.MATERIALS[id]["name"], cost[id]])
	return ", ".join(parts)


func _on_craft_pressed(id: String) -> void:
	GameState.craft(id)
	_rebuild_crafting()
