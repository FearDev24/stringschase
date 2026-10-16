// Gerador de áudio original de Cordas Partidas (síntese própria, sem samples de terceiros).
// Gera efeitos sonoros e uma música em loop como WAV 16 bits mono, 22050 Hz.
//
// Uso (a partir da pasta game/):
//   node tools/audio/generate_audio.mjs
//
// Ruído usa semente fixa: a saída é idêntica em todas as execuções.

import { mkdirSync, writeFileSync } from "node:fs";
import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";

const SR = 22050;
const here = dirname(fileURLToPath(import.meta.url));
const SFX_DIR = join(here, "..", "..", "assets", "audio", "sfx");
const MUSIC_DIR = join(here, "..", "..", "assets", "audio", "music");

let seed = 12345;
function rnd() {
	seed = (seed * 1664525 + 1013904223) >>> 0;
	return (seed / 4294967296) * 2 - 1;
}

const sq = (ph) => (ph % 1 < 0.5 ? 1 : -1);
const saw = (ph) => 2 * (ph % 1) - 1;
const sine = (ph) => Math.sin(2 * Math.PI * ph);

// Avança a fase de um oscilador por frequência f (Hz) e devolve a fase em ciclos.
function step(st, key, f) {
	st[key] = (st[key] || 0) + f / SR;
	return st[key];
}

// Renderiza um efeito de duração dur (segundos) com fn(t, st, dur) -> amostra.
function render(dur, fn) {
	const n = Math.floor(dur * SR);
	const out = new Float32Array(n);
	const st = { lp: 0 };
	for (let i = 0; i < n; i++) {
		out[i] = fn(i / SR, st, dur);
	}
	return out;
}

// Filtro passa-baixa de um polo, para tirar o chiado do ruído.
function lowpass(st, x, a) {
	st.lp += a * (x - st.lp);
	return st.lp;
}

function normalize(buf, peak = 0.85) {
	let max = 0;
	for (const v of buf) max = Math.max(max, Math.abs(v));
	if (max === 0) return buf;
	const k = peak / max;
	for (let i = 0; i < buf.length; i++) buf[i] *= k;
	return buf;
}

function encodeWav(samples) {
	const n = samples.length;
	const buf = Buffer.alloc(44 + n * 2);
	buf.write("RIFF", 0);
	buf.writeUInt32LE(36 + n * 2, 4);
	buf.write("WAVE", 8);
	buf.write("fmt ", 12);
	buf.writeUInt32LE(16, 16);
	buf.writeUInt16LE(1, 20);
	buf.writeUInt16LE(1, 22);
	buf.writeUInt32LE(SR, 24);
	buf.writeUInt32LE(SR * 2, 28);
	buf.writeUInt16LE(2, 32);
	buf.writeUInt16LE(16, 34);
	buf.write("data", 36);
	buf.writeUInt32LE(n * 2, 40);
	for (let i = 0; i < n; i++) {
		const v = Math.max(-1, Math.min(1, samples[i]));
		buf.writeInt16LE(Math.round(v * 32767), 44 + i * 2);
	}
	return buf;
}

// ---------- Efeitos sonoros ----------

const SFX = {
	// Golpe básico: varredura de ar com pico agudo.
	swing_light: render(0.16, (t, st, d) => {
		const f = 1400 * (1 - t / d) + 300;
		const x = 0.5 * saw(step(st, "ph", f)) * Math.exp(-t * 18) + 0.35 * rnd() * Math.exp(-t * 30);
		return x * 0.9;
	}),
	// Golpe pesado do combo: mais grave e longo.
	swing_heavy: render(0.24, (t, st, d) => {
		const f = 620 * (1 - t / d) + 140;
		const x = 0.55 * saw(step(st, "ph", f)) * Math.exp(-t * 11) + 0.45 * rnd() * Math.exp(-t * 16);
		return x;
	}),
	// Impacto em carne: tom grave que cai, mais um estalo de ruído.
	hit_flesh: render(0.14, (t, st) => {
		const f = 170 * Math.exp(-t * 12) + 50;
		return 0.6 * sq(step(st, "ph", f)) * Math.exp(-t * 20) + 0.7 * rnd() * Math.exp(-t * 60);
	}),
	// Impacto em metal (lâmina contra armadura do inimigo).
	hit_metal: render(0.14, (t, st) => {
		const ph1 = step(st, "a", 1800);
		const ph2 = step(st, "b", 2700);
		return 0.45 * sine(ph1) * Math.exp(-t * 25) + 0.25 * sine(ph2) * Math.exp(-t * 35) + 0.2 * rnd() * Math.exp(-t * 80);
	}),
	// Acerto da habilidade especial: tilintar dourado.
	gold_chime: render(0.45, (t, st) => {
		const a = sine(step(st, "a", 880)) * Math.exp(-t * 7);
		const b = sine(step(st, "b", 1320)) * 0.6 * Math.exp(-t * 9);
		return 0.5 * (a + b);
	}),
	// Pulo: varredura ascendente.
	jump: render(0.18, (t, st, d) => {
		const f = 260 + (t / d) * 1500;
		return 0.35 * sq(step(st, "ph", f)) * (1 - t / d);
	}),
	// Aterrissagem: baque grave.
	land: render(0.14, (t, st) => {
		const f = 110 * Math.exp(-t * 15) + 45;
		return 0.6 * sine(step(st, "ph", f)) * Math.exp(-t * 22) + 0.25 * rnd() * Math.exp(-t * 50);
	}),
	// Esquiva: sopro de ar com filtro que abre.
	roll: render(0.4, (t, st, d) => {
		const a = 0.02 + 0.12 * (t / d);
		return 0.6 * lowpass(st, rnd(), a) * Math.sin((Math.PI * t) / d);
	}),
	// Laço Tecido: varredura e arpejo dourado de quatro notas.
	special: render(0.7, (t, st, d) => {
		const a = 0.05 + 0.25 * Math.sin((Math.PI * t) / d);
		const sweep = lowpass(st, rnd(), a) * 0.4 * Math.sin((Math.PI * t) / d);
		const notes = [587, 698, 880, 1175];
		let arp = 0;
		for (let k = 0; k < notes.length; k++) {
			const start = k * 0.11;
			if (t >= start) {
				const lt = t - start;
				arp += sine(step(st, "n" + k, notes[k])) * Math.exp(-lt * 9) * 0.22;
			}
		}
		return sweep + arp;
	}),
	// Aviso do Cão-Fuso: rosnado que sobe e treme.
	hound_telegraph: render(0.55, (t, st, d) => {
		const vib = 14 * sine(t * 7);
		const f = (88 + vib) * (1 + 0.4 * (t / d));
		const env = Math.pow(t / d, 1.5);
		return 0.32 * saw(step(st, "ph", f)) * env + 0.12 * rnd() * env;
	}),
	// Investida do Cão-Fuso: ruído com varredura descendente.
	hound_lunge: render(0.34, (t, st) => {
		const f = 320 * Math.exp(-t * 5) + 70;
		return 0.4 * saw(step(st, "ph", f)) * Math.exp(-t * 6) + 0.3 * rnd() * Math.exp(-t * 10);
	}),
	// Morte do Cão-Fuso: fios se desfiando com tremolo.
	hound_die: render(1.2, (t, st) => {
		const trem = 0.5 + 0.5 * sine(12 * t - 8 * t * t);
		const noise = lowpass(st, rnd(), 0.05) * trem * Math.exp(-t * 2.2) * 0.6;
		const f = 400 * Math.exp(-t * 3) + 60;
		return noise + 0.25 * sine(step(st, "ph", f)) * Math.exp(-t * 3);
	}),
	// Dano em um inimigo.
	enemy_hurt: render(0.12, (t, st) => {
		return 0.4 * sq(step(st, "ph", 500 * Math.exp(-t * 15) + 120)) * Math.exp(-t * 15) + 0.3 * rnd() * Math.exp(-t * 40);
	}),
	// Dano em Ondra.
	player_hurt: render(0.25, (t, st) => {
		const f = 420 * Math.exp(-t * 4) + 150;
		return 0.35 * sq(step(st, "ph", f)) * Math.exp(-t * 8) + 0.25 * rnd() * Math.exp(-t * 20);
	}),
	// Morte de Ondra: queda grave e longa.
	player_die: render(1.0, (t, st) => {
		const f = 300 * Math.exp(-t * 2.5) + 60;
		return 0.4 * saw(step(st, "ph", f)) * Math.exp(-t * 1.8) + 0.25 * sine(step(st, "b", 45)) * Math.exp(-t * 2);
	}),
};

// ---------- Música em loop ----------

// Loop de 4 compassos, 96 BPM, ré menor, com pad, baixo, arpejo e pulso.
function buildMusic() {
	const bpm = 96;
	const beat = 60 / bpm;
	const bars = 4;
	const total = bars * 4 * beat;
	const N = Math.round(total * SR);
	const out = new Float32Array(N);
	const midi = (m) => 440 * Math.pow(2, (m - 69) / 12);
	const progression = [
		[50, 53, 57], // Ré menor (D3 F3 A3)
		[46, 50, 53], // Si bemol maior
		[53, 57, 60], // Fá maior
		[48, 52, 55], // Dó maior
	];
	const addEvent = (start, dur, fn) => {
		const n = Math.round(dur * SR);
		const s0 = Math.round(start * SR);
		for (let k = 0; k < n; k++) {
			const idx = (s0 + k) % N;
			out[idx] += fn(k / SR, k, dur);
		}
	};

	// Pad: notas longas com ataque suave, em cada compasso.
	for (let bar = 0; bar < bars; bar++) {
		const start = bar * 4 * beat;
		const dur = 4 * beat;
		for (const note of progression[bar]) {
			const f = midi(note + 12);
			let ph = 0;
			addEvent(start, dur, (t) => {
				ph += f / SR;
				const env = Math.min(1, t / 0.3) * Math.min(1, (dur - t) / 0.4);
				return 0.05 * env * (sine(ph) + 0.4 * sine(ph * 2 + 0.1));
			});
		}
	}

	// Baixo: pulsos de colcheia na fundamental uma oitava abaixo.
	for (let bar = 0; bar < bars; bar++) {
		for (let e = 0; e < 8; e++) {
			const start = bar * 4 * beat + e * (beat / 2);
			const f = midi(progression[bar][0] - 12);
			let ph = 0;
			addEvent(start, beat / 2, (t) => {
				ph += f / SR;
				return 0.09 * saw(ph) * Math.exp(-t * 9);
			});
		}
	}

	// Arpejo: semicolcheias percorrendo as notas do acorde, em tom mais alto.
	for (let bar = 0; bar < bars; bar++) {
		const chord = progression[bar];
		for (let s = 0; s < 16; s++) {
			const start = bar * 4 * beat + s * (beat / 4);
			const f = midi(chord[s % 3] + 24);
			addEvent(start, beat / 4, (t) => 0.035 * sine(f * t) * Math.exp(-t * 14));
		}
	}

	// Pulso de bumbo e chiado de chimbal, para dar ritmo.
	for (let beatIdx = 0; beatIdx < bars * 4; beatIdx++) {
		const start = beatIdx * beat;
		if (beatIdx % 2 === 0) {
			let ph = 0;
			addEvent(start, 0.25, (t) => {
				ph += (110 * Math.exp(-t * 18) + 42) / SR;
				return 0.22 * sine(ph) * Math.exp(-t * 10);
			});
		}
		addEvent(start + beat / 2, 0.05, (t) => 0.05 * rnd() * Math.exp(-t * 80));
	}

	return normalize(out, 0.7);
}

// ---------- Escrita ----------

mkdirSync(SFX_DIR, { recursive: true });
mkdirSync(MUSIC_DIR, { recursive: true });

for (const [name, samples] of Object.entries(SFX)) {
	const path = join(SFX_DIR, name + ".wav");
	writeFileSync(path, encodeWav(normalize(samples, 0.8)));
	console.log("efeito: " + name + ".wav (" + (samples.length / SR).toFixed(2) + " s)");
}

const music = buildMusic();
writeFileSync(join(MUSIC_DIR, "ruinas_loop.wav"), encodeWav(music));
console.log("música: ruinas_loop.wav (" + (music.length / SR).toFixed(2) + " s, loop)");
