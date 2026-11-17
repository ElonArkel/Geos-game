extends Node
## Estado global do jogo (Autoload "GameState").
## Guarda energia, materiais, componentes construídos e dados educativos.

signal energy_changed(current: float, maximum: float)
signal inventory_changed
signal message_posted(text: String)
signal scan_performed(title: String, body: String)
signal player_died

const MAX_ENERGY := 100.0
const LEVEL_PATH := "res://scenes/levels/level_%02d.tscn"
const MENU_PATH := "res://scenes/main_menu.tscn"

# Camadas na ordem da jornada (índice 0 = núcleo interno).
# Cada fase usa layer_index para saber qual destas entradas mostrar.
# REVISE os textos com seu professor/orientador antes de publicar.
const LAYERS := [
	{"name": "Núcleo Interno", "depth": "5.150 a 6.371 km",
	 "info": "Esfera sólida de ferro e níquel. A temperatura passa de 5.000 °C, mas a pressão enorme impede o metal de derreter."},
	{"name": "Núcleo Externo", "depth": "2.900 a 5.150 km",
	 "info": "Ferro e níquel líquidos. O movimento desse metal gera o campo magnético da Terra."},
	{"name": "Manto Inferior", "depth": "cerca de 700 a 2.900 km",
	 "info": "Rocha muito quente e sob forte pressão, que flui lentamente por convecção."},
	{"name": "Manto Superior", "depth": "da crosta até cerca de 700 km",
	 "info": "Inclui a astenosfera, parte mais maleável sobre a qual as placas tectônicas se movem."},
	{"name": "Crosta", "depth": "5 a 70 km de espessura",
	 "info": "Camada sólida onde vivemos. A crosta oceânica é mais fina (basalto) e a continental é mais espessa (granito)."},
	{"name": "Troposfera", "depth": "0 a cerca de 12 km de altitude",
	 "info": "Concentra a maior parte do ar e quase todo o vapor d'água. É onde se formam nuvens e o clima."},
	{"name": "Estratosfera", "depth": "cerca de 12 a 50 km",
	 "info": "Abriga a camada de ozônio, que absorve boa parte da radiação ultravioleta do Sol."},
	{"name": "Mesosfera", "depth": "cerca de 50 a 85 km",
	 "info": "A camada mais fria da atmosfera. A maioria dos meteoros se desintegra aqui."},
	{"name": "Termosfera", "depth": "cerca de 85 a 600 km",
	 "info": "Ar muito rarefeito e temperaturas altíssimas. Aqui surgem as auroras e orbita a Estação Espacial."},
	{"name": "Exosfera", "depth": "acima de cerca de 600 km",
	 "info": "Última camada, de transição para o espaço. Os gases são tão raros que podem escapar da gravidade."},
]

# Materiais coletáveis. "color" é usado só no placeholder visual.
const MATERIALS := {
	"ferro": {"name": "Ferro", "color": Color(0.7, 0.7, 0.75),
		"info": "Metal pesado. Junto com o níquel forma a maior parte do núcleo da Terra."},
	"niquel": {"name": "Níquel", "color": Color(0.8, 0.85, 0.7),
		"info": "Metal que acompanha o ferro no núcleo. Conduz bem a eletricidade, ótimo para circuitos."},
	"silicato": {"name": "Silicato", "color": Color(0.9, 0.55, 0.3),
		"info": "Minerais de silício e oxigênio. Formam a maior parte do manto e da crosta."},
	"basalto": {"name": "Basalto", "color": Color(0.35, 0.35, 0.4),
		"info": "Rocha vulcânica escura, formada quando o magma esfria. Comum no fundo dos oceanos."},
	"quartzo": {"name": "Quartzo", "color": Color(0.85, 0.95, 1.0),
		"info": "Cristal de silício e oxigênio, comum na crosta. Usado em osciladores de rádio."},
}

# Componentes que o jogador constrói na cápsula.
# "ability" (opcional) é uma habilidade liberada ao construir.
const RECIPES := {
	"isolante_termico": {"name": "Isolante Térmico",
		"desc": "Revestimento do traje que resiste a calor extremo por um tempo.",
		"cost": {"ferro": 2, "niquel": 1}, "ability": "heat_resist"},
	"reforco_estrutural": {"name": "Reforço Estrutural",
		"desc": "Estrutura que ajuda a cápsula e o traje a suportar a pressão.",
		"cost": {"silicato": 2, "ferro": 1}, "ability": "pressure_resist"},
	"bobina_de_sinal": {"name": "Bobina de Sinal",
		"desc": "Parte eletrônica do transmissor de resgate.",
		"cost": {"niquel": 2, "quartzo": 1}},
	"antena_de_resgate": {"name": "Antena de Resgate",
		"desc": "Antena para enviar o sinal na exosfera.",
		"cost": {"basalto": 2, "quartzo": 2}},
}

var energy: float = MAX_ENERGY
var inventory: Dictionary = {}    # id do material -> quantidade
var components: Dictionary = {}   # id do componente -> true
var layer_index: int = 0
var checkpoint: Vector2 = Vector2.ZERO


func _ready() -> void:
	_setup_inputs()


# --- Entradas (criadas por código para o projeto funcionar sem configurar nada) ---
func _setup_inputs() -> void:
	_add_action("move_left", [KEY_A, KEY_LEFT])
	_add_action("move_right", [KEY_D, KEY_RIGHT])
	_add_action("jump", [KEY_SPACE, KEY_W, KEY_UP])
	_add_action("interact", [KEY_E])
	_add_action("scan", [KEY_Q])


func _add_action(action: StringName, keys: Array) -> void:
	if not InputMap.has_action(action):
		InputMap.add_action(action)
	for k in keys:
		var ev := InputEventKey.new()
		ev.physical_keycode = k
		InputMap.action_add_event(action, ev)


# --- Jogo ---
func reset_game() -> void:
	energy = MAX_ENERGY
	inventory.clear()
	components.clear()
	layer_index = 0
	energy_changed.emit(energy, MAX_ENERGY)
	inventory_changed.emit()


func drain_energy(amount: float) -> void:
	if energy <= 0.0:
		return
	energy = maxf(0.0, energy - amount)
	energy_changed.emit(energy, MAX_ENERGY)
	if energy <= 0.0:
		player_died.emit()


func restore_energy(amount: float) -> void:
	energy = minf(MAX_ENERGY, energy + amount)
	energy_changed.emit(energy, MAX_ENERGY)


func respawn_energy() -> void:
	energy = MAX_ENERGY * 0.6
	energy_changed.emit(energy, MAX_ENERGY)
	post_message("Energia crítica! A cápsula reiniciou o sistema.")


func post_message(text: String) -> void:
	message_posted.emit(text)


func add_item(id: String, amount: int = 1) -> void:
	inventory[id] = inventory.get(id, 0) + amount
	inventory_changed.emit()


func has_items(cost: Dictionary) -> bool:
	for id in cost:
		if inventory.get(id, 0) < cost[id]:
			return false
	return true


func can_craft(id: String) -> bool:
	return RECIPES.has(id) and not components.has(id) and has_items(RECIPES[id]["cost"])


func craft(id: String) -> bool:
	if not can_craft(id):
		return false
	for mat in RECIPES[id]["cost"]:
		inventory[mat] -= RECIPES[id]["cost"][mat]
	components[id] = true
	inventory_changed.emit()
	post_message("Componente construído: %s" % RECIPES[id]["name"])
	return true


func has_component(id: String) -> bool:
	return components.has(id)


func has_ability(ability: String) -> bool:
	for id in components:
		if RECIPES[id].get("ability", "") == ability:
			return true
	return false


func go_to_next_layer() -> void:
	var path: String = LEVEL_PATH % (layer_index + 2)
	if ResourceLoader.exists(path):
		get_tree().change_scene_to_file.call_deferred(path)
	else:
		post_message("Próxima camada em construção. Crie o arquivo %s" % path)
