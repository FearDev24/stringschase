class_name CharacterRig
extends Node2D

## Personagem esquelético desenhado por código (sem sprites ou assets importados).
## A origem do nó é o quadril. Cada parte é um polígono com contorno e sombreamento.
## As poses vêm de CharacterAnims e são suavizadas por um blend curto entre animações.
## A capa é uma corrente de pontos com inércia, e o rastro da lâmina fica no mundo.

signal anim_finished(anim_name: String)

const BLEND_TIME := 0.08
const THIGH := 21.0
const SHIN := 20.0
const UPPER_ARM := 14.0
const FOREARM := 13.0
const TORSO := 27.0
const HEAD_R := 10.0
const BLADE := 52.0
const TRAIL_MAX := 12
const HIP_ANCHOR := Vector2(0.0, -40.0)

var anims: Dictionary = {}
var current := ""
var anim_time := 0.0
var trail_on := false
var aura := 0.0

var _pose: Dictionary = CharacterAnims.default_pose()
var _target: Dictionary = CharacterAnims.default_pose()
var _blend_from: Dictionary = CharacterAnims.default_pose()
var _blend_time := BLEND_TIME
var _finished := false
var _geo: Dictionary = {}
var _trail: Array[Vector2] = []
var _cape: PackedVector2Array = PackedVector2Array()
var _time := 0.0


func _ready() -> void:
	anims = CharacterAnims.build()
	_cape = PackedVector2Array([Vector2.ZERO, Vector2(-3, 10), Vector2(-5, 20), Vector2(-7, 30)])
	position = HIP_ANCHOR
	play("idle")
	_compute_geometry()


func set_facing(dir: float) -> void:
	if dir != 0.0:
		scale.x = signf(dir)


func play(anim_name: String, restart := false) -> void:
	if anim_name == current and not restart:
		return
	if not anims.has(anim_name):
		push_error("Animação desconhecida: %s" % anim_name)
		return
	_blend_from = _pose.duplicate()
	_blend_time = 0.0
	current = anim_name
	anim_time = 0.0
	_finished = false


func is_playing(anim_name: String) -> bool:
	return current == anim_name and not _finished


func progress() -> float:
	if current == "":
		return 0.0
	return clampf(anim_time / float(anims[current]["dur"]), 0.0, 1.0)


## Avança a animação. world_vx é a velocidade horizontal do personagem, usada na capa.
func step(delta: float, world_vx: float) -> void:
	_time += delta
	if current != "":
		var anim: Dictionary = anims[current]
		anim_time += delta
		var t := anim_time / float(anim["dur"])
		if not anim["loop"] and t >= 1.0 and not _finished:
			_finished = true
			anim_finished.emit(current)
		_target = CharacterAnims.sample(anim, t)
	_blend_time += delta
	var w := clampf(_blend_time / BLEND_TIME, 0.0, 1.0)
	_pose = CharacterAnims.lerp_pose(_blend_from, _target, w) if w < 1.0 else _target.duplicate()
	position = HIP_ANCHOR + Vector2(0.0, float(_pose["hip_y"]))
	rotation = deg_to_rad(float(_pose["body"]))
	_compute_geometry()
	_update_cape(delta, world_vx * scale.x)
	_update_trail()
	queue_redraw()


## Segmento da lâmina em coordenadas globais: [punho, ponta].
func blade_segment() -> PackedVector2Array:
	return PackedVector2Array([to_global(_geo["hand_f"]), to_global(_geo["tip"])])


static func _dir(deg: float) -> Vector2:
	var r := deg_to_rad(deg)
	return Vector2(sin(r), cos(r))


static func _up(deg: float) -> Vector2:
	var r := deg_to_rad(deg)
	return Vector2(sin(r), -cos(r))


func _compute_geometry() -> void:
	var p := _pose
	var hip := Vector2.ZERO
	var up := _up(p["torso"])
	var nor := Vector2(-up.y, up.x)
	var neck: Vector2 = hip + up * TORSO
	var shoulder: Vector2 = hip + up * (TORSO * 0.82)
	var head_dir := _up(p["head"])
	var head_c: Vector2 = neck + head_dir * (HEAD_R + 2.0)
	var hip_b: Vector2 = hip - nor * 4.0
	var hip_f: Vector2 = hip + nor * 4.0
	var knee_b: Vector2 = hip_b + _dir(p["leg_back_up"]) * THIGH
	var foot_b: Vector2 = knee_b + _dir(p["leg_back_lo"]) * SHIN
	var knee_f: Vector2 = hip_f + _dir(p["leg_front_up"]) * THIGH
	var foot_f: Vector2 = knee_f + _dir(p["leg_front_lo"]) * SHIN
	var sh_b: Vector2 = shoulder - nor * 6.0
	var sh_f: Vector2 = shoulder + nor * 6.0
	var elb_b: Vector2 = sh_b + _dir(p["arm_back_up"]) * UPPER_ARM
	var hand_b: Vector2 = elb_b + _dir(p["arm_back_lo"]) * FOREARM
	var elb_f: Vector2 = sh_f + _dir(p["arm_front_up"]) * UPPER_ARM
	var hand_f: Vector2 = elb_f + _dir(p["arm_front_lo"]) * FOREARM
	var tip: Vector2 = hand_f + _dir(p["wpn"]) * BLADE
	_geo = {
		"hip": hip, "up": up, "nor": nor, "neck": neck,
		"head": head_c, "head_dir": head_dir,
		"hip_b": hip_b, "knee_b": knee_b, "foot_b": foot_b,
		"hip_f": hip_f, "knee_f": knee_f, "foot_f": foot_f,
		"sh_b": sh_b, "elb_b": elb_b, "hand_b": hand_b,
		"sh_f": sh_f, "elb_f": elb_f, "hand_f": hand_f,
		"tip": tip,
	}


func _update_cape(delta: float, local_vx: float) -> void:
	var anchor: Vector2 = _geo["neck"] - _geo["nor"] * 7.0 + Vector2(0, 2)
	_cape[0] = anchor
	var k := clampf(delta * 16.0, 0.0, 1.0)
	for i in range(1, _cape.size()):
		var prev: Vector2 = _cape[i - 1]
		var flutter := sin(_time * 7.0 + float(i) * 1.3) * 1.4
		var target := prev + Vector2(-3.0 - local_vx * 0.05 + flutter, 9.5)
		_cape[i] = _cape[i].lerp(target, k)


func _update_trail() -> void:
	if trail_on:
		_trail.append(to_global(_geo["tip"]))
		if _trail.size() > TRAIL_MAX:
			_trail.pop_front()
	elif not _trail.is_empty():
		_trail.pop_front()


func _draw() -> void:
	if _geo.is_empty():
		return
	if aura > 0.0:
		var ac := Vector2(0, -20)
		draw_circle(ac, 60.0, Color(Palette.GOLD, 0.10 * aura))
		draw_circle(ac, 42.0, Color(Palette.GOLD_GLOW, 0.12 * aura))
		draw_arc(ac, 54.0, 0.0, TAU, 48, Color(Palette.GOLD, 0.7 * aura), 2.0)
	_draw_trail()
	_draw_leg(_geo["hip_b"], _geo["knee_b"], _geo["foot_b"], Palette.COAT_DARK)
	_draw_arm(_geo["sh_b"], _geo["elb_b"], _geo["hand_b"], Palette.COAT_DARK)
	_draw_cape()
	_draw_coat()
	_draw_head()
	_draw_leg(_geo["hip_f"], _geo["knee_f"], _geo["foot_f"], Palette.COAT)
	_draw_arm(_geo["sh_f"], _geo["elb_f"], _geo["hand_f"], Palette.COAT)
	_draw_blade()


func _draw_trail() -> void:
	var n := _trail.size()
	for i in range(1, n):
		var a := to_local(_trail[i - 1])
		var b := to_local(_trail[i])
		var f := float(i) / float(n)
		draw_line(a, b, Color(Palette.GOLD_GLOW, 0.8 * f), 1.5 + 3.0 * f)


## Membro com afinamento e contorno. Usado para pernas e braços.
func _draw_limb(a: Vector2, b: Vector2, wa: float, wb: float, col: Color) -> void:
	var d := (b - a).normalized()
	var n := Vector2(-d.y, d.x)
	var pts := PackedVector2Array([a + n * wa, b + n * wb, b - n * wb, a - n * wa])
	draw_colored_polygon(pts, col)
	var shade := PackedVector2Array([a - n * wa * 0.1, b - n * wb * 0.1, b - n * wb * 0.75, a - n * wa * 0.75])
	draw_colored_polygon(shade, col.darkened(0.25))
	draw_polyline(PackedVector2Array([pts[0], pts[1], pts[2], pts[3], pts[0]]), Palette.OUTLINE, 1.4)
	draw_circle(b, wb, col)
	draw_arc(b, wb, 0.0, TAU, 12, Palette.OUTLINE, 1.0)


func _draw_leg(hip: Vector2, knee: Vector2, foot: Vector2, col: Color) -> void:
	_draw_limb(hip, knee, 6.0, 4.8, col)
	_draw_limb(knee, foot, 4.8, 3.8, col.darkened(0.1))
	# Bota convexa (sempre triangula, mesmo com a perna em qualquer ângulo).
	var boot := PackedVector2Array([foot + Vector2(-3.0, -4.0), foot + Vector2(3.0, -4.0), foot + Vector2(6.0, 0.0), foot + Vector2(-3.0, 0.0)])
	draw_colored_polygon(boot, Palette.BOOT)
	draw_polyline(PackedVector2Array([boot[0], boot[1], boot[2], boot[3], boot[0]]), Palette.OUTLINE, 1.0)


func _draw_arm(sh: Vector2, elb: Vector2, hand: Vector2, col: Color) -> void:
	_draw_limb(sh, elb, 4.2, 3.4, col)
	_draw_limb(elb, hand, 3.4, 2.8, col.lightened(0.05))
	draw_circle(hand, 3.4, Palette.SKIN)
	draw_arc(hand, 3.4, 0.0, TAU, 10, Palette.OUTLINE, 1.0)


func _draw_cape() -> void:
	if _cape.size() < 2:
		return
	draw_polyline(_cape, Palette.OUTLINE, 11.0)
	draw_polyline(_cape, Palette.COAT_DARK, 8.0)
	var inner := PackedVector2Array()
	for i in range(_cape.size()):
		inner.append(_cape[i] + Vector2(1.5, 0.0))
	draw_polyline(inner, Palette.COAT, 2.5)


func _draw_coat() -> void:
	var hip: Vector2 = _geo["hip"]
	var up: Vector2 = _geo["up"]
	var nor: Vector2 = _geo["nor"]
	var neck: Vector2 = _geo["neck"]
	var down := -up
	var hem_f := hip + nor * 12.0 + down * 22.0
	var hem_b := hip - nor * 12.0 + down * 22.0
	var pts := PackedVector2Array([neck - nor * 9.0, neck + nor * 9.0, hip + nor * 11.0, hem_f, hem_b, hip - nor * 11.0])
	draw_colored_polygon(pts, Palette.COAT)
	draw_polyline(PackedVector2Array([pts[0], pts[1], pts[2], pts[3], pts[4], pts[5], pts[0]]), Palette.OUTLINE, 1.5)
	# Painel frontal mais claro, com costura dourada.
	var panel := PackedVector2Array([neck + nor * 9.0, neck + nor * 1.5, hip + nor * 2.0, hip + nor * 11.0])
	draw_colored_polygon(panel, Palette.COAT_LIGHT)
	draw_line(neck + nor * 1.5 + down * 1.0, hip + nor * 2.0, Palette.GOLD, 1.0)
	# Cinto.
	draw_line(hip - nor * 12.0, hip + nor * 12.0, Palette.BELT, 3.5)
	draw_rect(Rect2(hip + nor * 4.0 - Vector2(1.5, 2.0), Vector2(3.5, 4.0)), Palette.GOLD)
	# Losango dourado no peito (fio da Luz).
	var c := neck + down * 9.0
	var d := PackedVector2Array([c + up * 3.0, c + nor * 2.5, c - up * 3.0, c - nor * 2.5])
	draw_colored_polygon(d, Palette.GOLD)
	draw_polyline(PackedVector2Array([d[0], d[1], d[2], d[3], d[0]]), Palette.OUTLINE, 1.0)
	# Bainha dourada na barra.
	draw_line(hem_b + up * 1.0, hem_f + up * 1.0, Palette.GOLD, 1.0)


func _draw_head() -> void:
	var c: Vector2 = _geo["head"]
	var hd: Vector2 = _geo["head_dir"]
	var hn := Vector2(-hd.y, hd.x)
	# Rabo de cavalo, atrás da cabeça.
	var tail := PackedVector2Array([c - hn * HEAD_R * 0.6, c - hn * HEAD_R * 1.5 - hd * 3.0, c - hn * HEAD_R * 1.8 - hd * 11.0, c - hn * HEAD_R * 1.4 - hd * 18.0])
	draw_polyline(tail, Palette.OUTLINE, 6.0)
	draw_polyline(tail, Palette.HAIR, 4.0)
	# Cabelo (cobre a parte de trás e o topo).
	var cap := PackedVector2Array([c])
	for i in range(10):
		var a := PI * (0.12 + 0.9 * float(i) / 9.0)
		cap.append(c + hn * cos(a) * (HEAD_R + 1.6) + hd * sin(a) * (HEAD_R + 1.6))
	draw_colored_polygon(cap, Palette.HAIR)
	draw_polyline(cap, Palette.OUTLINE, 1.2)
	# Rosto.
	draw_circle(c, HEAD_R - 1.0, Palette.OUTLINE)
	draw_circle(c, HEAD_R - 2.0, Palette.SKIN)
	# Olho dourado (a Luz nos olhos).
	var eye := c + hn * HEAD_R * 0.42 + hd * HEAD_R * 0.12
	draw_circle(eye, 1.8, Palette.GOLD_GLOW)
	draw_circle(eye, 0.8, Palette.OUTLINE)


func _draw_blade() -> void:
	var hand: Vector2 = _geo["hand_f"]
	var tip: Vector2 = _geo["tip"]
	var d := (tip - hand).normalized()
	var n := Vector2(-d.y, d.x)
	# Guarda e punho.
	draw_line(hand - n * 5.5, hand + n * 5.5, Palette.GOLD, 2.2)
	draw_line(hand - d * 3.0, hand + d * 0.5, Palette.BELT, 2.5)
	# Lâmina de agulha: larga na base, fina na ponta.
	var blade := PackedVector2Array([hand + n * 2.2 + d * 2.0, tip, hand - n * 2.2 + d * 2.0])
	draw_colored_polygon(blade, Palette.STEEL)
	draw_polyline(PackedVector2Array([blade[0], blade[1], blade[2], blade[0]]), Palette.OUTLINE, 1.2)
	draw_line(hand + d * 4.0, tip, Palette.STEEL_SHADE, 1.0)
	# Fio dourado correndo pela lâmina.
	draw_line(hand + d * 2.0, tip - d * 1.0, Color(Palette.GOLD_GLOW, 0.8), 1.0)
