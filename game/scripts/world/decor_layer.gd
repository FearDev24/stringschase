class_name DecorLayer
extends Node2D

## Camada de cenário em paralaxe. FAR: silhuetas de ruínas distantes. MID: faixas rasgadas
## penduradas com fios dourados. FOG: névoa e fios em primeiro plano.

enum Kind { FAR, MID, FOG }

var kind: int = Kind.FAR
var _time := 0.0
var _rng := RandomNumberGenerator.new()
var _far_heights: Array[float] = []
var _banner_x: Array[float] = []


func _ready() -> void:
	_rng.seed = 40 + kind
	if kind == Kind.FAR:
		for i in range(40):
			_far_heights.append(_rng.randf_range(200.0, 420.0))
	if kind == Kind.MID:
		for i in range(12):
			_banner_x.append(-200.0 + float(i) * 260.0 + _rng.randf_range(-40.0, 40.0))


func _process(delta: float) -> void:
	_time += delta
	queue_redraw()


func _draw() -> void:
	match kind:
		Kind.FAR:
			_draw_far()
		Kind.MID:
			_draw_mid()
		Kind.FOG:
			_draw_fog()


func _draw_far() -> void:
	var base := Palette.NIGHT_LIGHT.darkened(0.35)
	# Céu em faixas, para dar profundidade noturna.
	for i in range(12):
		var y := float(i) * 60.0 - 60.0
		var t := float(i) / 11.0
		draw_rect(Rect2(-600.0, y, 4000.0, 62.0), Palette.NIGHT.lerp(Palette.NIGHT_LIGHT, t * 0.6))
	for i in range(_far_heights.size()):
		var x := -600.0 + float(i) * 100.0
		var h := _far_heights[i]
		draw_rect(Rect2(x, 720.0 - h, 70.0, h), base)
		# Arco quebrado em algumas torres.
		if i % 3 == 0:
			draw_arc(Vector2(x + 35.0, 720.0 - h), 36.0, PI, TAU, 16, base, 6.0)
	# Brilhos dourados distantes, entre as torres.
	for i in range(14):
		var gx := float(i) * 240.0 - 200.0
		draw_circle(Vector2(gx, 300.0 + sin(float(i) * 1.7) * 60.0), 3.0, Color(Palette.GOLD, 0.25))


func _draw_mid() -> void:
	for i in range(_banner_x.size()):
		var x := _banner_x[i]
		var length := 220.0 + float(i % 3) * 40.0
		var sway := sin(_time * 0.9 + float(i)) * 6.0
		var w := 60.0
		var pts := PackedVector2Array([
			Vector2(x - w * 0.5, 0.0),
			Vector2(x + w * 0.5, 0.0),
			Vector2(x + w * 0.5 + sway, length - 36.0),
			Vector2(x + w * 0.2 + sway * 1.2, length - 16.0),
			Vector2(x + sway * 1.4, length),
			Vector2(x - w * 0.2 + sway * 1.2, length - 22.0),
			Vector2(x - w * 0.5 + sway, length - 40.0),
		])
		draw_colored_polygon(pts, Palette.COAT_DARK.darkened(0.1))
		draw_polyline(pts, Palette.OUTLINE, 1.5)
		# Faixa vermelha do Caos, desbotada, e um fio dourado.
		draw_line(Vector2(x - w * 0.3, 0.0), Vector2(x - w * 0.3 + sway * 0.5, length - 40.0), Color(Palette.CORRUPT, 0.35), 3.0)
		draw_line(Vector2(x + w * 0.25, 0.0), Vector2(x + w * 0.25 + sway, length - 30.0), Color(Palette.GOLD, 0.45), 1.5)


func _draw_fog() -> void:
	for i in range(9):
		var x := float(i) * 340.0 + fmod(_time * 22.0 + float(i) * 80.0, 340.0) - 200.0
		var y := 600.0 + sin(float(i) * 2.3) * 40.0
		draw_circle(Vector2(x, y), 120.0, Color(Palette.NIGHT_LIGHT.lightened(0.3), 0.07))
	# Fios dourados caindo do topo, em primeiro plano.
	for i in range(8):
		var x := float(i) * 170.0 + 40.0
		var sway := sin(_time * 0.7 + float(i)) * 12.0
		draw_line(Vector2(x, -10.0), Vector2(x + sway, 150.0 + float(i % 3) * 30.0), Color(Palette.GOLD, 0.22), 1.0)
