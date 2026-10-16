extends SceneTree

## Gera folhas de poses de Ondra (uma linha por animação, vários quadros) em docs/screenshots.
## Rodar com janela (precisa de renderização):
##   Godot_v4.7.1-stable_win64_console.exe --path game -s res://tools/capture_sheet.gd

const CELL_W := 120.0
const ROW_H := 118.0
const FRAMES := 8
const LABEL_W := 150.0

const SHEETS := [
	["idle", "run", "jump", "fall", "land", "attack1"],
	["attack2", "air_attack", "special", "hurt", "roll", "dead"],
]


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var out_dir := ProjectSettings.globalize_path("res://").path_join("../docs/screenshots")
	for i in range(SHEETS.size()):
		await _render_sheet(SHEETS[i], out_dir.path_join("poses_sheet_%d.png" % (i + 1)))
	quit(0)


func _render_sheet(anims: Array, out_path: String) -> void:
	var root_node := Node2D.new()
	root.add_child(root_node)
	var bg := ColorRect.new()
	bg.color = Palette.NIGHT
	bg.position = Vector2.ZERO
	bg.size = Vector2(LABEL_W + CELL_W * FRAMES, ROW_H * anims.size())
	root_node.add_child(bg)
	var rigs: Array = []
	for row in range(anims.size()):
		var anim_name: String = anims[row]
		var label := Label.new()
		label.text = anim_name
		label.position = Vector2(12.0, row * ROW_H + 46.0)
		label.add_theme_color_override("font_color", Palette.GOLD_GLOW)
		label.add_theme_font_size_override("font_size", 18)
		root_node.add_child(label)
		for f in range(FRAMES):
			var holder := Node2D.new()
			holder.position = Vector2(LABEL_W + CELL_W * f + CELL_W * 0.5, row * ROW_H + ROW_H - 16.0)
			root_node.add_child(holder)
			var rig := CharacterRig.new()
			holder.add_child(rig)
			rig.scale = Vector2(0.9, 0.9)
			rigs.append([rig, anim_name, float(f) / float(FRAMES - 1)])
	await process_frame
	for entry in rigs:
		var rig: CharacterRig = entry[0]
		var anim_name: String = entry[1]
		var t: float = entry[2]
		rig.play(anim_name, true)
		rig._blend_time = CharacterRig.BLEND_TIME
		rig.anim_time = t * float(rig.anims[anim_name]["dur"])
		rig.step(0.0, 0.0)
	await process_frame
	await process_frame
	var img := root.get_texture().get_image()
	img.save_png(out_path)
	print("Salvo: " + out_path)
	root_node.queue_free()
	await process_frame
