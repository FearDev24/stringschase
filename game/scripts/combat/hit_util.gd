class_name HitUtil
extends RefCounted

## Testes de colisão do combate. Uma hitbox é um segmento (lâmina ou focinho) com raio,
## e uma hurtbox é um retângulo. A colisão é feita por amostragem ao longo do segmento.

const SAMPLES := 6


## true se o segmento, com raio "radius", toca o retângulo.
static func segment_hits_rect(seg: PackedVector2Array, rect: Rect2, radius: float) -> bool:
	if seg.size() < 2:
		return false
	var grown := rect.grow(radius)
	var a := seg[0]
	var b := seg[1]
	for i in range(SAMPLES + 1):
		var p := a.lerp(b, float(i) / float(SAMPLES))
		if grown.has_point(p):
			return true
	return false


## Ponto de contato aproximado, para posicionar os efeitos visuais.
static func contact_point(seg: PackedVector2Array, rect: Rect2) -> Vector2:
	var a := seg[0]
	var b := seg[1]
	for i in range(SAMPLES + 1):
		var p := a.lerp(b, float(i) / float(SAMPLES))
		if rect.grow(4.0).has_point(p):
			return p
	return rect.get_center()
