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
| A-011 | Áudio | Som | — | — | Não produzido ainda |

## Ferramentas usadas (todas gratuitas ou já instaladas)
- **Godot 4.7.1** (instalado em `C:\Users\CPU\Desktop\godot\`): engine, desenho, testes e capturas.
- **Python** e **Node.js**: não são necessários para os assets atuais.
- **Blender** e **Inkscape**: instalados, sem uso ainda.

## Capturas de referência
- `docs/screenshots/poses_sheet_1.png` e `poses_sheet_2.png`: folhas das 12 animações de Ondra.
- `docs/screenshots/game_01_idle.png` a `game_06_special.png`: telas reais da demonstração.
