extends Node2D

## Ponto de entrada da demonstração "Cordas Partidas". Monta a fase, o jogador, os inimigos
## e a HUD. A resolução de acertos roda por último em cada quadro de física, usando os
## dados de ataque ativos de cada lutador.

var stage: Stage
var player: Player
var hud: Hud
var hounds: Array[SpindleHound] = []
var _hit_log: Dictionary = {}
var _elapsed := 0.0
var _defeated := 0
var _won := false
var _effects: Node2D


func _ready() -> void:
	process_physics_priority = 100
	_setup_input()
	RenderingServer.set_default_clear_color(Palette.NIGHT)

	var mod := CanvasModulate.new()
	mod.color = Color(0.62, 0.64, 0.82)
	add_child(mod)

	stage = Stage.new()
	add_child(stage)

	player = Player.new()
	player.position = stage.player_spawn()
	add_child(player)
	player.died.connect(_on_player_died)

	var cam := Camera2D.new()
	cam.position_smoothing_enabled = true
	cam.position_smoothing_speed = 8.0
	cam.limit_left = 0
	cam.limit_top = 0
	cam.limit_right = int(Stage.WORLD_SIZE.x)
	cam.limit_bottom = int(Stage.WORLD_SIZE.y)
	player.add_child(cam)
	cam.make_current()

	for p in stage.spawn_points():
		var hound := SpindleHound.new()
		hound.position = p
		hound.target = player
		add_child(hound)
		hound.died.connect(_on_hound_died)
		hounds.append(hound)

	_effects = Node2D.new()
	_effects.z_index = 5
	add_child(_effects)

	var layer := CanvasLayer.new()
	add_child(layer)
	hud = Hud.new()
	layer.add_child(hud)


func _physics_process(delta: float) -> void:
	_elapsed += delta
	_resolve_combat()


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("restart"):
		get_tree().reload_current_scene()
		return
	var remaining := 0
	for h in hounds:
		if is_instance_valid(h) and h.alive:
			remaining += 1
	var message := ""
	var sub := ""
	if _won:
		message = "Demonstração concluída"
		sub = "Ruínas Desfiadas limpas. Pressione R para jogar de novo."
	elif not player.alive:
		message = "Ondra caiu"
		sub = "Pressione R para recomeçar."
	hud.update_state({
		"hp": player.hp,
		"max_hp": player.max_hp,
		"meter": player.meter,
		"combo": player.hit_combo,
		"remaining": remaining,
		"defeated": _defeated,
		"message": message,
		"sub_message": sub,
		"fps": Engine.get_frames_per_second(),
	})


func _resolve_combat() -> void:
	for h in hounds:
		if not is_instance_valid(h) or not h.alive:
			continue
		_try_hit(player, h)
		_try_hit(h, player)


## Testa se o golpe ativo de "attacker" atinge "defender" neste quadro.
func _try_hit(attacker: Fighter, defender: Fighter) -> void:
	if not attacker.alive or not defender.alive:
		return
	var data := attacker.active_attack()
	if data.is_empty():
		return
	var key := "%d:%d:%d" % [attacker.get_instance_id(), attacker.attack_serial, defender.get_instance_id()]
	if _hit_log.has(key):
		var repeat := float(data.get("repeat", 0.0))
		if repeat <= 0.0 or _elapsed - float(_hit_log[key]) < repeat:
			return
	var seg := attacker.attack_segment()
	var box := defender.get_hurtbox()
	if not HitUtil.segment_hits_rect(seg, box, 12.0):
		return
	_hit_log[key] = _elapsed
	if _hit_log.size() > 400:
		_hit_log.clear()
	var hit := attacker.make_hit(data)
	if defender.take_hit(hit):
		attacker.on_attack_landed(data)
		var col := Palette.GOLD_GLOW if attacker == player else Palette.CORRUPT_GLOW
		_spawn_spark(HitUtil.contact_point(seg, box), col)


func _spawn_spark(pos: Vector2, col: Color) -> void:
	var s := HitSpark.new()
	s.position = pos
	s.color = col
	_effects.add_child(s)


func _on_hound_died(_fighter: Fighter) -> void:
	_defeated += 1
	if _defeated >= hounds.size():
		_won = true


func _on_player_died(_fighter: Fighter) -> void:
	pass


func _setup_input() -> void:
	_bind("move_left", [KEY_A, KEY_LEFT])
	_bind("move_right", [KEY_D, KEY_RIGHT])
	_bind("jump", [KEY_SPACE, KEY_W, KEY_UP])
	_bind("attack", [KEY_X, KEY_J])
	_bind("special", [KEY_C, KEY_K])
	_bind("roll", [KEY_SHIFT, KEY_L])
	_bind("restart", [KEY_R])


func _bind(action: String, keys: Array) -> void:
	if not InputMap.has_action(action):
		InputMap.add_action(action)
	for k in keys:
		var ev := InputEventKey.new()
		ev.physical_keycode = k
		InputMap.action_add_event(action, ev)
