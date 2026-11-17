extends Area2D
## Material coletável. Troque "material_id" no Inspetor (ferro, niquel, silicato, basalto, quartzo).
## Para usar sprite: adicione um filho chamado "Visual" (Sprite2D) na cena e o placeholder some.

@export var material_id: String = "ferro"
@export var amount: int = 1


func _ready() -> void:
	collision_layer = 4
	collision_mask = 2
	var shape := CollisionShape2D.new()
	var circle := CircleShape2D.new()
	circle.radius = 14.0
	shape.shape = circle
	add_child(shape)
	if not has_node("Visual"):
		var v := Polygon2D.new()
		v.name = "Visual"
		v.color = GameState.MATERIALS[material_id]["color"]
		v.polygon = PackedVector2Array([Vector2(0, -12), Vector2(10, 0), Vector2(0, 12), Vector2(-10, 0)])
		add_child(v)
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return
	GameState.add_item(material_id, amount)
	GameState.post_message("Coletado: %s x%d" % [GameState.MATERIALS[material_id]["name"], amount])
	queue_free()


func get_scan_info() -> Dictionary:
	var m: Dictionary = GameState.MATERIALS[material_id]
	return {"title": m["name"], "body": m["info"]}
