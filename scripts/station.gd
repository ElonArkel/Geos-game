extends Area2D
## Estação de reparo da Cápsula Exploradora. Aperte E perto dela para construir componentes.

@export var station_name: String = "Cápsula Exploradora"


func _ready() -> void:
	collision_layer = 4
	collision_mask = 0
	var shape := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = Vector2(64, 64)
	shape.shape = rect
	add_child(shape)
	if not has_node("Visual"):
		var v := Polygon2D.new()
		v.name = "Visual"
		v.color = Color(0.3, 0.6, 0.9)
		v.polygon = PackedVector2Array([Vector2(-32, -32), Vector2(32, -32), Vector2(32, 32), Vector2(-32, 32)])
		add_child(v)
	var label := Label.new()
	label.text = "[E]"
	label.position = Vector2(-12, -58)
	add_child(label)


func interact(_player: Node) -> void:
	var hud := get_tree().get_first_node_in_group("hud")
	if hud:
		hud.open_crafting()


func get_scan_info() -> Dictionary:
	return {"title": station_name,
		"body": "Bancada de reparo da cápsula. Aqui você transforma materiais coletados em componentes."}
