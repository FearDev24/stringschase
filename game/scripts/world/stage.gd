class_name Stage
extends Node2D

## Frayed Ruins (Ruínas Desfiadas, tradução nossa): fase curta da demonstração.
## Desenha o mundo (chão, plataformas, tear quebrado, lâmpadas, fenda de luz), cria as
## colisões e as luzes, e monta duas camadas de paralaxe (DecorLayer) atrás e na frente.

const WORLD_SIZE := Vector2(2600.0, 720.0)
const FLOOR_Y := 640.0
const PLATFORMS := [
	Rect2(420.0, 520.0, 200.0, 16.0),
	Rect2(760.0, 430.0, 150.0, 16.0),
	Rect2(1000.0, 560.0, 180.0, 16.0),
	Rect2(1300.0, 470.0, 200.0, 16.0),
	Rect2(1640.0, 380.0, 180.0, 16.0),
	Rect2(1900.0, 540.0, 200.0, 16.0),
]
const LAMPS := [
	Vector2(300.0, 420.0),
	Vector2(900.0, 360.0),
	Vector2(1420.0, 390.0),
	Vector2(1980.0, 470.0),
	Vector2(2450.0, 420.0),
]
const PILLARS := [180.0, 640.0, 1120.0, 1560.0, 2240.0, 2520.0]
const PORTAL_POS := Vector2(120.0, 470.0)

var _time := 0.0
var _rng := RandomNumberGenerator.new()
var _tiles: Array[Rect2] = []
var _pillar_h: Array[float] = []


func _ready() -> void:
	_rng.seed = 1187
	_build_collision()
	_build_tiles()
	for x in PILLARS:
		_pillar_h.append(300.0 + _rng.randf_range(-20.0, 20.0))
	_build_lights()
	_build_decor_layers()


func _process(delta: float) -> void:
	_time += delta
	queue_redraw()


func spawn_points() -> Array[Vector2]:
	return [Vector2(900.0, FLOOR_Y), Vector2(1500.0, FLOOR_Y), Vector2(2050.0, FLOOR_Y)]


func player_spawn() -> Vector2:
	return Vector2(160.0, FLOOR_Y - 40.0)


func _add_solid(r: Rect2, one_way := false) -> void:
	var body := StaticBody2D.new()
	var shape := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = r.size
	shape.shape = rect
	shape.position = r.position + r.size * 0.5
	shape.one_way_collision = one_way
	body.add_child(shape)
	add_child(body)


func _build_collision() -> void:
	_add_solid(Rect2(-60.0, FLOOR_Y, WORLD_SIZE.x + 120.0, 300.0))
	_add_solid(Rect2(-60.0, -300.0, 60.0, 1300.0))
	_add_solid(Rect2(WORLD_SIZE.x, -300.0, 60.0, 1300.0))
	for r in PLATFORMS:
		_add_solid(r, true)


func _build_tiles() -> void:
	# Blocos do chão, gerados com semente fixa para que a fase seja sempre igual.
	var x := -60.0
	while x < WORLD_SIZE.x + 60.0:
		var w := _rng.randf_range(44.0, 78.0)
		_tiles.append(Rect2(x, FLOOR_Y + 14.0 + _rng.randf_range(-3.0, 3.0), w, 46.0))
		x += w + 2.0


func _build_lights() -> void:
	var tex := _glow_texture()
	for p in LAMPS:
		var light := PointLight2D.new()
		light.texture = tex
		light.texture_scale = 2.4
		light.energy = 1.1
		light.color = Palette.GOLD
		light.position = p
		add_child(light)
	# Luz da fenda do Caos, bem mais fraca e avermelhada.
	var crack := PointLight2D.new()
	crack.texture = tex
	crack.texture_scale = 1.4
	crack.energy = 0.7
	crack.color = Palette.CORRUPT_GLOW
	crack.position = Vector2(2000.0, FLOOR_Y - 8.0)
	add_child(crack)
	# A fenda de luz do Grande Portal, a porta dimensional do capítulo 1.
	var portal := PointLight2D.new()
	portal.texture = tex
	portal.texture_scale = 2.0
	portal.energy = 1.0
	portal.color = Color("fff1c4")
	portal.position = PORTAL_POS
	add_child(portal)


func _build_decor_layers() -> void:
	var pb := ParallaxBackground.new()
	add_child(pb)
	var far := ParallaxLayer.new()
	far.motion_scale = Vector2(0.25, 0.25)
	pb.add_child(far)
	var far_draw := DecorLayer.new()
	far_draw.kind = DecorLayer.Kind.FAR
	far.add_child(far_draw)
	var mid := ParallaxLayer.new()
	mid.motion_scale = Vector2(0.55, 0.55)
	pb.add_child(mid)
	var mid_draw := DecorLayer.new()
	mid_draw.kind = DecorLayer.Kind.MID
	mid.add_child(mid_draw)
	var fg := ParallaxLayer.new()
	fg.motion_scale = Vector2(1.25, 1.25)
	pb.add_child(fg)
	var fog := DecorLayer.new()
	fog.kind = DecorLayer.Kind.FOG
	fg.add_child(fog)


static func _glow_texture() -> GradientTexture2D:
	var g := Gradient.new()
	g.colors = PackedColorArray([Color(1.0, 1.0, 1.0, 1.0), Color(1.0, 1.0, 1.0, 0.0)])
	g.offsets = PackedFloat32Array([0.0, 1.0])
	var t := GradientTexture2D.new()
	t.gradient = g
	t.fill = GradientTexture2D.FILL_RADIAL
	t.fill_from = Vector2(0.5, 0.5)
	t.fill_to = Vector2(1.0, 0.5)
	t.width = 256
	t.height = 256
	return t


func _draw() -> void:
	_draw_pillars()
	_draw_loom(Vector2(560.0, FLOOR_Y))
	_draw_portal(PORTAL_POS)
	_draw_floor()
	for r in PLATFORMS:
		_draw_platform(r)
	_draw_crack(Vector2(2000.0, FLOOR_Y))
	for p in LAMPS:
		_draw_lamp(p)


func _draw_pillars() -> void:
	for i in range(PILLARS.size()):
		var x: float = PILLARS[i]
		var h := _pillar_h[i]
		var top := FLOOR_Y - h
		var body := Rect2(x - 28.0, top, 56.0, h)
		draw_rect(body, Palette.NIGHT_LIGHT.darkened(0.15))
		draw_rect(Rect2(x - 34.0, FLOOR_Y - 14.0, 68.0, 14.0), Palette.NIGHT_LIGHT)
		# Topo quebrado, em degraus.
		var jag := PackedVector2Array([Vector2(x - 28.0, top), Vector2(x - 14.0, top - 18.0), Vector2(x + 4.0, top - 6.0), Vector2(x + 18.0, top - 26.0), Vector2(x + 28.0, top)])
		draw_colored_polygon(jag, Palette.NIGHT_LIGHT.darkened(0.15))
		draw_polyline(PackedVector2Array([jag[0], jag[1], jag[2], jag[3], jag[4]]), Palette.OUTLINE, 1.5)
		# Fio dourado enrolado no pilar.
		for k in range(4):
			var yy := top + 40.0 + float(k) * 56.0
			draw_line(Vector2(x - 26.0, yy), Vector2(x + 26.0, yy + 8.0), Color(Palette.GOLD, 0.35), 1.0)


func _draw_loom(base: Vector2) -> void:
	var wood := Palette.WOOD_DARK
	# Pés e travessa do tear.
	draw_rect(Rect2(base + Vector2(-70.0, -170.0), Vector2(10.0, 170.0)), wood)
	draw_rect(Rect2(base + Vector2(60.0, -170.0), Vector2(10.0, 170.0)), wood)
	draw_rect(Rect2(base + Vector2(-74.0, -176.0), Vector2(148.0, 12.0)), Palette.WOOD)
	# Tecido inacabado, desfiado nas bordas.
	var cloth := PackedVector2Array([base + Vector2(-60.0, -164.0), base + Vector2(50.0, -164.0), base + Vector2(46.0, -90.0), base + Vector2(30.0, -70.0), base + Vector2(10.0, -86.0), base + Vector2(-14.0, -62.0), base + Vector2(-40.0, -88.0), base + Vector2(-58.0, -76.0)])
	draw_colored_polygon(cloth, Palette.COAT.darkened(0.1))
	draw_polyline(PackedVector2Array(cloth), Palette.OUTLINE, 1.2)
	for i in range(7):
		var x := -52.0 + float(i) * 15.0
		draw_line(base + Vector2(x, -160.0), base + Vector2(x + 4.0, -92.0), Color(Palette.GOLD, 0.45), 1.0)
	# Fusos no chão.
	for fx in [-44.0, 30.0]:
		draw_circle(base + Vector2(fx, -4.0), 6.0, Palette.BONE_SHADE)
		draw_circle(base + Vector2(fx, -4.0), 3.0, Palette.BONE)


func _draw_portal(p: Vector2) -> void:
	var pulse := 0.5 + 0.5 * sin(_time * 2.0)
	for k in range(5):
		var rx := 26.0 + float(k) * 6.0
		draw_arc(p, rx, 0.0, TAU, 40, Color(Palette.GOLD_GLOW, (0.45 - float(k) * 0.07) * (0.7 + 0.3 * pulse)), 2.0)
		draw_arc(p, rx * 0.7, 0.0, TAU, 40, Color(Color("fff1c4"), 0.25), 1.0)
	draw_circle(p, 22.0, Color(Color("fff1c4"), 0.35 + 0.1 * pulse))
	draw_circle(p, 10.0, Color(Color("ffffff"), 0.8))
	# Fios que escapam da fenda.
	for i in range(6):
		var a := _time * 0.8 + float(i) * TAU / 6.0
		var end := p + Vector2(cos(a) * 56.0, sin(a) * 84.0)
		draw_line(p + Vector2(cos(a) * 18.0, sin(a) * 26.0), end, Color(Palette.GOLD, 0.5), 1.0)


func _draw_floor() -> void:
	draw_rect(Rect2(-60.0, FLOOR_Y, WORLD_SIZE.x + 120.0, 80.0), Palette.NIGHT_LIGHT.darkened(0.2))
	for t in _tiles:
		draw_rect(t, Palette.NIGHT_LIGHT)
		draw_rect(Rect2(t.position, Vector2(t.size.x, 3.0)), Palette.NIGHT_LIGHT.lightened(0.15))
		draw_rect(t, Palette.OUTLINE, false, 1.0)
	# Borda superior do chão, com fiapos.
	draw_line(Vector2(-60.0, FLOOR_Y), Vector2(WORLD_SIZE.x + 60.0, FLOOR_Y), Palette.STEEL_SHADE, 2.0)
	for i in range(40):
		var x := float(i) * 66.0 + 12.0
		draw_line(Vector2(x, FLOOR_Y), Vector2(x + 4.0, FLOOR_Y - 5.0), Color(Palette.GOLD, 0.4), 1.0)


func _draw_platform(r: Rect2) -> void:
	draw_rect(r, Palette.COAT_DARK)
	draw_rect(Rect2(r.position, Vector2(r.size.x, 4.0)), Palette.COAT_LIGHT)
	draw_rect(r, Palette.OUTLINE, false, 1.5)
	# Fiapos de fio pendurados embaixo, com leve balanço.
	var n := int(r.size.x / 26.0)
	for i in range(n):
		var x := r.position.x + 12.0 + float(i) * 26.0
		var sway := sin(_time * 1.6 + x * 0.05) * 3.0
		draw_line(Vector2(x, r.position.y + r.size.y), Vector2(x + sway, r.position.y + r.size.y + 14.0), Color(Palette.GOLD, 0.55), 1.0)


func _draw_crack(p: Vector2) -> void:
	var pulse := 0.6 + 0.4 * sin(_time * 3.0)
	var pts := PackedVector2Array([p + Vector2(-40.0, 0.0), p + Vector2(-20.0, -3.0), p + Vector2(-8.0, 2.0), p + Vector2(8.0, -2.0), p + Vector2(22.0, 3.0), p + Vector2(40.0, 0.0)])
	draw_polyline(pts, Color(Palette.CORRUPT, 0.5 * pulse), 6.0)
	draw_polyline(pts, Palette.CORRUPT_GLOW, 1.5)


func _draw_lamp(p: Vector2) -> void:
	var pulse := 0.8 + 0.2 * sin(_time * 4.0 + p.x)
	draw_line(p + Vector2(0.0, -40.0), p + Vector2(0.0, -6.0), Color(Palette.GOLD, 0.6), 1.0)
	draw_circle(p, 9.0, Color(Palette.GOLD, 0.25 * pulse))
	draw_circle(p, 4.5, Palette.GOLD_GLOW)
	draw_arc(p, 4.5, 0.0, TAU, 12, Palette.OUTLINE, 1.0)
