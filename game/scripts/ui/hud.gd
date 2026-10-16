class_name Hud
extends Control

## HUD desenhada por código: vida, medidor da habilidade, combo, inimigos restantes e
## mensagens de fim de partida. Os dados chegam pela função update_state, chamada por main.gd.

var hp := 100
var max_hp := 100
var meter := 0.0
var combo := 0
var remaining := 0
var defeated := 0
var message := ""
var sub_message := ""
var fps := 0.0


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_fit_to_viewport()
	get_viewport().size_changed.connect(_fit_to_viewport)


## Dentro de um CanvasLayer o Control não herda tamanho, então ocupa a tela explicitamente.
func _fit_to_viewport() -> void:
	position = Vector2.ZERO
	size = get_viewport().get_visible_rect().size
	queue_redraw()


func update_state(data: Dictionary) -> void:
	hp = int(data.get("hp", hp))
	max_hp = int(data.get("max_hp", max_hp))
	meter = float(data.get("meter", meter))
	combo = int(data.get("combo", combo))
	remaining = int(data.get("remaining", remaining))
	defeated = int(data.get("defeated", defeated))
	message = str(data.get("message", ""))
	sub_message = str(data.get("sub_message", ""))
	fps = float(data.get("fps", fps))
	queue_redraw()


func _draw() -> void:
	var font := ThemeDB.fallback_font
	var margin := Vector2(18.0, 18.0)
	# Vida.
	draw_string(font, margin + Vector2(0, 14), "ONDRA", HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Palette.GOLD_GLOW)
	_bar(margin + Vector2(0, 22), Vector2(260.0, 16.0), float(hp) / float(max_hp), Color("c94b5a"))
	# Medidor do Laço Tecido.
	_bar(margin + Vector2(0, 46), Vector2(180.0, 10.0), meter / 100.0, Palette.GOLD)
	draw_string(font, margin + Vector2(186, 55), "Laço Tecido (C) %d%%" % int(meter), HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Palette.GOLD_GLOW)
	# Combo.
	if combo > 1:
		draw_string(font, Vector2(size.x * 0.5 - 60.0, 120.0), "%d GOLPES" % combo, HORIZONTAL_ALIGNMENT_CENTER, 120.0, 26, Palette.GOLD_GLOW)
	# Inimigos.
	var kills := "Cães-Fuso restantes: %d   derrotados: %d" % [remaining, defeated]
	draw_string(font, Vector2(size.x - 430.0, 30.0), kills, HORIZONTAL_ALIGNMENT_RIGHT, 412.0, 14, Palette.STEEL)
	# Controles.
	var help := "A/D mover · Espaço pular · X atacar · C Laço Tecido · Shift esquivar · R recomeçar"
	draw_string(font, Vector2(margin.x, size.y - 16.0), help, HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color(Palette.STEEL, 0.75))
	draw_string(font, Vector2(size.x - 120.0, size.y - 16.0), "%d FPS" % int(fps), HORIZONTAL_ALIGNMENT_RIGHT, 108.0, 12, Color(Palette.STEEL, 0.5))
	# Mensagem central.
	if message != "":
		var ccx := size.x * 0.5
		draw_rect(Rect2(Vector2(ccx - 320.0, size.y * 0.5 - 60.0), Vector2(640.0, 110.0)), Color(Palette.NIGHT, 0.75))
		draw_string(font, Vector2(ccx - 300.0, size.y * 0.5 - 16.0), message, HORIZONTAL_ALIGNMENT_CENTER, 600.0, 30, Palette.GOLD_GLOW)
		if sub_message != "":
			draw_string(font, Vector2(ccx - 300.0, size.y * 0.5 + 22.0), sub_message, HORIZONTAL_ALIGNMENT_CENTER, 600.0, 15, Palette.STEEL)


func _bar(pos: Vector2, dims: Vector2, frac: float, col: Color) -> void:
	draw_rect(Rect2(pos - Vector2(2, 2), dims + Vector2(4, 4)), Palette.OUTLINE)
	draw_rect(Rect2(pos, dims), Color(0.1, 0.1, 0.16, 0.9))
	draw_rect(Rect2(pos, Vector2(dims.x * clampf(frac, 0.0, 1.0), dims.y)), col)
