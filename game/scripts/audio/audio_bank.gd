class_name AudioBank
extends Node

## Banco de áudio de Cordas Partidas. Toca efeitos por nome (arquivos em assets/audio/sfx)
## com um pool de reprodutores, e mantém a música em loop (assets/audio/music).
## Os sons são gerados por tools/audio/generate_audio.mjs.

const SFX_PATH := "res://assets/audio/sfx/%s.wav"
const MUSIC_PATH := "res://assets/audio/music/ruinas_loop.wav"
const POOL_SIZE := 10

var _streams: Dictionary = {}
var _pool: Array[AudioStreamPlayer] = []
var _music: AudioStreamPlayer


func _ready() -> void:
	for i in range(POOL_SIZE):
		var p := AudioStreamPlayer.new()
		p.volume_db = -4.0
		add_child(p)
		_pool.append(p)
	_music = AudioStreamPlayer.new()
	_music.volume_db = -14.0
	add_child(_music)
	_start_music()


## Toca um efeito pelo nome. Se todos os canais estiverem ocupados, o efeito é ignorado.
func play(sound: String) -> void:
	var stream := _get_stream(sound)
	if stream == null:
		return
	for p in _pool:
		if not p.playing:
			p.stream = stream
			p.play()
			return


func _get_stream(sound: String) -> AudioStream:
	if _streams.has(sound):
		return _streams[sound]
	var path := SFX_PATH % sound
	if not ResourceLoader.exists(path):
		push_warning("Efeito sonoro ausente: " + path)
		return null
	var stream: AudioStream = load(path)
	_streams[sound] = stream
	return stream


func _start_music() -> void:
	if not ResourceLoader.exists(MUSIC_PATH):
		push_warning("Música ausente: " + MUSIC_PATH)
		return
	var stream: AudioStreamWAV = load(MUSIC_PATH)
	stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
	stream.loop_begin = 0
	# WAV 16 bits mono: dois bytes por quadro.
	stream.loop_end = int(stream.data.size() / 2)
	_music.stream = stream
	_music.play()
