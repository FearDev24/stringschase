# Status do Projeto — Cordas Partidas

Data: 16/10/2026. Versão: demonstração vertical, primeira entrega.

## 1. Diagnóstico inicial
- A pasta `C:\Projetos\Strings Universo` estava **vazia** ao iniciar. Não havia projeto anterior a preservar.
- Godot 4.7.1 encontrado em `C:\Users\CPU\Desktop\godot\` (não estava no PATH). Usado diretamente.
- Blender e Inkscape instalados, sem uso ainda.
- Node.js 24 e npm disponíveis.

## 2. Estado da demonstração vertical

Os critérios da seção 7 do pedido foram atendidos assim:

| Critério | Estado | Evidência |
|---|---|---|
| Personagem jogável com 11 animações pedidas | **Feito**: idle, run, jump (+rise), fall, land, attack1, attack2 (combo), air_attack, special, hurt, dead (+roll) | `poses_sheet_1.png`, `poses_sheet_2.png` |
| Transições coerentes e resposta aos comandos | **Feito**, com blend de 0,08 s e buffer de entrada | Testes de estado |
| Inimigo original com IA, ataque, reação e morte | **Feito**: Cão-Fuso, com patrulha, alerta, circulação, telegrafia, investida, exposição e morte | `game_04_hound_telegraph.png`; testes de IA |
| Cenário com identidade visual | **Feito**: Ruínas Desfiadas, com paralaxe, iluminação e decoração | `game_01_idle.png` |
| Combate: colisão, hitbox/hurtbox, combos, reações, efeitos, especial | **Feito** | `game_05_attack.png`, `game_06_special.png` |
| Executável na Godot | **Feito**: roda com `godot --path game` | Importação e execução sem erros |
| Qualidade visual demonstrável | **Parcial**: funcional e legível, mas com acabamento abaixo de arte profissional (ver seção 4) | Capturas reais |

### Como jogar
- **A / D** ou setas: mover
- **Espaço** (ou W / seta para cima): pular, segurando para pular mais alto
- **X** (ou J): atacar. Dois toques seguidos fazem o combo de 2 golpes
- **No ar, X**: ataque aéreo, uma vez por salto
- **C** (ou K): Laço Tecido, habilidade especial. Gasta 50% do medidor e ganha invulnerabilidade curta
- **Shift** (ou L): esquiva
- **R**: recomeçar

## 3. Funcionalidades concluídas
- Movimentação: corrida com aceleração, salto de altura variável, queda com gravidade reforçada, aterrissagem.
- Combate: combo de dois golpes com janela de cancelamento, ataque aéreo, especial com acerto repetido por alvo, esquiva com invulnerabilidade.
- Colisão: hitbox como segmento (lâmina) contra hurtbox retangular. Acerto único por golpe, e repetido só no especial.
- Reações: hitstop, recuo com knockback, piscar vermelho, estado HURT e recuperação.
- Inimigo: Cão-Fuso com IA em estados (patrulha, alerta, circulação, telegrafia, investida, exposição, dano, morte).
- HUD: vida, medidor, combo, inimigos restantes e controles.
- Testes: 30 testes de gameplay passando (`game/tests/test_gameplay.gd`).

## 4. Limitações conhecidas
1. **Arte procedural.** Personagem e inimigo são formas desenhadas por código. Funcionam e são coerentes, mas não têm o acabamento de pixel art ou ilustração pintada. Recomendação: avaliar a migração para arte desenhada no Krita antes da fase seguinte.
2. **Sem áudio.** Nenhum som foi produzido ou importado.
3. **Um inimigo e uma fase.** Conforme pedido, não há expansão de conteúdo antes da aprovação da demonstração.
4. **Sem menu, sem salvamento, sem progressão.** Fora do escopo da demonstração.
5. **Valores de balanceamento provisórios** (dano, velocidade, tempos de janela). Ajustáveis em `player.gd` (`ATTACKS`) e `spindle_hound.gd`.
6. **Só testado no Windows com Godot 4.7.1**, renderizador Compatibility.
7. **REA não instalado.** Ver `GRAND_CHASE_MECHANICS.md`, seção 0. A instalação exige sua autorização.
8. **Lore com lacunas na wiki.** A wiki não publica civilizações, nomes de Tecelões nem descrições de criaturas e chefes. Ver `STRINGS_LORE_REFERENCE.md`.

## 5. Problemas conhecidos
- Nenhum erro crítico conhecido nos testes e nas capturas.
- Durante o desenvolvimento houve um polígono degenerado na bota (corrigido, convexo).
- No modo headless, os desenhos não são renderizados, então a validação visual depende das capturas com janela.

## 6. Como reproduzir as verificações
```bash
"C:/Users/CPU/Desktop/godot/Godot_v4.7.1-stable_win64_console.exe" --headless --path "C:/Projetos/Strings Universo/game" -s res://tests/test_gameplay.gd
```
Para as capturas (precisa de janela):
```bash
"C:/Users/CPU/Desktop/godot/Godot_v4.7.1-stable_win64_console.exe" --path "C:/Projetos/Strings Universo/game" -s res://tools/capture_game.gd
```
```bash
"C:/Users/CPU/Desktop/godot/Godot_v4.7.1-stable_win64_console.exe" --path "C:/Projetos/Strings Universo/game" -s res://tools/capture_sheet.gd
```
