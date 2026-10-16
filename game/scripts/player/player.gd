class_name Player
extends Fighter

## Ondra, a protagonista. Controla movimento, combo terrestre, ataque aéreo, habilidade
## especial "Laço Tecido" e esquiva. Os tempos dos golpes são definidos em ATTACKS e
## a detecção de acerto fica com a cena principal (main.gd).

signal meter_changed(value: float)
signal combo_changed(hits: int)

enum S { IDLE, RUN, JUMP, FALL, LAND, ATK1, ATK2, AIR_ATK, SPECIAL, ROLL, HURT, DEAD }

const RUN_SPEED := 250.0
const RUN_ACCEL := 2200.0
const AIR_ACCEL := 1300.0
const FRICTION := 2600.0
const JUMP_VELOCITY := -540.0
const JUMP_CUT := 0.45
const GRAVITY := 1500.0
const FALL_MULT := 1.35
const MAX_FALL := 900.0
const ROLL_SPEED := 380.0
const ROLL_TIME := 0.42
const ROLL_COOLDOWN := 0.5
const SPECIAL_COST := 50.0
const SPECIAL_TIME := 0.72
const LAND_TIME := 0.16
const HURT_TIME := 0.34
const CHAIN_OPEN := 0.14
const BUFFER := 0.2

## Janela ativa (start..end, em segundos desde o início do estado) e dados de cada golpe.
## repeat > 0 permite novo acerto no mesmo inimigo após esse intervalo (habilidade especial).
const ATTACKS := {
	S.ATK1: {"dur": 0.32, "start": 0.07, "end": 0.17, "damage": 14, "knock": Vector2(170.0, -110.0), "stun": 0.28, "hitstop": 0.06, "meter": 6.0, "repeat": 0.0, "knockdown": false},
	S.ATK2: {"dur": 0.46, "start": 0.16, "end": 0.30, "damage": 24, "knock": Vector2(320.0, -240.0), "stun": 0.40, "hitstop": 0.10, "meter": 10.0, "repeat": 0.0, "knockdown": true},
	S.AIR_ATK: {"dur": 0.42, "start": 0.10, "end": 0.34, "damage": 18, "knock": Vector2(120.0, 260.0), "stun": 0.30, "hitstop": 0.07, "meter": 8.0, "repeat": 0.0, "knockdown": false},
	S.SPECIAL: {"dur": 0.72, "start": 0.12, "end": 0.58, "damage": 14, "knock": Vector2(240.0, -150.0), "stun": 0.30, "hitstop": 0.04, "meter": 4.0, "repeat": 0.22, "knockdown": false},
}

var state: int = S.IDLE
var state_time := 0.0
var meter := 50.0
var hit_combo := 0
var roll_cd := 0.0
var roll_dir := 1.0
var combo_timer := 0.0
var _air_attack_used := false
var _buf_jump := 0.0
var _buf_attack := 0.0
var _buf_special := 0.0
var _buf_roll := 0.0
var _jump_cut_done := false


func _ready() -> void:
	max_hp = 100
	hp = 100
	rig = CharacterRig.new()
	add_child(rig)
	var shape := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = Vector2(22.0, 60.0)
	shape.shape = rect
	shape.position = Vector2(0.0, -30.0)
	add_child(shape)
	collision_layer = 1
	collision_mask = 1


func _physics_process(delta: float) -> void:
	if is_frozen(delta):
		rig.step(0.0, velocity.x)
		return
	tick_timers(delta)
	state_time += delta
	roll_cd = maxf(0.0, roll_cd - delta)
	if combo_timer > 0.0:
		combo_timer -= delta
		if combo_timer <= 0.0 and hit_combo > 0:
			hit_combo = 0
			combo_changed.emit(0)
	_buf_jump = maxf(0.0, _buf_jump - delta)
	_buf_attack = maxf(0.0, _buf_attack - delta)
	_buf_special = maxf(0.0, _buf_special - delta)
	_buf_roll = maxf(0.0, _buf_roll - delta)
	if Input.is_action_just_pressed("jump"):
		_buf_jump = BUFFER * 0.6
	if Input.is_action_just_pressed("attack"):
		_buf_attack = BUFFER
	if Input.is_action_just_pressed("special"):
		_buf_special = BUFFER * 0.6
	if Input.is_action_just_pressed("roll"):
		_buf_roll = BUFFER * 0.6

	var axis := Input.get_axis("move_left", "move_right")
	match state:
		S.IDLE, S.RUN, S.LAND:
			_ground(axis, delta)
		S.JUMP:
			_jump(axis, delta)
		S.FALL:
			_fall(axis, delta)
		S.AIR_ATK:
			_air_attack(delta)
		S.ATK1:
			_attack_ground(delta, true)
		S.ATK2:
			_attack_ground(delta, false)
		S.SPECIAL:
			_special(delta)
		S.ROLL:
			_roll()
		S.HURT:
			_hurt(delta)
		S.DEAD:
			_gravity(delta, 1.0)
			velocity.x = move_toward(velocity.x, 0.0, FRICTION * delta)

	move_and_slide()
	if state in [S.IDLE, S.RUN, S.JUMP, S.FALL, S.LAND] and absf(axis) > 0.1:
		set_facing(axis)
	_update_rig_anim()
	rig.aura = move_toward(rig.aura, 1.0 if state == S.SPECIAL else 0.0, delta * 3.0)
	rig.step(delta, velocity.x)


## Golpe ativo neste instante, ou dicionário vazio. A cena principal testa o acerto.
func active_attack() -> Dictionary:
	if not ATTACKS.has(state):
		return {}
	var data: Dictionary = ATTACKS[state]
	if state_time < float(data["start"]) or state_time > float(data["end"]):
		return {}
	return data


func attack_segment() -> PackedVector2Array:
	return rig.blade_segment()


func on_attack_landed(data: Dictionary) -> void:
	meter = minf(100.0, meter + float(data["meter"]))
	hit_combo += 1
	combo_timer = 1.2
	combo_changed.emit(hit_combo)
	meter_changed.emit(meter)
	hitstop = maxf(hitstop, float(data["hitstop"]) * 0.6)


func take_hit(hit: Dictionary) -> bool:
	if not super.take_hit(hit):
		return false
	if not alive:
		_set_state(S.DEAD)
	else:
		_set_state(S.HURT)
	return true


func _set_state(new_state: int) -> void:
	state = new_state
	state_time = 0.0
	if ATTACKS.has(new_state):
		attack_serial += 1
	var sound := SFX_BY_STATE.get(new_state, "") as String
	if sound != "":
		sfx_requested.emit(sound)


const SFX_BY_STATE := {
	S.ATK1: "swing_light",
	S.ATK2: "swing_heavy",
	S.AIR_ATK: "swing_light",
	S.SPECIAL: "special",
	S.JUMP: "jump",
	S.LAND: "land",
	S.ROLL: "roll",
	S.HURT: "player_hurt",
	S.DEAD: "player_die",
}


func _gravity(delta: float, mult: float) -> void:
	velocity.y = minf(velocity.y + GRAVITY * mult * delta, MAX_FALL)


func _move_ground(axis: float, delta: float) -> void:
	var target := axis * RUN_SPEED
	var accel := RUN_ACCEL if absf(axis) > 0.1 else FRICTION
	velocity.x = move_toward(velocity.x, target, accel * delta)


func _ground(axis: float, delta: float) -> void:
	if not is_on_floor():
		_set_state(S.FALL)
		return
	_gravity(delta, 1.0)
	if _buf_attack > 0.0:
		_buf_attack = 0.0
		_set_state(S.ATK1)
		return
	if _buf_special > 0.0 and meter >= SPECIAL_COST:
		_buf_special = 0.0
		meter -= SPECIAL_COST
		meter_changed.emit(meter)
		invuln = 0.3
		_set_state(S.SPECIAL)
		return
	if _buf_roll > 0.0 and roll_cd <= 0.0:
		_start_roll(axis)
		return
	if _buf_jump > 0.0:
		_buf_jump = 0.0
		velocity.y = JUMP_VELOCITY
		_jump_cut_done = false
		_set_state(S.JUMP)
		return
	_move_ground(axis, delta)
	if state == S.LAND and state_time < LAND_TIME:
		return
	var want := S.RUN if absf(velocity.x) > 20.0 else S.IDLE
	if state != want:
		_set_state(want)


func _jump(axis: float, delta: float) -> void:
	_gravity(delta, 1.0)
	_air_move(axis, delta)
	if not Input.is_action_pressed("jump") and not _jump_cut_done and velocity.y < 0.0:
		velocity.y *= JUMP_CUT
		_jump_cut_done = true
	if _buf_attack > 0.0 and not _air_attack_used:
		_start_air_attack()
		return
	if velocity.y >= 0.0:
		_set_state(S.FALL)


func _fall(axis: float, delta: float) -> void:
	_gravity(delta, FALL_MULT)
	_air_move(axis, delta)
	if _buf_attack > 0.0 and not _air_attack_used:
		_start_air_attack()
		return
	if is_on_floor():
		_air_attack_used = false
		_set_state(S.LAND)


func _air_move(axis: float, delta: float) -> void:
	velocity.x = move_toward(velocity.x, axis * RUN_SPEED, AIR_ACCEL * delta)


func _start_air_attack() -> void:
	_buf_attack = 0.0
	_air_attack_used = true
	velocity.y = 180.0
	_set_state(S.AIR_ATK)


func _air_attack(delta: float) -> void:
	_gravity(delta, 0.6)
	velocity.x = move_toward(velocity.x, 0.0, FRICTION * delta * 0.5)
	if is_on_floor():
		_air_attack_used = false
		_set_state(S.LAND)
	elif state_time >= float(ATTACKS[S.AIR_ATK]["dur"]):
		_set_state(S.FALL)


## Combo terrestre. Em ATK1, a entrada do botão dentro da janela abre o ATK2.
func _attack_ground(delta: float, can_chain: bool) -> void:
	_gravity(delta, 1.0)
	velocity.x = move_toward(velocity.x, 0.0, FRICTION * delta * 0.6)
	if can_chain and state_time >= CHAIN_OPEN and _buf_attack > 0.0:
		_buf_attack = 0.0
		_set_state(S.ATK2)
		return
	var dur := float(ATTACKS[state]["dur"])
	if state_time >= dur:
		_set_state(S.IDLE if is_on_floor() else S.FALL)


func _start_roll(axis: float) -> void:
	_buf_roll = 0.0
	roll_cd = ROLL_COOLDOWN
	roll_dir = facing if absf(axis) < 0.1 else signf(axis)
	set_facing(roll_dir)
	invuln = 0.28
	_set_state(S.ROLL)


func _roll() -> void:
	velocity.x = roll_dir * ROLL_SPEED
	velocity.y = 0.0
	if state_time >= ROLL_TIME:
		_set_state(S.IDLE)


func _special(delta: float) -> void:
	_gravity(delta, 1.0)
	velocity.x = move_toward(velocity.x, 0.0, FRICTION * delta * 2.0)
	if state_time >= SPECIAL_TIME:
		_set_state(S.IDLE if is_on_floor() else S.FALL)


func _hurt(delta: float) -> void:
	_gravity(delta, 1.0)
	velocity.x = move_toward(velocity.x, 0.0, FRICTION * delta * 0.4)
	if state_time >= HURT_TIME:
		_set_state(S.IDLE if is_on_floor() else S.FALL)


func _update_rig_anim() -> void:
	match state:
		S.IDLE:
			rig.play("idle")
		S.RUN:
			rig.play("run")
		S.JUMP:
			rig.play("jump" if state_time < 0.2 else "rise")
		S.FALL:
			rig.play("fall")
		S.LAND:
			rig.play("land")
		S.ATK1:
			rig.play("attack1")
		S.ATK2:
			rig.play("attack2")
		S.AIR_ATK:
			rig.play("air_attack")
		S.SPECIAL:
			rig.play("special")
		S.ROLL:
			rig.play("roll")
		S.HURT:
			rig.play("hurt")
		S.DEAD:
			rig.play("dead")
	rig.trail_on = not active_attack().is_empty()
