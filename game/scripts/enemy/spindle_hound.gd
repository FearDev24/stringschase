class_name SpindleHound
extends Fighter

## Cão-Fuso (Spindle Hound), criatura de Frayed Ruins. A wiki lista a criatura, mas sem aparência
## nem comportamento: ambos são invenção original deste jogo. Patrulha, percebe o jogador,
## circula a distância, avisa a investida (telegrafia), investe e fica exposto depois.

enum AI { PATROL, ALERT, STALK, TELEGRAPH, LUNGE, RECOVER, HURT, DEAD }

const MAX_HP := 60
const PATROL_SPEED := 70.0
const STALK_SPEED := 170.0
const LUNGE_SPEED := 480.0
const GRAVITY := 1500.0
const DETECT_RANGE := 340.0
const STALK_DIST := 170.0
const ATTACK_RANGE := 240.0
const ALERT_TIME := 0.45
const TELEGRAPH_TIME := 0.55
const LUNGE_TIME := 0.40
const LUNGE_ACTIVE := Vector2(0.06, 0.32)
const RECOVER_TIME := 0.80
const ATTACK_COOLDOWN := 1.2
const DEATH_TIME := 1.4
const LUNGE_DAMAGE := 14
const PATROL_HALF := 120.0

var ai: int = AI.PATROL
var ai_time := 0.0
var attack_cd := 0.8
var target: Fighter
var home_x := 0.0
var _time := 0.0
var _death_time := 0.0
var _stun := 0.0


func _ready() -> void:
	max_hp = MAX_HP
	hp = MAX_HP
	home_x = global_position.x
	collision_layer = 2
	collision_mask = 1
	var shape := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = Vector2(40.0, 30.0)
	shape.shape = rect
	shape.position = Vector2(0.0, -15.0)
	add_child(shape)
	facing = -1.0


func _physics_process(delta: float) -> void:
	_time += delta
	if ai == AI.DEAD:
		_death_time += delta
		velocity.x = move_toward(velocity.x, 0.0, 900.0 * delta)
		velocity.y = minf(velocity.y + GRAVITY * delta, 900.0)
		move_and_slide()
		modulate.a = clampf(1.0 - _death_time / DEATH_TIME, 0.0, 1.0)
		if _death_time >= DEATH_TIME:
			queue_free()
		queue_redraw()
		return
	if is_frozen(delta):
		queue_redraw()
		return
	ai_time += delta
	attack_cd = maxf(0.0, attack_cd - delta)
	tick_timers(delta)

	var dx := 0.0
	var dy := 0.0
	if target != null and target.alive:
		dx = target.global_position.x - global_position.x
		dy = target.global_position.y - global_position.y

	match ai:
		AI.PATROL:
			_patrol(delta, absf(dx), dy)
		AI.ALERT:
			velocity.x = 0.0
			if ai_time >= ALERT_TIME:
				_set_ai(AI.STALK)
		AI.STALK:
			_stalk(delta, dx)
		AI.TELEGRAPH:
			velocity.x = 0.0
			if dx != 0.0:
				set_facing(signf(dx))
			if ai_time >= TELEGRAPH_TIME:
				_set_ai(AI.LUNGE)
		AI.LUNGE:
			velocity.x = facing * LUNGE_SPEED
			if ai_time >= LUNGE_TIME:
				_set_ai(AI.RECOVER)
		AI.RECOVER:
			velocity.x = move_toward(velocity.x, 0.0, 1600.0 * delta)
			if ai_time >= RECOVER_TIME:
				attack_cd = ATTACK_COOLDOWN
				_set_ai(AI.STALK)
		AI.HURT:
			velocity.x = move_toward(velocity.x, 0.0, 1200.0 * delta)
			if ai_time >= _stun:
				_set_ai(AI.STALK)

	if ai != AI.LUNGE:
		velocity.y = minf(velocity.y + GRAVITY * delta, 900.0)
	else:
		velocity.y = 0.0
	move_and_slide()
	queue_redraw()


func take_hit(hit: Dictionary) -> bool:
	if not super.take_hit(hit):
		return false
	if not alive:
		_set_ai(AI.DEAD)
		_death_time = 0.0
		collision_layer = 0
		return true
	_stun = float(hit.get("stun", 0.25))
	_set_ai(AI.HURT)
	return true


## Golpe ativo: só a investida, na janela LUNGE_ACTIVE, com o focinho como hitbox.
func active_attack() -> Dictionary:
	if ai == AI.LUNGE and ai_time >= LUNGE_ACTIVE.x and ai_time <= LUNGE_ACTIVE.y:
		return {
			"damage": LUNGE_DAMAGE,
			"knock": Vector2(260.0, -190.0),
			"stun": 0.32,
			"hitstop": 0.05,
			"knockdown": false,
			"repeat": 0.0,
		}
	return {}


func attack_segment() -> PackedVector2Array:
	return PackedVector2Array([to_global(_p(Vector2(6.0, -34.0))), to_global(_p(Vector2(44.0, -34.0)))])


func _set_ai(new_ai: int) -> void:
	ai = new_ai
	ai_time = 0.0
	if new_ai == AI.LUNGE:
		attack_serial += 1
	var sound := SFX_BY_AI.get(new_ai, "") as String
	if sound != "":
		sfx_requested.emit(sound)


## O impacto do golpe do jogador é tocado por main.gd, então o estado HURT fica sem som aqui.
const SFX_BY_AI := {
	AI.TELEGRAPH: "hound_telegraph",
	AI.LUNGE: "hound_lunge",
	AI.DEAD: "hound_die",
}


func _sees_player(adx: float, dy: float) -> bool:
	return adx < DETECT_RANGE and absf(dy) < 110.0


func _ledge_or_wall_ahead() -> bool:
	var space := get_world_2d().direct_space_state
	var origin := global_position + Vector2(facing * 26.0, -6.0)
	var floor_q := PhysicsRayQueryParameters2D.create(origin, origin + Vector2(0.0, 40.0))
	floor_q.collision_mask = 1
	if space.intersect_ray(floor_q).is_empty():
		return true
	var wall_q := PhysicsRayQueryParameters2D.create(global_position + Vector2(0.0, -20.0), global_position + Vector2(facing * 26.0, -20.0))
	wall_q.collision_mask = 1
	return not space.intersect_ray(wall_q).is_empty()


func _patrol(_delta: float, adx: float, dy: float) -> void:
	if target != null and target.alive and _sees_player(adx, dy):
		_set_ai(AI.ALERT)
		return
	velocity.x = facing * PATROL_SPEED
	var out_of_zone := global_position.x > home_x + PATROL_HALF or global_position.x < home_x - PATROL_HALF
	if out_of_zone or _ledge_or_wall_ahead():
		facing = -facing


func _stalk(delta: float, dx: float) -> void:
	if target == null or not target.alive:
		_set_ai(AI.PATROL)
		return
	var dir := signf(dx) if dx != 0.0 else facing
	set_facing(dir)
	var adx := absf(dx)
	if adx > DETECT_RANGE * 1.5:
		_set_ai(AI.PATROL)
		return
	# Mantém distância e desliza de um lado para o outro (não avança em linha reta).
	var error := adx - STALK_DIST
	var want := clampf(error * 3.0, -STALK_SPEED, STALK_SPEED) * dir
	want += sin(_time * 2.3) * 45.0
	if _ledge_or_wall_ahead() and signf(want) == facing:
		want = 0.0
	velocity.x = move_toward(velocity.x, want, 1400.0 * delta)
	if attack_cd <= 0.0 and adx < ATTACK_RANGE and adx > 90.0:
		_set_ai(AI.TELEGRAPH)


func _p(v: Vector2) -> Vector2:
	return Vector2(v.x * facing, v.y)


func _ellipse(center: Vector2, rx: float, ry: float, n := 18) -> PackedVector2Array:
	var pts := PackedVector2Array()
	for i in range(n):
		var a := TAU * float(i) / float(n)
		pts.append(center + Vector2(cos(a) * rx, sin(a) * ry))
	return pts


func _draw() -> void:
	var walking := absf(velocity.x) > 15.0 and (ai == AI.PATROL or ai == AI.STALK or ai == AI.RECOVER)
	var ph := _time * 14.0 if walking else 0.0
	var death := clampf(_death_time / DEATH_TIME, 0.0, 1.0) if ai == AI.DEAD else 0.0

	# Sombra no chão.
	draw_colored_polygon(_ellipse(Vector2(0.0, 0.5), 30.0, 4.0), Color(0, 0, 0, 0.35))

	# Brilho de telegrafia (aviso visual antes da investida).
	if ai == AI.TELEGRAPH:
		var pulse := 0.5 + 0.5 * sin(_time * 24.0)
		draw_circle(_p(Vector2(0.0, -30.0)), 46.0, Color(Palette.CORRUPT, 0.12 + 0.12 * pulse))

	# Pernas (atrás primeiro).
	_draw_leg(_p(Vector2(-14.0, -22.0)), 0.0, ph, Palette.WOOD_DARK)
	_draw_leg(_p(Vector2(-22.0, -22.0)), 1.9, ph, Palette.WOOD_DARK)

	# Fios que se desfiam da bobina.
	_draw_strands(death)

	# Corpo: bobina de tear.
	var spool := _ellipse(_p(Vector2(0.0, -34.0)), 26.0, 13.0)
	draw_colored_polygon(spool, Palette.WOOD)
	draw_polyline(_closed(spool), Palette.OUTLINE, 1.6)
	for x in [-16.0, -6.0, 4.0, 14.0]:
		draw_line(_p(Vector2(x, -46.0)), _p(Vector2(x, -22.0)), Palette.WOOD_DARK, 2.0)
	for k in range(4):
		var x0 := -20.0 + float(k) * 12.0
		draw_line(_p(Vector2(x0, -46.0)), _p(Vector2(x0 + 6.0, -22.0)), Palette.CORRUPT, 1.2)
	# Tampas de osso nas duas pontas.
	var cap_b := _ellipse(_p(Vector2(-26.0, -34.0)), 4.0, 13.0)
	var cap_f := _ellipse(_p(Vector2(26.0, -34.0)), 4.0, 13.0)
	draw_colored_polygon(cap_b, Palette.BONE)
	draw_colored_polygon(cap_f, Palette.BONE)
	draw_polyline(_closed(cap_b), Palette.OUTLINE, 1.2)
	draw_polyline(_closed(cap_f), Palette.OUTLINE, 1.2)

	# Pernas da frente.
	_draw_leg(_p(Vector2(14.0, -22.0)), 3.1, ph, Palette.WOOD)
	_draw_leg(_p(Vector2(20.0, -22.0)), 0.6, ph, Palette.WOOD)

	_draw_head()

	if ai != AI.DEAD and hp < max_hp:
		var w := 40.0
		var frac := float(hp) / float(max_hp)
		draw_rect(Rect2(Vector2(-w * 0.5, -66.0), Vector2(w, 4.0)), Palette.OUTLINE)
		draw_rect(Rect2(Vector2(-w * 0.5 + 1.0, -65.0), Vector2((w - 2.0) * frac, 2.0)), Palette.CORRUPT)


func _closed(pts: PackedVector2Array) -> PackedVector2Array:
	var out := pts.duplicate()
	out.append(pts[0])
	return out


func _draw_leg(hip: Vector2, off: float, ph: float, col: Color) -> void:
	var sw := sin(ph + off) * 0.35
	var knee := hip + Vector2(sin(sw) * 8.0 + 2.0, 11.0)
	var foot := knee + Vector2(-sin(sw) * 9.0, 11.0)
	if ai == AI.LUNGE:
		knee = hip + _p(Vector2(-6.0, 12.0))
		foot = hip + _p(Vector2(-18.0, 24.0))
	var pts := PackedVector2Array([hip, knee, foot])
	draw_polyline(pts, Palette.OUTLINE, 6.5)
	draw_polyline(pts, col, 4.0)
	draw_circle(foot, 3.0, Palette.BONE)


func _draw_strands(death: float) -> void:
	var count := 5
	var len_factor := 1.0 - death * 0.85
	for i in range(count):
		var start := _p(Vector2(-22.0 + float(i) * 2.0, -30.0 + float(i % 2) * 6.0))
		var pts := PackedVector2Array([start])
		for k in range(1, 6):
			var wob := sin(_time * 4.0 + float(i) * 1.1 + float(k) * 0.8) * (3.0 + float(k))
			var p := start + _p(Vector2(-float(k) * 7.0 * len_factor, 4.0 + float(k) * 2.2 * len_factor + wob * 0.3))
			pts.append(p)
		draw_polyline(pts, Color(Palette.CORRUPT, 0.35), 4.0)
		draw_polyline(pts, Palette.CORRUPT, 1.6)
		if death < 0.6:
			draw_circle(pts[pts.size() - 1], 1.4, Palette.CORRUPT_GLOW)


func _draw_head() -> void:
	var hc := _p(Vector2(30.0, -40.0))
	var ear_up := Vector2(-2.0, -16.0) if ai != AI.TELEGRAPH else Vector2(-8.0, -6.0)
	var ear_back := _p(Vector2(-4.0, -6.0))
	# Orelhas, achatadas no aviso.
	var e1 := PackedVector2Array([hc + ear_back, hc + _p(ear_up), hc + _p(Vector2(6.0, -4.0))])
	draw_colored_polygon(e1, Palette.WOOD_DARK)
	draw_polyline(PackedVector2Array([e1[0], e1[1], e1[2], e1[0]]), Palette.OUTLINE, 1.2)
	# Crânio e focinho.
	var skull := _ellipse(hc, 11.0, 9.0)
	draw_colored_polygon(skull, Palette.BONE)
	draw_polyline(_closed(skull), Palette.OUTLINE, 1.4)
	var snout := PackedVector2Array([hc + _p(Vector2(6.0, -4.0)), hc + _p(Vector2(16.0, -2.0)), hc + _p(Vector2(16.0, 3.0)), hc + _p(Vector2(6.0, 4.0))])
	draw_colored_polygon(snout, Palette.BONE)
	draw_polyline(_closed(snout), Palette.OUTLINE, 1.2)
	# Olhos vermelho-violeta, mais fortes no aviso e na investida.
	var glow := 1.0 if ai == AI.TELEGRAPH or ai == AI.LUNGE else 0.6
	draw_circle(hc + _p(Vector2(3.0, -3.0)), 2.6, Color(Palette.CORRUPT_GLOW, glow * 0.5))
	draw_circle(hc + _p(Vector2(3.0, -3.0)), 1.5, Palette.CORRUPT_GLOW)
