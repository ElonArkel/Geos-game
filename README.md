# Geos - Godot 4.3+

Jogo 2D de plataforma pedagógico: um aprendiz do Instituto Geos preso no núcleo da Terra
precisa subir por todas as camadas até a exosfera.

## Como abrir
1. Instale o Godot 4.3 ou mais novo (versão "Standard", não precisa da .NET).
2. Abra o Godot > **Importar** > selecione o arquivo `project.godot` desta pasta.
3. Aperte **F5**. O jogo abre no menu principal.

Se o Godot perguntar sobre converter o projeto para uma versão mais nova, pode aceitar.

## Controles
| Ação | Teclas |
|---|---|
| Mover | A/D ou setas |
| Pular | Espaço, W ou seta para cima (segure para pular mais alto) |
| Interagir (bancada da cápsula) | E |
| Scan (analisa o objeto mais próximo, custa 2 de energia) | Q |
| Fechar a bancada | Esc |

## O que já funciona
- Personagem com corrida, pulo variável, coyote time e buffer de pulo.
- **Scan**: aponta o material/perigo mais próximo e mostra o texto educativo.
- Coleta de materiais, inventário e **construção de componentes** na bancada da cápsula.
- **Energia limitada**: zonas perigosas drenam energia, cair custa 15, Scan custa 2.
  Chegar a zero reinicia no último checkpoint com 60% de energia.
- Habilidades liberadas por componentes (ex.: Isolante Térmico = resistir a calor).
- Corrente de ar/convecção que empurra o jogador para cima.
- Passagens bloqueadas até construir o componente certo.
- 2 fases jogáveis (Núcleo Interno e Núcleo Externo) e os dados das 10 camadas.

## Estrutura de pastas
```
autoload/game_state.gd   estado global: energia, inventário, camadas, materiais, receitas
scripts/                 um script por tipo de objeto
scenes/                  cenas reutilizáveis (player, plataforma, material, hud...)
scenes/levels/           level_01.tscn, level_02.tscn... (um arquivo por camada)
assets/sprites/          coloque seus sprites aqui
assets/audio/            coloque sons/músicas aqui
```

## Onde mexer para o conteúdo do jogo
Quase tudo que é conteúdo está em **`autoload/game_state.gd`**:
- `LAYERS`: nome, profundidade e texto de cada camada (REVISE com seu professor).
- `MATERIALS`: materiais e o texto que o Scan mostra.
- `RECIPES`: componentes, custo e habilidade que liberam.

Para ligar uma habilidade nova: crie a receita com `"ability": "nome"` e use
`required_ability = "nome"` em um Hazard na fase.

## Como colocar seus sprites
Tudo hoje usa formas coloridas como placeholder. Para trocar:

**Personagem** (`scenes/player.tscn`): dentro do nó `Visual`, apague `Placeholder` e `Visor`,
adicione um `AnimatedSprite2D` (ou `Sprite2D`) e arraste seus quadros. O espelhamento
esquerda/direita já funciona porque o script inverte o nó `Visual`.
Se o sprite for maior que o placeholder (20x28 px), ajuste o `CollisionShape2D`.

**Materiais, bancada, passagem e checkpoint**: abra a cena (ex.: `collectible.tscn`), adicione
um filho chamado exatamente **`Visual`** (Sprite2D). Quando esse nó existe, o placeholder não é criado.
Para materiais com sprites diferentes, use "Cenas herdadas" (botão direito na cena > Nova cena herdada)
ou troque a textura por fase.

**Plataformas**: em `platform.tscn` desligue `show_placeholder` e adicione um `Sprite2D`
ou `TileMapLayer`. O colisor continua sendo o `size` do Inspetor.

## Como criar uma fase nova (próxima camada)
1. Em `scenes/levels/`, duplique `level_02.tscn` e renomeie para o próximo número
   (`level_03.tscn` = Manto Inferior, e assim por diante até `level_10.tscn`).
2. Selecione o nó raiz e mude `layer_index` (2 para o Manto Inferior, 3 para o Manto Superior...).
3. Arraste cenas de `scenes/` para montar: `platform`, `hazard`, `updraft`, `collectible`, `checkpoint`, `station`, `exit_portal`.
   Tamanhos de plataforma/zonas se ajustam em `size` no Inspetor.
4. Em `exit_portal`, escolha o `required_component` que libera a saída.

O jogo já procura `level_03.tscn` sozinho quando o jogador passa pelo `exit_portal` da fase 2.

## Dicas de ajuste de jogabilidade
Selecione o nó `Player` e mexa no Inspetor: `speed`, `jump_velocity`, `gravity`...
Alturas de pulo: com os valores atuais o jogador sobe ~74 px e alcança ~150 px na horizontal.
Mantenha degraus de plataforma abaixo de 60 px de altura.

## Ideias para os próximos passos
- Menu de pausa e tela de fim de jogo (envio do sinal na exosfera exige `bobina_de_sinal` + `antena_de_resgate`).
- Tela de "Diário do Scan" listando tudo que o jogador já analisou.
- Perguntas rápidas no Scan para reforçar o conteúdo.
- Sons, música e animações.
