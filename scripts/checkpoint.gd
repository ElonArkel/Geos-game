extends Area2D
## Ao tocar, define o ponto de retorno quando o jogador cai ou fica sem energia.

var _active := false


func _ready() -> void:
	collision_layer = 0
	collision_mask = 2
	var shape := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = Vector2(40, 80)
	shape.shape = rect
	add_child(shape)
	if not has_node("Visual"):
		var v := Polygon2D.new()
		v.name = "Visual"
		v.color = Color(1, 1, 0.4, 0.35)
		v.polygon = PackedVector2Array([Vector2(-4, -40), Vector2(4, -40), Vector2(4, 40), Vector2(-4, 40)])
		add_child(v)
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	if _active or not body.is_in_group("player"):
		return
	_active = true
	GameState.checkpoint = global_position
	GameState.post_message("Checkpoint salvo.")
