class_name Fighter
extends CharacterBody2D

## Base de qualquer personagem que luta (jogador e inimigos).
## Guarda vida, invulnerabilidade, pausa de impacto (hitstop) e a hurtbox usada nos testes de colisão.
## Os métodos de ataque (active_attack, attack_segment, make_hit) são o contrato usado por main.gd.

signal died(fighter: Fighter)
## Pede um efeito sonoro pelo nome (ver AudioBank e assets/audio/sfx).
signal sfx_requested(sound: String)

const HURT_SIZE := Vector2(30.0, 86.0)
const FLASH_TIME := 0.12

var hp := 100
var max_hp := 100
var facing := 1.0
var hitstop := 0.0
var invuln := 0.0
var flash := 0.0
var alive := true
## Incrementa a cada golpe novo, para que um mesmo golpe não acerte o mesmo alvo duas vezes.
var attack_serial := 0
var rig: CharacterRig


## Retorna true quando o personagem está congelado pelo hitstop, e já consome o tempo.
func is_frozen(delta: float) -> bool:
	if hitstop > 0.0:
		hitstop -= delta
		return true
	return false


func tick_timers(delta: float) -> void:
	if invuln > 0.0:
		invuln -= delta
	if flash > 0.0:
		flash -= delta
	modulate = Color(1.0, 0.5, 0.5) if flash > 0.0 else Color.WHITE


func get_hurtbox() -> Rect2:
	return Rect2(global_position + Vector2(-HURT_SIZE.x * 0.5, -HURT_SIZE.y), HURT_SIZE)


func set_facing(dir: float) -> void:
	if dir != 0.0:
		facing = signf(dir)
		if rig != null:
			rig.set_facing(facing)


## Golpe ativo neste instante, ou dicionário vazio.
func active_attack() -> Dictionary:
	return {}


## Segmento [início, fim] da hitbox em coordenadas globais.
func attack_segment() -> PackedVector2Array:
	return PackedVector2Array()


## Monta o pacote do golpe que é entregue ao alvo.
func make_hit(data: Dictionary) -> Dictionary:
	return {
		"damage": data["damage"],
		"knock": data["knock"],
		"stun": data["stun"],
		"hitstop": data["hitstop"],
		"source_x": global_position.x,
		"knockdown": data["knockdown"],
	}


func on_attack_landed(_data: Dictionary) -> void:
	pass


## Recebe um golpe. hit contém: damage, knock (Vector2), stun, hitstop, source_x.
## Retorna false se o golpe foi ignorado (morto ou invulnerável).
func take_hit(hit: Dictionary) -> bool:
	if not alive or invuln > 0.0:
		return false
	hp = maxi(0, hp - int(hit.get("damage", 0)))
	hitstop = maxf(hitstop, float(hit.get("hitstop", 0.06)))
	flash = FLASH_TIME
	var knock: Vector2 = hit.get("knock", Vector2.ZERO)
	var from_x: float = float(hit.get("source_x", global_position.x))
	var dir := signf(global_position.x - from_x)
	if dir == 0.0:
		dir = -facing
	velocity = Vector2(knock.x * dir, knock.y)
	if hp <= 0:
		_die()
	return true


func _die() -> void:
	alive = false
	died.emit(self)
