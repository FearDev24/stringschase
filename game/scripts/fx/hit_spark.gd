class_name HitSpark
extends Node2D

## Faíscas de impacto: linhas que se abrem a partir do ponto de contato e desaparecem.

const LIFE := 0.22

var color := Palette.GOLD_GLOW
var _t := 0.0
var _angles: Array[float] = []


func _ready() -> void:
	var rng := RandomNumberGenerator.new()
	rng.randomize()
	for i in range(7):
		_angles.append(rng.randf_range(0.0, TAU))


func _process(delta: float) -> void:
	_t += delta
	if _t >= LIFE:
		queue_free()
		return
	queue_redraw()


func _draw() -> void:
	var f := _t / LIFE
	var a := 1.0 - f
	for ang in _angles:
		var dir := Vector2(cos(ang), sin(ang))
		draw_line(dir * (6.0 + 30.0 * f), dir * (10.0 + 46.0 * f), Color(color, a), 2.0)
	draw_circle(Vector2.ZERO, 10.0 * (1.0 - f) + 2.0, Color(Color.WHITE, a * 0.8))
