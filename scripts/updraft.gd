@tool
extends Area2D
## Corrente de ar (ou de convecção): empurra o jogador para cima.

@export var size: Vector2 = Vector2(100, 300): set = _set_size
@export var color: Color = Color(0.4, 0.8, 1.0, 0.25): set = _set_color
@export var updraft_name: String = "Corrente ascendente"
@export_multiline var scan_text: String = "Fluxo de material que sobe. Pode carregar o jogador para cima."

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
		body_entered.connect(_on_body_entered)
		body_exited.connect(_on_body_exited)


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


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		body.updraft_count += 1


func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		body.updraft_count = maxi(0, body.updraft_count - 1)


func get_scan_anchor() -> Vector2:
	return global_position + size / 2.0


func get_scan_info() -> Dictionary:
	return {"title": updraft_name, "body": scan_text}
