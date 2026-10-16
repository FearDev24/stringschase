# Roteiro de Desenvolvimento — Cordas Partidas

Ordem definida no pedido: a demonstração vertical vem antes de qualquer expansão. Cada etapa só começa depois da aprovação da anterior.

## Etapa 0 — Base (concluída)
- Projeto Godot 4.7.1, pasta `game/`.
- Documentação base (`CLAUDE.md`, `PROJECT_STATUS.md`, `ART_DIRECTION.md`, `ASSET_REGISTRY.md`, `GRAND_CHASE_MECHANICS.md`, `STRINGS_LORE_REFERENCE.md`).

## Etapa 1 — Demonstração vertical (concluída, aguarda avaliação)
- Ondra com 13 animações e controles.
- Combate: combo, ataque aéreo, especial, esquiva, hitstop, knockback.
- Cão-Fuso com IA completa.
- Ruínas Desfiadas com paralaxe e iluminação.
- 30 testes de gameplay e capturas reais.
- **Aguardando sua avaliação antes da etapa 2.**

## Etapa 2 — Qualidade visual (proposta, depende da sua avaliação)
- Decidir a técnica final de arte do personagem: manter o rig procedural ou migrar para ilustração no Krita.
- Refinar silhueta, proporções e peças de armadura.
- Revisar contraste e leitura de combate em cada cena.
- Adicionar áudio original (sons de corte, impacto e aviso), produzido com ferramentas livres.

## Etapa 3 — Ajuste de combate (proposta)
- Balancear dano, tempos de janela e knockback com base no teste de sensação.
- Adicionar cancelamentos, hitbox por golpe e um segundo combo.
- Medir frame-data dos golpes e registrar no `GRAND_CHASE_MECHANICS.md`.

## Etapa 4 — Inimigos e fases (depois da aprovação)
- Mais criaturas, cada uma com comportamento próprio (evitar perseguição simples).
- Minibosses e um primeiro chefe, com base na arena descrita na wiki (The Unspooler's Loom).
- Mais uma fase conectada às Ruínas.

## Etapa 5 — Progressão (depois da etapa 4)
- Classes ou formas de Ondra, medidor e recompensas.
- Salvamento local.

## Etapa 6 — Arquitetura multiplayer (preparação apenas)
- Separar estado de jogo da apresentação.
- Sem servidores pagos. Qualquer teste online será local ou em LAN.

## Pendências imediatas
- [ ] Autorização para instalar o REA (`npx rea-agents setup`).
- [ ] Sua avaliação da demonstração e decisão sobre a técnica de arte (Etapa 2).
