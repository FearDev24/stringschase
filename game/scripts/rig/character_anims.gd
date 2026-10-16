class_name CharacterAnims
extends RefCounted

## Biblioteca de animações da Ondra, definida como keyframes de juntas.
## Ângulos das pernas e braços são absolutos, em graus, medidos a partir de "para baixo":
## 0 = para baixo, 90 = para frente (direção do personagem), 180 = para cima.
## O tronco e a cabeça usam 0 = vertical. Qualquer junta não citada em um keyframe
## herda o valor da pose padrão.
##
## Formato de cada animação: {"dur": segundos, "loop": bool, "keys": [[t, pose], ...]}
## com t em [0, 1]. Para animações em loop o primeiro keyframe é repetido ao final.


static func default_pose() -> Dictionary:
	return {
		"hip_y": 0.0,
		"body": 0.0,
		"torso": 0.0,
		"head": 0.0,
		"arm_back_up": -12.0,
		"arm_back_lo": -22.0,
		"arm_front_up": 14.0,
		"arm_front_lo": 24.0,
		"leg_back_up": -3.0,
		"leg_back_lo": -1.0,
		"leg_front_up": 3.0,
		"leg_front_lo": 1.0,
		"wpn": 50.0,
	}


static func build() -> Dictionary:
	var anims := {}

	anims["idle"] = _anim(2.4, true, [
		[0.0, {"torso": 2.0, "head": -2.0, "arm_front_up": 34.0, "arm_front_lo": 58.0, "wpn": 40.0, "arm_back_up": -14.0, "arm_back_lo": -26.0}],
		[0.5, {"hip_y": 1.2, "torso": 0.0, "head": 0.0, "arm_front_up": 32.0, "arm_front_lo": 56.0, "wpn": 42.0, "arm_back_up": -12.0, "arm_back_lo": -24.0}],
	])

	# Corrida: ciclo de 4 keyframes, pernas e braços em oposição.
	anims["run"] = _anim(0.56, true, [
		[0.00, {"hip_y": -1.0, "torso": 7.0, "leg_front_up": 30.0, "leg_front_lo": 4.0, "leg_back_up": -28.0, "leg_back_lo": 22.0, "arm_front_up": -20.0, "arm_front_lo": 8.0, "arm_back_up": 24.0, "arm_back_lo": 40.0, "wpn": 30.0}],
		[0.25, {"hip_y": -4.0, "torso": 8.0, "leg_front_up": 8.0, "leg_front_lo": 20.0, "leg_back_up": -8.0, "leg_back_lo": 10.0, "arm_front_up": 0.0, "arm_front_lo": 14.0, "arm_back_up": 10.0, "arm_back_lo": 24.0, "wpn": 32.0}],
		[0.50, {"hip_y": -1.0, "torso": 7.0, "leg_front_up": -28.0, "leg_front_lo": 22.0, "leg_back_up": 30.0, "leg_back_lo": 4.0, "arm_front_up": 24.0, "arm_front_lo": 40.0, "arm_back_up": -20.0, "arm_back_lo": 8.0, "wpn": 30.0}],
		[0.75, {"hip_y": -4.0, "torso": 8.0, "leg_front_up": -8.0, "leg_front_lo": 10.0, "leg_back_up": 8.0, "leg_back_lo": 20.0, "arm_front_up": 10.0, "arm_front_lo": 24.0, "arm_back_up": 0.0, "arm_back_lo": 14.0, "wpn": 32.0}],
	])

	# Salto: impulso com braços para cima e pernas recolhidas.
	anims["jump"] = _anim(0.26, false, [
		[0.0, {"torso": 0.0, "leg_front_up": 40.0, "leg_front_lo": 10.0, "leg_back_up": 10.0, "leg_back_lo": 20.0, "arm_front_up": 110.0, "arm_front_lo": 150.0, "arm_back_up": 60.0, "arm_back_lo": 100.0, "wpn": 150.0}],
		[1.0, {"torso": -4.0, "leg_front_up": 75.0, "leg_front_lo": -20.0, "leg_back_up": 25.0, "leg_back_lo": -40.0, "arm_front_up": 120.0, "arm_front_lo": 160.0, "arm_back_up": 50.0, "arm_back_lo": 90.0, "wpn": 140.0}],
	])

	# Subida: segura a pose de salto enquanto sobe.
	anims["rise"] = _anim(0.2, true, [
		[0.0, {"torso": -4.0, "leg_front_up": 75.0, "leg_front_lo": -20.0, "leg_back_up": 25.0, "leg_back_lo": -40.0, "arm_front_up": 120.0, "arm_front_lo": 160.0, "arm_back_up": 50.0, "arm_back_lo": 90.0, "wpn": 140.0}],
	])

	# Queda: pernas estendidas, braços abertos para equilibrar.
	anims["fall"] = _anim(0.42, true, [
		[0.0, {"torso": 4.0, "head": -6.0, "leg_front_up": 12.0, "leg_front_lo": 14.0, "leg_back_up": -8.0, "leg_back_lo": -4.0, "arm_front_up": 70.0, "arm_front_lo": 85.0, "arm_back_up": -60.0, "arm_back_lo": -80.0, "wpn": 90.0}],
		[0.5, {"torso": 3.0, "head": -4.0, "leg_front_up": 6.0, "leg_front_lo": 10.0, "leg_back_up": -12.0, "leg_back_lo": -8.0, "arm_front_up": 80.0, "arm_front_lo": 92.0, "arm_back_up": -70.0, "arm_back_lo": -88.0, "wpn": 96.0}],
	])

	# Aterrissagem: agacha e volta à postura de espera.
	anims["land"] = _anim(0.18, false, [
		[0.0, {"hip_y": 7.0, "torso": 8.0, "leg_front_up": 55.0, "leg_front_lo": -10.0, "leg_back_up": 25.0, "leg_back_lo": -20.0, "arm_front_up": 60.0, "arm_front_lo": 80.0, "arm_back_up": -40.0, "arm_back_lo": -55.0, "wpn": 60.0}],
		[1.0, {"hip_y": 0.0, "torso": 2.0, "head": -2.0, "arm_front_up": 34.0, "arm_front_lo": 58.0, "wpn": 40.0, "arm_back_up": -14.0, "arm_back_lo": -26.0}],
	])

	# Golpe básico: preparação, corte horizontal, seguimento.
	anims["attack1"] = _anim(0.32, false, [
		[0.0, {"torso": -8.0, "head": -4.0, "leg_front_up": 8.0, "leg_back_up": -6.0, "arm_front_up": -70.0, "arm_front_lo": -120.0, "wpn": -135.0}],
		[0.35, {"torso": 12.0, "head": 4.0, "leg_front_up": 20.0, "leg_front_lo": 6.0, "leg_back_up": -20.0, "leg_back_lo": -8.0, "arm_front_up": 84.0, "arm_front_lo": 92.0, "wpn": 92.0}],
		[0.6, {"torso": 10.0, "arm_front_up": 70.0, "arm_front_lo": 78.0, "wpn": 72.0}],
		[1.0, {"torso": 2.0, "arm_front_up": 34.0, "arm_front_lo": 58.0, "wpn": 40.0, "arm_back_up": -14.0, "arm_back_lo": -26.0}],
	])

	# Segundo golpe do combo: golpe de cima para baixo com avanço do tronco.
	anims["attack2"] = _anim(0.46, false, [
		[0.0, {"torso": -4.0, "arm_front_up": 170.0, "arm_front_lo": 178.0, "wpn": 180.0, "arm_back_up": -30.0, "arm_back_lo": -60.0}],
		[0.42, {"torso": 22.0, "hip_y": 2.0, "arm_front_up": 100.0, "arm_front_lo": 70.0, "wpn": 22.0, "leg_front_up": 30.0, "leg_front_lo": 4.0, "leg_back_up": -28.0, "leg_back_lo": -10.0}],
		[0.7, {"torso": 8.0, "arm_front_up": 60.0, "arm_front_lo": 70.0, "wpn": 50.0}],
		[1.0, {"torso": 2.0, "arm_front_up": 34.0, "arm_front_lo": 58.0, "wpn": 40.0, "arm_back_up": -14.0, "arm_back_lo": -26.0}],
	])

	# Ataque aéreo: lâmina para baixo, com o corpo inclinado.
	anims["air_attack"] = _anim(0.42, false, [
		[0.0, {"torso": 6.0, "leg_front_up": 70.0, "leg_front_lo": -10.0, "leg_back_up": 40.0, "leg_back_lo": -30.0, "arm_front_up": 150.0, "arm_front_lo": 165.0, "wpn": 160.0}],
		[0.4, {"torso": 18.0, "leg_front_up": 40.0, "leg_front_lo": 10.0, "leg_back_up": 20.0, "leg_back_lo": 5.0, "arm_front_up": 100.0, "arm_front_lo": 80.0, "wpn": 18.0}],
		[1.0, {"torso": 14.0, "leg_front_up": 30.0, "leg_front_lo": 10.0, "leg_back_up": 14.0, "leg_back_lo": 4.0, "arm_front_up": 90.0, "arm_front_lo": 60.0, "wpn": 30.0}],
	])

	# Habilidade especial "Laço Tecido": giro completo com a lâmina horizontal.
	var spin_arms := {"arm_front_up": 90.0, "arm_front_lo": 90.0, "wpn": 90.0, "arm_back_up": -90.0, "arm_back_lo": -90.0, "torso": 0.0, "head": 0.0}
	anims["special"] = _anim(0.72, false, [
		[0.0, spin_arms.merged({"body": 0.0, "hip_y": 0.0})],
		[0.33, spin_arms.merged({"body": 120.0, "hip_y": -8.0})],
		[0.66, spin_arms.merged({"body": 240.0, "hip_y": -8.0})],
		[1.0, spin_arms.merged({"body": 360.0, "hip_y": 0.0})],
	])

	# Recebeu dano: recuo do tronco e braços abertos.
	anims["hurt"] = _anim(0.34, false, [
		[0.0, {"torso": -26.0, "head": -18.0, "hip_y": -2.0, "arm_front_up": -40.0, "arm_front_lo": -60.0, "arm_back_up": -70.0, "arm_back_lo": -80.0, "leg_front_up": 10.0, "leg_back_up": -10.0}],
		[0.4, {"torso": -14.0, "head": -8.0, "arm_front_up": -20.0, "arm_front_lo": -35.0, "arm_back_up": -40.0, "arm_back_lo": -50.0}],
		[1.0, {"torso": 2.0, "head": -2.0, "arm_front_up": 34.0, "arm_front_lo": 58.0, "wpn": 40.0, "arm_back_up": -14.0, "arm_back_lo": -26.0}],
	])

	# Esquiva: rolamento para frente.
	anims["roll"] = _anim(0.42, false, [
		[0.0, {"hip_y": 4.0, "body": 0.0, "leg_front_up": 80.0, "leg_front_lo": 100.0, "leg_back_up": 60.0, "leg_back_lo": 90.0}],
		[0.5, {"hip_y": 14.0, "body": 180.0, "leg_front_up": 40.0, "leg_front_lo": 60.0, "leg_back_up": 30.0, "leg_back_lo": 50.0}],
		[1.0, {"hip_y": 4.0, "body": 360.0, "leg_front_up": 3.0, "leg_front_lo": 1.0, "leg_back_up": -3.0, "leg_back_lo": -1.0}],
	])

	# Morte: cai para trás e fica no chão.
	anims["dead"] = _anim(1.2, false, [
		[0.0, {"torso": -10.0, "head": -10.0}],
		[0.5, {"body": -70.0, "hip_y": 14.0, "torso": 0.0, "head": -20.0}],
		[1.0, {"body": -88.0, "hip_y": 26.0, "leg_front_up": 80.0, "leg_front_lo": 60.0, "leg_back_up": 60.0, "leg_back_lo": 40.0, "arm_front_up": 100.0, "arm_front_lo": 110.0, "arm_back_up": -60.0, "arm_back_lo": -70.0, "head": -30.0}],
	])

	return anims


static func _anim(dur: float, loop: bool, raw_keys: Array) -> Dictionary:
	var keys: Array = []
	for k in raw_keys:
		var pose := default_pose()
		pose.merge(k[1], true)
		keys.append([float(k[0]), pose])
	if loop:
		# Fecha o ciclo: o último segmento volta ao primeiro keyframe.
		keys.append([1.0, keys[0][1].duplicate()])
	return {"dur": dur, "loop": loop, "keys": keys}


## Amostra a pose no instante normalizado t (0..1).
static func sample(anim: Dictionary, t: float) -> Dictionary:
	var keys: Array = anim["keys"]
	if anim["loop"]:
		t = fposmod(t, 1.0)
	else:
		t = clampf(t, 0.0, 1.0)
	for i in range(keys.size() - 1):
		var a: Array = keys[i]
		var b: Array = keys[i + 1]
		if t <= float(b[0]):
			var span: float = float(b[0]) - float(a[0])
			var k: float = 0.0 if span <= 0.0 else (t - float(a[0])) / span
			return lerp_pose(a[1], b[1], k)
	return keys[keys.size() - 1][1].duplicate()


static func lerp_pose(a: Dictionary, b: Dictionary, k: float) -> Dictionary:
	var out := {}
	for key in a:
		out[key] = lerpf(float(a[key]), float(b.get(key, a[key])), k)
	return out
