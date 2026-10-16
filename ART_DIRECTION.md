# Direção de Arte — Cordas Partidas

## 1. Princípios

1. **Original do início ao fim.** Nenhum sprite, tileset, animação ou pacote de terceiros entra no projeto. Todos os visuais são desenhados por código (Godot) ou criados com ferramentas livres. Ver `ASSET_REGISTRY.md`.
2. **Silhueta antes de detalhe.** Ondra e os inimigos precisam ser reconhecíveis em preto e branco.
3. **Ouro é a Luz, vermelho-violeta é o Caos.** Esse contraste guia o jogo inteiro: fios dourados marcam o que é da criação, e a corrupção aparece em vermelho.
4. **Leitura de combate sempre.** O cenário nunca pode competir com o personagem ou com os avisos de ataque.

## 2. Técnica adotada (demonstração)

| Elemento | Técnica | Por quê |
|---|---|---|
| Personagem (Ondra) | Rig esquelético 2D desenhado por código (`scripts/rig/character_rig.gd`): polígonos afinados, contorno, sombreamento, capa com inércia e rastro da lâmina | Sem arquivos importados, animação transicionável por código, fácil de alterar |
| Animações | Keyframes de ângulos absolutos de juntas (`scripts/rig/character_anims.gd`), blend de 0,08 s | Trocar a animação sem salto visual e sem assets |
| Inimigo (Cão-Fuso) | Desenho procedural com fases de andar, telegrafia pulsante e exposição | Mesma técnica, sem rig complexo |
| Cenário | Desenho procedural em `_draw`, blocos com semente fixa, paralaxe em 3 camadas (`stage.gd`, `decor_layer.gd`) | Consistência entre execuções |
| Luz | `CanvasModulate` azulado, `PointLight2D` dourados nas lâmpadas e avermelhado na fenda | Contraste e profundidade |

**Limitação honesta:** essa técnica entrega identidade e legibilidade, mas não alcança o acabamento de um sprite pintado à mão. Para uma qualidade superior, o próximo passo é migrar parte do rig para pixel art ou ilustração desenhada no Krita, mantendo a mesma paleta e as mesmas silhuetas.

## 3. Paleta

Definida em `game/scripts/rig/palette.gd`. Cores principais:

| Papel | Nome | Hex |
|---|---|---|
| Contorno | OUTLINE | `#0b0d17` |
| Casaco | COAT / COAT_DARK / COAT_LIGHT | `#2b3766` / `#1b2140` / `#4a5f9c` |
| Ouro (Luz) | GOLD / GOLD_GLOW | `#f5c85a` / `#ffe9a6` |
| Caos | CORRUPT / CORRUPT_GLOW | `#d6365f` / `#ff7aa0` |
| Noite (céu) | NIGHT / NIGHT_LIGHT | `#0d1024` / `#2a2f5c` |
| Osso e madeira | BONE / WOOD | `#c9b08a` / `#7d4f2c` |

## 4. Personagem: Ondra

- **Silhueta:** casaco longo com barra arrematada, capa que flutua, rabo de cavalo, lâmina de agulha longa.
- **Identidade:** losango dourado no peito, costura dourada na barra, olhos com brilho dourado, fio dourado na lâmina.
- **Proporções:** cabeça grande e expressiva (≈ 1/5 da altura), corpo estreito, braços longos para a lâmina.
- **Cores:** índigo com detalhes dourados. Não usar vermelho no personagem, reservado ao Caos.

## 5. Inimigo: Cão-Fuso (Spindle Hound)

- Corpo de bobina de tear de madeira, tampas de osso, fios vermelhos enrolados.
- Quatro patas finas, focinho ósseo, olhos vermelho-violeta.
- Ao avisar a investida: as orelhas se achatam e o corpo ganha um brilho vermelho pulsante.
- Ao morrer: os fios se desfiam e a silhueta desaparece em 1,4 s.

## 6. Cenário: Ruínas Desfiadas (Frayed Ruins)

- **Profundidade:** três camadas de paralaxe (ruínas distantes, faixas rasgadas com fios dourados, névoa e fios em primeiro plano).
- **Iluminação:** noite azulada, lâmpadas douradas nas plataformas, fenda avermelhada no chão, fenda de luz do Grande Portal à esquerda.
- **Elementos ambientais:** tear quebrado, pilares com topo partido, plataformas com fiapos pendurados, chão de blocos.
- **Leitura:** plataformas em tom índigo claro sobre fundo mais escuro; avisos e inimigos sempre com contorno.

## 7. Padrões de animação

- Ataques: preparação (windup) → golpe → recuperação, com janela ativa curta definida em `player.gd` (`ATTACKS`).
- Transições: todo estado tem animação própria. Entre estados, blend de 0,08 s.
- Impacto: pausa de 0,04–0,10 s (hitstop), faísca de 0,22 s, piscar vermelho de 0,12 s no alvo.
- Pulo: impulso com braços para cima → subida → queda com braços abertos → aterrissagem agachada de 0,16 s.

## 8. Critérios de qualidade (checklist para cada novo asset)

- [ ] Legível em preto e branco (silhueta).
- [ ] Usa a paleta de `palette.gd`.
- [ ] Original: criado no projeto, sem origem externa, registrado em `ASSET_REGISTRY.md`.
- [ ] Testado em tela real (captura em `docs/screenshots/`).
- [ ] Não compete com o personagem nem com os avisos de ataque.

## 9. Ferramentas livres e disponíveis

- **Godot 4.7.1** (instalado): engine e desenho procedural.
- **Blender** (instalado): modelagem 3D para renderização de sprites, caso seja adotado.
- **Inkscape** (instalado): arte vetorial, caso seja necessário.
- **Krita**: não instalado. Recomendado para pintura digital futura.
