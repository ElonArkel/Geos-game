extends CharacterBody2D
## Aprendiz do Instituto Geos: movimento de plataforma, Scan e interação.
## Todos os números abaixo aparecem no Inspetor; ajuste até ficar gostoso de jogar.

@export var speed: float = 220.0
@export var acceleration: float = 1500.0
@export var friction: float = 1800.0
@export var jump_velocity: float = -440.0
@export var gravity: float = 1300.0
@export var max_fall_speed: float = 700.0
@export var coyote_time: float = 0.1        # pulo permitido logo após sair da borda
@export var jump_buffer_time: float = 0.12  # pulo "guardado" um instante antes de pousar
@export var jump_cut_multiplier: float = 0.5
@export var updraft_speed: float = 260.0
@export var scan_cost: float = 2.0

var updraft_count: int = 0   # mexido pelas zonas de corrente de ar
var input_locked: bool = false

var _coyote_timer: float = 0.0
var _jump_buffer_timer: float = 0.0
var _scan_cooldown: float = 0.0

@onready var visual: Node2D = $Visual
@onready var scan_area: Area2D = $ScanArea
@onready var interact_area: Area2D = $InteractArea


func _ready() -> void:
	add_to_group("player")


func _physics_process(delta: float) -> void:
	var dir := 0.0
	if not input_locked:
		dir = Input.get_axis("move_left", "move_right")

	# Gravidade ou corrente de ar
	if updraft_count > 0:
		velocity.y = move_toward(velocity.y, -updraft_speed, 1600.0 * delta)
	elif not is_on_floor():
		velocity.y = minf(velocity.y + gravity * delta, max_fall_speed)

	# Pulo com coyote time e buffer
	if is_on_floor():
		_coyote_timer = coyote_time
	else:
		_coyote_timer -= delta

	if not input_locked and Input.is_action_just_pressed("jump"):
		_jump_buffer_timer = jump_buffer_time
	else:
		_jump_buffer_timer -= delta

	if _jump_buffer_timer > 0.0 and _coyote_timer > 0.0:
		velocity.y = jump_velocity
		_jump_buffer_timer = 0.0
		_coyote_timer = 0.0

	# Soltar o botão cedo = pulo mais baixo
	if Input.is_action_just_released("jump") and velocity.y < 0.0 and updraft_count == 0:
		velocity.y *= jump_cut_multiplier

	# Horizontal
	if dir != 0.0:
		velocity.x = move_toward(velocity.x, dir * speed, acceleration * delta)
		visual.scale.x = signf(dir)
	else:
		velocity.x = move_toward(velocity.x, 0.0, friction * delta)

	move_and_slide()
	_scan_cooldown -= delta


func _unhandled_input(event: InputEvent) -> void:
	if input_locked:
		return
	if event.is_action_pressed("scan"):
		_do_scan()
	elif event.is_action_pressed("interact"):
		_do_interact()


func respawn(pos: Vector2) -> void:
	global_position = pos
	velocity = Vector2.ZERO
	updraft_count = 0


func _do_scan() -> void:
	if _scan_cooldown > 0.0:
		return
	_scan_cooldown = 0.4
	var target := _closest(scan_area, "get_scan_info")
	if target == null:
		GameState.scan_performed.emit("Scan", "Nada para analisar por perto. Aproxime-se de um material ou objeto.")
		return
	GameState.drain_energy(scan_cost)
	var info: Dictionary = target.get_scan_info()
	GameState.scan_performed.emit(info.get("title", "Desconhecido"), info.get("body", ""))


func _do_interact() -> void:
	var target := _closest(interact_area, "interact")
	if target != null:
		target.interact(self)


func _closest(area: Area2D, method: String) -> Area2D:
	var best: Area2D = null
	var best_dist := INF
	for a in area.get_overlapping_areas():
		if not a.has_method(method):
			continue
		var pos: Vector2 = a.get_scan_anchor() if a.has_method("get_scan_anchor") else a.global_position
		var d := global_position.distance_to(pos)
		if d < best_dist:
			best = a
			best_dist = d
	return best
