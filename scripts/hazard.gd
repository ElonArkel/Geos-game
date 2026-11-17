@tool
extends Area2D
## Zona perigosa (magma, calor, gás...). Drena energia enquanto o jogador está dentro.
## Se "required_ability" estiver preenchido e o jogador tiver a habilidade, não sofre dano.
## Habilidades: veja "ability" em RECIPES no game_state.gd (ex.: heat_resist).

@export var size: Vector2 = Vector2(128, 32): set = _set_size
@export var color: Color = Color(1.0, 0.3, 0.1, 0.55): set = _set_color
@export var damage_per_second: float = 25.0
@export var required_ability: String = ""
@export var hazard_name: String = "Magma"
@export_multiline var scan_text: String = "Rocha derretida. O contato drena a energia do traje."

var _shape: CollisionShape2D
var _rect: ColorRect


func _ready() -> void:
	_shape = CollisionShape2D.new()
	_shape.shape = RectangleShape2D.new()
	add_child(_shape)
	_rect = ColorRect.new()
	_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_rect)
	_refresh()
	if not Engine.is_editor_hint():
		collision_layer = 4
		collision_mask = 2


func _set_size(v: Vector2) -> void:
	size = v
	_refresh()


func _set_color(v: Color) -> void:
	color = v
	_refresh()


func _refresh() -> void:
	if _shape == null:
		return
	(_shape.shape as RectangleShape2D).size = size
	_shape.position = size / 2.0
	_rect.size = size
	_rect.color = color


func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	for body in get_overlapping_bodies():
		if not body.is_in_group("player"):
			continue
		if required_ability != "" and GameState.has_ability(required_ability):
			continue
		GameState.drain_energy(damage_per_second * delta)


func get_scan_anchor() -> Vector2:
	return global_position + size / 2.0


func get_scan_info() -> Dictionary:
	var text := scan_text
	if required_ability != "":
		text += "\nUm componente adequado na cápsula pode proteger o traje."
	return {"title": hazard_name, "body": text}
