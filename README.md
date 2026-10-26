# Strings Chase — Cordas Partidas

Demonstração vertical de um jogo de ação 2D desenvolvido em Godot, ambientado no universo Strings. O protótipo apresenta a personagem Ondra enfrentando o Cão-Fuso nas Ruínas Desfiadas.

## O que já existe

- movimentação, corrida, salto variável, queda e esquiva;
- combo de dois golpes, ataque aéreo e habilidade especial;
- hitbox/hurtbox, hitstop, knockback, dano e morte;
- inimigo com patrulha, alerta, telegrafia, investida e recuperação;
- HUD, efeitos de combate, paralaxe e iluminação;
- 30 testes de gameplay em GDScript.

## Controles

| Ação | Teclas |
|---|---|
| Mover | A/D ou setas |
| Pular | Espaço, W ou seta para cima |
| Atacar | X ou J |
| Especial | C ou K |
| Esquivar | Shift ou L |
| Reiniciar | R |

## Executar

Abra a pasta `game/` no Godot 4.7.1 ou execute:

```bash
godot --path game
```

Para rodar os testes:

```bash
godot --headless --path game -s res://tests/test_gameplay.gd
```

O projeto ainda é uma vertical slice: possui uma fase e um inimigo, sem progressão ou salvamento.
