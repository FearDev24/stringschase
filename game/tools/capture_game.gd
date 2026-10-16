extends SceneTree

## Captura telas reais da demonstração (Frayed Ruins) em docs/screenshots.
## Rodar com janela (precisa de renderização):
##   Godot_v4.7.1-stable_win64_console.exe --path game -s res://tools/capture_game.gd

var _out := ""
var _main: Node


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	_out = ProjectSettings.globalize_path("res://").path_join("../docs/screenshots")
	_main = load("res://scenes/main.tscn").instantiate()
	root.add_child(_main)
	await frames(60)
	await shot("game_01_idle.png")

	Input.action_press("move_right")
	await frames(28)
	await shot("game_02_run.png")
	Input.action_release("move_right")

	await frames(40)
	Input.action_press("jump")
	await frames(12)
	Input.action_release("jump")
	await frames(5)
	await shot("game_03_jump.png")
	await frames(90)

	# Espera o primeiro Cão-Fuso entrar em aviso de investida, e registra o aviso.
	var hound = _main.hounds[0]
	_main.player.invuln = 999.0
	_main.player.position.x = hound.position.x - 300.0
	for i in range(60 * 12):
		await physics_frame
		if hound.ai == SpindleHound.AI.TELEGRAPH:
			break
	await shot("game_04_hound_telegraph.png")

	# Ataque básico contra o inimigo, no meio do golpe.
	await frames(60)
	_main.player.position.x = hound.position.x - 62.0
	_main.player.invuln = 999.0
	await frames(5)
	Input.action_press("attack")
	await physics_frame
	Input.action_release("attack")
	await frames(9)
	await shot("game_05_attack.png")
	await frames(40)

	# Habilidade especial "Laço Tecido".
	_main.player.meter = 80.0
	Input.action_press("special")
	await physics_frame
	Input.action_release("special")
	await frames(22)
	await shot("game_06_special.png")

	quit(0)


func frames(n: int) -> void:
	for i in range(n):
		await physics_frame


func shot(file_name: String) -> void:
	await process_frame
	var img := root.get_texture().get_image()
	img.save_png(_out.path_join(file_name))
	print("Salvo: " + file_name)
