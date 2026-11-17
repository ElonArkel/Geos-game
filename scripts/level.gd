extends Node2D
## Script base de toda fase. Para criar uma fase nova: duplique level_02.tscn,
## mude layer_index e monte o cenário.

const HUD_SCENE := preload("res://scenes/hud.tscn")

@export var layer_index: int = 0           # 0 = núcleo interno ... 9 = exosfera
@export var kill_y: float = 900.0          # abaixo disso o jogador "caiu"
@export var bg_color: Color = Color(0.12, 0.05, 0.05)
@export var limit_left: int = 0
@export var limit_right: int = 2000
@export var limit_top: int = -200
@export var limit_bottom: int = 720

@onready var player: CharacterBody2D = $Player
@onready var player_start: Marker2D = $PlayerStart


func _ready() -> void:
	RenderingServer.set_default_clear_color(bg_color)
	GameState.layer_index = layer_index
	GameState.checkpoint = player_start.global_position
	player.respawn(GameState.checkpoint)

	var cam: Camera2D = player.get_node("Camera2D")
	cam.limit_left = limit_left
	cam.limit_right = limit_right
	cam.limit_top = limit_top
	cam.limit_bottom = limit_bottom

	GameState.player_died.connect(_on_player_died)

	if get_tree().get_first_node_in_group("hud") == null:
		add_child(HUD_SCENE.instantiate())

	var layer: Dictionary = GameState.LAYERS[layer_index]
	GameState.post_message("Camada: %s" % layer["name"])


func _physics_process(_delta: float) -> void:
	if player.global_position.y > kill_y:
		GameState.drain_energy(15.0)  # cair custa energia
		player.respawn(GameState.checkpoint)


func _on_player_died() -> void:
	GameState.respawn_energy()
	player.respawn(GameState.checkpoint)
