@tool
extends StaticBody2D
## Plataforma retangular. Ajuste "size" no Inspetor; a origem é o canto superior esquerdo.
## Para usar sprite: adicione um filho Sprite2D/TileMapLayer e desligue "show_placeholder".

@export var size: Vector2 = Vector2(128, 32): set = _set_size
@export var color: Color = Color(0.35, 0.25, 0.2): set = _set_color
@export var one_way: bool = false: set = _set_one_way
@export var show_placeholder: bool = true: set = _set_show

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


func _set_size(v: Vector2) -> void:
	size = v
	_refresh()


func _set_color(v: Color) -> void:
	color = v
	_refresh()


func _set_one_way(v: bool) -> void:
	one_way = v
	_refresh()


func _set_show(v: bool) -> void:
	show_placeholder = v
	_refresh()


func _refresh() -> void:
	if _shape == null:
		return
	(_shape.shape as RectangleShape2D).size = size
	_shape.position = size / 2.0
	_shape.one_way_collision = one_way
	_rect.position = Vector2.ZERO
	_rect.size = size
	_rect.color = color
	_rect.visible = show_placeholder
