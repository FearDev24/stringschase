# CLAUDE.md — Regras permanentes do projeto Cordas Partidas

Leia este arquivo antes de qualquer alteração. Ele vale para todas as sessões futuras.

## Contexto
- Jogo de RPG de ação e plataforma 2D, original, dentro do universo Strings. **Não é o MMORPG** e não deve ser modificado por este projeto.
- Engine: **Godot 4.7.1** (`C:\Users\CPU\Desktop\godot\Godot_v4.7.1-stable_win64.exe`). Plataforma: Windows.
- Código em `game/`. Documentação na raiz.

## Regras inegociáveis
1. **Nenhum asset de terceiros.** Não baixar sprites, tilesets, animações, pacotes públicos ou modelos prontos. Não copiar Grand Chase nem o MMORPG Strings.
2. **Custo zero.** Só ferramentas gratuitas ou open source. Não contratar serviços nem APIs pagas. Pedir autorização antes de qualquer gasto.
3. **Pedir autorização** antes de instalar programas, alterar configurações do computador, apagar ou sobrescrever trabalho existente, ou alterar a história oficial de Strings.
4. **Preservar o trabalho.** Não reiniciar o projeto. Não apagar arquivos sem olhar antes.
5. **Não declarar testes aprovados sem executá-los.** Registrar limitações.
6. **Não apresentar um asset como de qualidade profissional** sem evidência visual (captura em `docs/screenshots/`).
7. **Demonstração antes de expansão.** Não adicionar personagens, fases ou inimigos novos sem aprovação do responsável pela demonstração.

## Como trabalhar
- Antes de editar um sistema, ler o script existente e os testes relacionados.
- Ao criar um asset novo, registrar em `ASSET_REGISTRY.md` com técnica e localização.
- Ao decidir algo importante (técnica, balanceamento, lore), registrar em `PROJECT_STATUS.md`.
- Após mudar código de gameplay, rodar os testes (ver `PROJECT_STATUS.md`, seção 6).
- Após mudar aparência, gerar capturas com `tools/capture_game.gd` e `tools/capture_sheet.gd`.

## Estrutura
```
game/
  project.godot
  scenes/main.tscn            cena de entrada (script em scripts/main.gd)
  scripts/
    main.gd                   montagem, entrada, resolução de acertos, reinício
    rig/                      personagem desenhado por código e animações
    player/player.gd          Ondra: estados, combo, especial, esquiva
    enemy/spindle_hound.gd    Cão-Fuso: IA e desenho
    combat/                   base de lutador (fighter.gd) e testes de colisão (hit_util.gd)
    world/                    fase (stage.gd) e camadas de paralaxe (decor_layer.gd)
    fx/hit_spark.gd           faíscas de impacto
    ui/hud.gd                 HUD
  tests/test_gameplay.gd      testes headless
  tools/                      capturas de tela (precisam de janela)
docs/screenshots/             capturas reais
```

## Convenções de código
- GDScript 4, tipagem explícita onde ajuda a leitura.
- Comentários e textos de jogo em português do Brasil.
- Constantes de cor só em `palette.gd`.
- Dados de golpe ficam em dicionários `ATTACKS` (player) e `active_attack()` (inimigos). O contrato é: `active_attack()`, `attack_segment()`, `make_hit()`, `on_attack_landed()`, `take_hit()`.
- Ângulos do rig: absolutos, em graus, 0 = para baixo (pernas e braços), tronco e cabeça 0 = vertical.
- Nunca usar `_rng` dentro de `_draw`: o resultado deve ser fixo entre quadros.

## Pontos de atenção
- Desenhar polígonos com contornos côncavos pode quebrar a triangulação. Preferir formas convexas.
- Os testes usam `Input.action_press`, então a ordem entre a entrada e o quadro físico importa.
- A cena principal processa a resolução de acertos com `process_physics_priority = 100`, para rodar depois dos lutadores.

## Referências
- `GRAND_CHASE_MECHANICS.md`: estudo de mecânicas (observado, verificado ou hipótese).
- `STRINGS_LORE_REFERENCE.md`: lore oficial usado, limitações da wiki e conteúdo inédito.
- `ART_DIRECTION.md`: identidade visual e critérios.
- `DEVELOPMENT_ROADMAP.md`: etapas.
