# Registro de Assets Originais — Cordas Partidas

Todo recurso visual ou sonoro do projeto está listado aqui, com a técnica e a localização. Nada foi importado de terceiros.

## Política
- Nenhum sprite, tileset, animação, pacote gratuito ou pago de terceiros.
- Nenhum recurso do MMORPG Strings ou de Grand Chase.
- Todos os visuais são **gerados por código** dentro do projeto Godot ou criados com ferramentas livres.

## Registro

| ID | Asset | Tipo | Técnica | Localização | Status |
|---|---|---|---|---|---|
| A-001 | Ondra (protagonista) | Personagem | Rig esquelético 2D desenhado por código (polígonos, contorno, sombreamento, capa com inércia, rastro) | `game/scripts/rig/character_rig.gd` | Demonstração, testado em tela |
| A-002 | Animações de Ondra (idle, run, jump, rise, fall, land, attack1, attack2, air_attack, special, hurt, roll, dead) | Animação | Keyframes de ângulos absolutos de juntas, blend 0,08 s | `game/scripts/rig/character_anims.gd` | Demonstração, 13 animações, folhas em `docs/screenshots/poses_sheet_*.png` |
| A-003 | Paleta de cores | Identidade | Constantes de cor | `game/scripts/rig/palette.gd` | Ativa |
| A-004 | Cão-Fuso (inimigo) | Criatura | Desenho procedural (bobina, osso, fios, pernas animadas, telegrafia) | `game/scripts/enemy/spindle_hound.gd` | Demonstração, testado em tela |
| A-005 | Ruínas Desfiadas (cenário) | Fase | Chão e plataformas por retângulos, decoração desenhada por código, blocos com semente fixa | `game/scripts/world/stage.gd` | Demonstração |
| A-006 | Camadas de paralaxe (ruínas, faixas, névoa) | Cenário | Desenho procedural em `_draw` | `game/scripts/world/decor_layer.gd` | Demonstração |
| A-007 | Luzes (lâmpadas, fenda, portal) | Iluminação | `PointLight2D` com textura radial gerada em código | `game/scripts/world/stage.gd` (`_build_lights`, `_glow_texture`) | Demonstração |
| A-008 | Faíscas de impacto | Efeito | Linhas radiais que expandem e somem | `game/scripts/fx/hit_spark.gd` | Demonstração |
| A-009 | Interface (HUD) | UI | Desenho por código (barras, textos) | `game/scripts/ui/hud.gd` | Demonstração |
| A-010 | Fonte | Fonte | Fonte padrão do Godot (`ThemeDB.fallback_font`) | — | Padrão do engine, sem arquivo adicionado |
| A-011 | 15 efeitos sonoros (golpes, impactos, pulo, aterrissagem, esquiva, especial, aviso/investida/morte do Cão-Fuso, dano e morte de Ondra) | Som | Síntese própria (onda quadrada, dente de serra, senoide e ruído com semente fixa), gerada por `game/tools/audio/generate_audio.mjs` | `game/assets/audio/sfx/*.wav` | Gerado. Não ouvido pelo autor do código: aguarda avaliação |
| A-012 | Música de loop "Ruínas" (10 s, 96 BPM, ré menor) | Música | Síntese própria: pad, baixo, arpejo e pulso, em loop sem emenda | `game/assets/audio/music/ruinas_loop.wav` | Gerada. Não ouvida pelo autor do código: aguarda avaliação |
| A-013 | Banco de áudio e ligações | Código | Pool de reprodutores; eventos de estado do jogador e do inimigo emitem `sfx_requested` | `game/scripts/audio/audio_bank.gd`, `fighter.gd`, `player.gd`, `spindle_hound.gd`, `main.gd` | Ativo |

## Ferramentas usadas (todas gratuitas)
- **Godot 4.7.1** (instalado em `C:\Users\CPU\Desktop\godot\`): engine, desenho, testes e capturas.
- **Node.js 24**: gerador de áudio (`game/tools/audio/generate_audio.mjs`), sem dependências.
- **Krita 5.3.4**, **Audacity 4.0.1** e **LMMS 1.2.2**: instalados via winget com autorização. Ainda não usados nos assets: a arte e a música atuais são geradas por código.
- **Blender** e **Inkscape**: instalados antes, sem uso ainda.

## Capturas de referência
- `docs/screenshots/poses_sheet_1.png` e `poses_sheet_2.png`: folhas das 12 animações de Ondra.
- `docs/screenshots/game_01_idle.png` a `game_06_special.png`: telas reais da demonstração.
