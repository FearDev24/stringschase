# Grand Chase — Estudo de Mecânicas

Objetivo: entender os sistemas de ação lateral que tornam Grand Chase profundo, e registrar o que foi **observado**, **verificado** ou apenas **hipótese**. Este documento não copia código, assets ou conteúdo protegido do jogo.

## 0. Status da investigação com REA

| Item | Situação |
|---|---|
| REA (`rea-agents` v6.5.0) | **Instalado e registrado no Claude Code** via `npx rea-agents setup --client claude_code --yes` (autorizado pelo responsável). Backup da configuração anterior em `C:\Users\CPU\.claude.json.rea.backup`. Skill instalada em `C:\Users\CPU\.claude\skills\reverse-engineer-anything` (v42, 207 ferramentas). **Claude Desktop, Codex e demais clientes não foram configurados.** Requer reiniciar o Claude Code para carregar o servidor MCP. |
| Provedores nativos (Ghidra, IDA, JADX) | **Não configurados.** Análise nativa exige um motor instalado (Ghidra 12.1.x, via `GHIDRA_INSTALL_DIR`, ou IDA/JADX). Ghidra é a alternativa gratuita; a instalação dele ainda precisa de autorização. |
| Engenharia reversa de binários do Grand Chase | **Não realizada.** A integração está pronta, mas nenhuma análise de binários, memória ou pacotes do jogo foi feita. Ainda falta definir o escopo e a autorização para isso. |
| Fontes usadas | Descrições públicas (Wikipedia, StrategyWiki, TV Tropes e artigos de guia listados abaixo). |

**Consequência:** tudo abaixo é classificado como *observado publicamente* (descrito em fontes de terceiros) ou *hipótese de design*. Nada foi *verificado tecnicamente* neste estudo. Se a autorização para REA for dada, a seção 8 indica o que investigar primeiro.

## 1. Fontes públicas consultadas

- Wikipedia (inglês), verbete "Grand Chase": https://en.wikipedia.org/wiki/Grand_Chase
- StrategyWiki, "Grand Chase/Gameplay": https://strategywiki.org/wiki/Grand_Chase/Gameplay
- TV Tropes, "Grand Chase": https://www.tvtropes.org/pmwiki/pmwiki.php/VideoGame/GrandChase
- BlueStacks, guia de iniciantes: https://www.bluestacks.com/blog/app-reviews/grand-chase/lets-play-grand-chase-the-complete-review-and-beginners-guide.html

## 2. Sistemas observados publicamente (classificação: observado, não verificado)

### Movimentação
- Jogo lateral com corrida, salto e controle de movimento direto pelo teclado.
- Esquiva/rolamento (*roll*) usado no meio de combos para reposicionar e ganhar quadros de invulnerabilidade (relato de comunidade via TV Tropes).
- "Stepping" (pequenos deslocamentos rápidos) existia como glitch que foi mantido no jogo.

### Combate
- Ataques básicos encadeados em combos terrestres e aéreos.
- Habilidades especiais em três graus, com efeitos visuais fortes.
- Combo básico de um personagem (Knight) pode manter inimigos em *hitstun*, segundo relato de comunidade.
- O design evita "apertar botão sem pensar": a combinação de combo, habilidade e item é a profundidade central.

### Classes e progressão
- Personagens predefinidos (não há criação de personagem).
- Progressão por mudança de classe (*job change*): cada personagem tem uma linha de classes, por exemplo, Elesis: Knight → Spearman → Swordmaster → Savior (TV Tropes).
- Fontes divergem sobre o número de classes/personagens; registrado como **incerto**.

## 3. Lacunas (não encontradas nas fontes)

- Valores de dash, distância de deslocamento e tempo de invulnerabilidade.
- Estrutura exata de combos aéreos, cancelamentos e janelas de input.
- Hitboxes, hurtboxes, valores de hitstun e knockback.
- Comportamento de IA de monstros e chefes.
- Estrutura multiplayer.

Esses pontos são **hipóteses de design** nesta versão do documento.

## 4. Adaptações originais previstas (Cordas Partidas)

Os sistemas abaixo são implementados do zero, com valores e nomes próprios.

| Sistema | Adaptação original | Estado |
|---|---|---|
| Movimentação | Corrida com aceleração/desaceleração, salto de altura variável, queda com controle aéreo limitado | **Implementado** (demo) |
| Esquiva | Rolamento com quadros de invulnerabilidade, usado para reposicionar | **Implementado** (demo) |
| Combo terrestre | Dois golpes encadeados com janela de cancelamento e buffer de input (o segundo é a finalização) | **Implementado** (demo). Um terceiro golpe fica para a próxima etapa |
| Ataque aéreo | Golpe descendente com janela de cancelamento ao pousar | **Implementado** (demo) |
| Habilidade especial | "Laço Tecido": giro que atinge tudo em volta, consome medidor | **Implementado** (demo) |
| Hitstop / hitstun / knockback | Pausa de impacto, reação e empurrão | **Implementado** (demo) |
| IA de inimigo | Cão-Fuso com patrulha, alerta, aproximação, aviso de investida (telegrafia), recuperação exposta | **Implementado** (demo) |
| Classes e progressão | Previsto para fases posteriores | Pendente |
| Dungeons e multiplayer | Previsto (arquitetura de cenas e spawns); não implementado | Pendente |

## 5. Princípios de design derivados

1. **Leitura de combate:** todo ataque inimigo tem aviso visual antes do dano (telegrafia de pelo menos 0,4 s).
2. **Recuperação exposta:** ataques fortes deixam o autor vulnerável por um intervalo curto, para haver recompensa por timing.
3. **Cancelamento controlado:** golpes podem ser encadeados só dentro de janelas definidas, para evitar combos "infinitos".
4. **Identidade por personagem:** cada personagem terá estilo, arma, movimentação e especial próprios (não variações cosméticas).

## 6. Como validar as mecânicas originais

- Cronometrar movimentos e combos na própria demo (valores registrados em `game/scripts/combat/` e nos testes).
- Comparar a "sensação" com jogadores de referência, sem reproduzir o conteúdo do jogo original.

## 7. Limitações

- Este documento não substitui análise técnica. Nenhuma afirmação sobre valores internos do Grand Chase foi confirmada.
- Não há capturas do jogo original usadas aqui.

## 8. Próximo passo se o REA for autorizado

Análise **somente de comportamento observável em uma instalação legítima do jogo, de propriedade do responsável**, sem contornar DRM ou anticheat e sem extrair conteúdo protegido. Prioridades: tempos de input (gravação de vídeo com quadros), janelas de cancelamento e valores de knockback, sempre registrados como *verificados* ou *hipótese*.
