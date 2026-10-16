extends SceneTree

## Testes de gameplay, rodados em modo headless:
##   godot --headless --path game -s res://tests/test_gameplay.gd
## Cada teste simula entradas reais (Input.action_press) e verifica o estado do jogador,
## do inimigo, o dano causado e a transição entre animações.

var _passed := 0
var _failed := 0
var _main: Node
var _player: Player
var _hound: SpindleHound


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	_main = load("res://scenes/main.tscn").instantiate()
	root.add_child(_main)
	await frames(5)
	_player = _main.player
	_hound = _main.hounds[0]
	# Remove os inimigos de fundo para que os testes controlem a cena.
	for h in _main.hounds:
		h.queue_free()
	_main.hounds.clear()
	await frames(2)
	await test_spawn_lands_on_floor()
	await test_run_right()
	await test_jump_and_land()
	await test_basic_attack_state()
	await test_combo_chain_to_second_hit()
	await test_special_needs_meter()
	await test_roll_gives_invulnerability()
	await test_player_takes_damage_and_dies()
	await test_hound_hit_damage_and_death()
	await test_hound_ai_telegraphs_then_lunges()
	await test_player_attack_hits_hound()
	print("RESULTADO: %d passaram, %d falharam" % [_passed, _failed])
	quit(1 if _failed > 0 else 0)


func frames(n: int) -> void:
	for i in range(n):
		await physics_frame


func check(cond: bool, label: String) -> void:
	if cond:
		_passed += 1
		print("  [OK]    " + label)
	else:
		_failed += 1
		print("  [FALHA] " + label)


func tap(action: String) -> void:
	Input.action_press(action)
	await physics_frame
	Input.action_release(action)


func reset_player(pos: Vector2) -> void:
	_player.position = pos
	_player.velocity = Vector2.ZERO
	_player.hp = 100
	_player.alive = true
	_player.invuln = 999.0
	_player.hitstop = 0.0
	_player.meter = 50.0
	_player._set_state(Player.S.IDLE)


func test_spawn_lands_on_floor() -> void:
	print("Teste: queda e aterrissagem")
	reset_player(Vector2(160.0, 560.0))
	await frames(90)
	check(_player.is_on_floor(), "jogador fica apoiado no chão")
	check(_player.state == Player.S.IDLE, "estado volta a IDLE após cair")


func test_run_right() -> void:
	print("Teste: corrida")
	reset_player(Vector2(300.0, 640.0))
	await frames(10)
	var x0 := _player.global_position.x
	Input.action_press("move_right")
	await frames(30)
	Input.action_release("move_right")
	check(_player.global_position.x - x0 > 100.0, "andar para a direita percorre mais de 100 px em 0,5 s")
	check(_player.facing > 0.0, "personagem vira para a direita")


func test_jump_and_land() -> void:
	print("Teste: salto e aterrissagem")
	reset_player(Vector2(300.0, 640.0))
	await frames(10)
	var y0 := _player.global_position.y
	# Segura o botão de pulo: o corte de altura só acontece ao soltar.
	Input.action_press("jump")
	await physics_frame
	await frames(3)
	check(_player.state == Player.S.JUMP, "salto entra no estado JUMP")
	var min_y := _player.global_position.y
	for i in range(30):
		await physics_frame
		min_y = minf(min_y, _player.global_position.y)
	Input.action_release("jump")
	check(y0 - min_y > 60.0, "salto segurado sobe mais de 60 px (subiu %d px)" % int(y0 - min_y))
	await frames(120)
	check(_player.is_on_floor(), "volta ao chão depois do salto")


func test_basic_attack_state() -> void:
	print("Teste: ataque básico")
	reset_player(Vector2(300.0, 640.0))
	await frames(10)
	var serial0 := _player.attack_serial
	await tap("attack")
	await frames(2)
	check(_player.state == Player.S.ATK1, "ataque entra no estado ATK1")
	check(_player.attack_serial == serial0 + 1, "ataque incrementa o número de série do golpe")
	await frames(40)
	check(_player.state == Player.S.IDLE, "ataque termina e volta a IDLE")


func test_combo_chain_to_second_hit() -> void:
	print("Teste: combo terrestre (ATK1 -> ATK2)")
	reset_player(Vector2(300.0, 640.0))
	await frames(10)
	await tap("attack")
	await frames(10)
	check(_player.state == Player.S.ATK1, "primeiro golpe está ativo")
	await tap("attack")
	await frames(3)
	check(_player.state == Player.S.ATK2, "segundo aperto dentro da janela abre o ATK2")
	await frames(60)
	check(_player.state == Player.S.IDLE, "combo termina e volta a IDLE")


func test_special_needs_meter() -> void:
	print("Teste: habilidade especial consome medidor")
	reset_player(Vector2(300.0, 640.0))
	_player.meter = 10.0
	await frames(5)
	await tap("special")
	await frames(3)
	check(_player.state != Player.S.SPECIAL, "sem medidor suficiente, a especial não ativa")
	_player.meter = 60.0
	await tap("special")
	await frames(3)
	check(_player.state == Player.S.SPECIAL, "com 60% de medidor, a especial ativa")
	check(_player.meter < 15.0, "a especial consome 50 do medidor")
	await frames(60)


func test_roll_gives_invulnerability() -> void:
	print("Teste: esquiva com invulnerabilidade")
	reset_player(Vector2(300.0, 640.0))
	_player.invuln = 0.0
	await frames(10)
	await tap("roll")
	await frames(2)
	check(_player.state == Player.S.ROLL, "esquiva entra no estado ROLL")
	check(_player.invuln > 0.0, "esquiva concede invulnerabilidade")
	await frames(60)


func test_player_takes_damage_and_dies() -> void:
	print("Teste: dano e morte do jogador")
	reset_player(Vector2(300.0, 640.0))
	_player.invuln = 0.0
	var ok := _player.take_hit({"damage": 15, "knock": Vector2(100, -100), "stun": 0.3, "hitstop": 0.0, "source_x": 500.0})
	check(ok and _player.hp == 85, "golpe de 15 reduz a vida para 85")
	check(_player.state == Player.S.HURT, "golpe leva o jogador a HURT")
	_player.invuln = 0.0
	_player.take_hit({"damage": 200, "knock": Vector2.ZERO, "stun": 0.3, "hitstop": 0.0, "source_x": 500.0})
	check(not _player.alive and _player.state == Player.S.DEAD, "golpe letal leva a DEAD")
	await frames(5)


func test_hound_hit_damage_and_death() -> void:
	print("Teste: dano e morte do inimigo")
	var h := _spawn_hound(Vector2(700.0, 640.0))
	await frames(5)
	h.invuln = 0.0
	var ok := h.take_hit({"damage": 20, "knock": Vector2(50, -50), "stun": 0.2, "hitstop": 0.0, "source_x": 600.0})
	check(ok and h.hp == SpindleHound.MAX_HP - 20, "golpe de 20 reduz o Cão-Fuso para %d" % (SpindleHound.MAX_HP - 20))
	check(h.ai == SpindleHound.AI.HURT, "golpe leva o Cão-Fuso ao estado HURT")
	h.take_hit({"damage": 999, "knock": Vector2.ZERO, "stun": 0.2, "hitstop": 0.0, "source_x": 600.0})
	check(not h.alive and h.ai == SpindleHound.AI.DEAD, "golpe letal leva o Cão-Fuso a DEAD")
	await frames(120)
	check(not is_instance_valid(h), "Cão-Fuso é removido ao fim da animação de morte")


func test_hound_ai_telegraphs_then_lunges() -> void:
	print("Teste: IA do Cão-Fuso (percepção, aviso e investida)")
	reset_player(Vector2(600.0, 640.0))
	var h := _spawn_hound(Vector2(800.0, 640.0))
	var saw := {"alert": false, "telegraph": false, "lunge": false, "recover": false}
	for i in range(60 * 10):
		await physics_frame
		if h.ai == SpindleHound.AI.ALERT:
			saw["alert"] = true
		elif h.ai == SpindleHound.AI.TELEGRAPH:
			saw["telegraph"] = true
		elif h.ai == SpindleHound.AI.LUNGE:
			saw["lunge"] = true
		elif h.ai == SpindleHound.AI.RECOVER:
			saw["recover"] = true
		if saw["recover"]:
			break
	check(saw["alert"], "inimigo percebe o jogador (ALERT)")
	check(saw["telegraph"], "inimigo avisa antes da investida (TELEGRAPH)")
	check(saw["lunge"], "inimigo investe (LUNGE)")
	check(saw["recover"], "inimigo fica exposto depois da investida (RECOVER)")
	_player.invuln = 999.0
	h.queue_free()
	await frames(3)


func test_player_attack_hits_hound() -> void:
	print("Teste: ataque do jogador acerta o inimigo")
	reset_player(Vector2(400.0, 640.0))
	var h := _spawn_hound(Vector2(462.0, 640.0))
	h.attack_cd = 999.0
	await frames(5)
	var hp0 := h.hp
	_player.set_facing(1.0)
	await tap("attack")
	await frames(30)
	check(h.hp < hp0, "golpe básico acerta o Cão-Fuso (vida %d -> %d)" % [hp0, h.hp])
	h.queue_free()
	await frames(3)


func _spawn_hound(pos: Vector2) -> SpindleHound:
	var h := SpindleHound.new()
	h.position = pos
	h.target = _player
	_main.add_child(h)
	_main.hounds.append(h)
	return h
