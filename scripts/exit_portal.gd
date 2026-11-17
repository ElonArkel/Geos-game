extends Area2D
## Passagem para a próxima camada. Pode exigir um componente construído.

@export var required_component: String = ""   # ex.: "isolante_termico"


func _ready() -> void:
	collision_layer = 4
	collision_mask = 2
	var shape := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = Vector2(48, 80)
	shape.shape = rect
	add_child(shape)
	if not has_node("Visual"):
		var v := Polygon2D.new()
		v.name = "Visual"
		v.color = Color(0.4, 1.0, 0.8, 0.5)
		v.polygon = PackedVector2Array([Vector2(-24, -40), Vector2(24, -40), Vector2(24, 40), Vector2(-24, 40)])
		add_child(v)
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return
	if required_component != "" and not GameState.has_component(required_component):
		var need: String = GameState.RECIPES[required_component]["name"]
		GameState.post_message("Passagem bloqueada. Falta construir: %s" % need)
		return
	GameState.go_to_next_layer()


func get_scan_info() -> Dictionary:
	var body := "Passagem para a próxima camada."
	if required_component != "":
		body += "\nExige: %s." % GameState.RECIPES[required_component]["name"]
	return {"title": "Passagem", "body": body}
